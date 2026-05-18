# ollama-cloud extension

Self-populating provider for [Ollama Cloud](https://ollama.com). Registers every
tool-capable cloud model with Pi automatically, deriving per-model metadata from
the API instead of a hand-maintained `models.json`.

## Why this exists

`~/.pi/agent/models.json` is a static list — every new Ollama Cloud model means
another hand-written entry. This extension fetches the live catalog at startup,
so new models appear on their own and the only thing you curate is the
**scoped-models** list (`enabledModels` in `settings.json`).

## How it works

Pi awaits the async extension factory before startup, so the provider is fully
populated by the time `/model`, Ctrl+P, and `pi --list-models` run.

1. `GET https://ollama.com/v1/models` — the OpenAI-compat endpoint. Returns
   model IDs only (no metadata).
2. For each ID, `POST https://ollama.com/api/show` — Ollama's native endpoint,
   which *does* return metadata. All calls run in parallel (`Promise.all`),
   ~1–2s total.
3. `pi.registerProvider("ollama-cloud", …)` with the derived models.

### Metadata derivation

| Pi field        | Source                                                        |
|-----------------|---------------------------------------------------------------|
| `id` / `name`   | `/v1/models` id (verbatim — correct by construction)          |
| `reasoning`     | `/api/show` `capabilities` includes `"thinking"`              |
| `input`         | `["text","image"]` if `capabilities` includes `"vision"`, else `["text"]` |
| `contextWindow` | the single `model_info` key ending in `.context_length`       |
| *(model kept?)* | only if `capabilities` includes `"tools"` — others are unusable in an agent loop and are skipped |

### Approximated fields

The API does not expose these, so they are **not** authoritative:

- **`maxTokens`** — `min(32000, contextWindow / 4)`. No output-cap field exists
  anywhere in `/api/show`. If a model truncates responses or tool-call JSON
  (`stopReason: "length"`), raise it via `modelOverrides` (see below).
- **`cost`** — all zeros. Irrelevant for your own cloud usage.

These are the low-stakes fields: wrong values fail loudly and locally, never
silently corrupt context. `contextWindow` (the one field whose errors are
silent and serious) **is** API-derived, so the dangerous case is covered.

## Requirements

- `OLLAMA_API_KEY` set in the environment (used as a Bearer token).
- Network access to `https://ollama.com` at Pi startup.

Failure handling: a single model whose `/api/show` call fails is skipped, never
fatal. If `/v1/models` itself is unreachable the provider registers empty —
Pi's built-in providers are unaffected.

## Validate

```
pi --list-models | grep ollama-cloud
```

or, in an interactive session: `/reload`, then `/model` and search
`ollama-cloud`. This exercises the real code path (Node fetch + provider
registration) and shows exactly which models registered and with what metadata.

## Scope models for Ctrl+P cycling

Registration ≠ scoping. The extension makes models *available*; the
scoped-models list controls which ones Ctrl+P cycles. `enabledModels` is matched
with glob patterns against `provider/id`, so no enumeration is needed. In
`~/.pi/agent/settings.json`:

```json
{ "enabledModels": ["ollama-cloud/glm*", "ollama-cloud/qwen3-coder*", "ollama-cloud/kimi*"] }
```

Or `["ollama-cloud/*"]` to scope all of them, then prune via `/scoped-models`.

## Per-model corrections

To pin metadata for a specific model without touching the extension, add a
`modelOverrides` entry under the `ollama-cloud` provider in `models.json`. Pi
merges overrides onto extension-registered models. Supported fields include
`name`, `reasoning`, `input`, `cost`, `contextWindow`, `maxTokens`, `compat`.

## Possible future enhancements

- **Disk cache** for `/api/show` results (keyed by model id, with a TTL) to skip
  the N+1 fetch on every startup. Deliberately omitted for now — the parallel
  fetch is fast enough and a stale cache would silently serve wrong metadata.
- **`compat` flags** (e.g. `supportsDeveloperRole: false`,
  `supportsReasoningEffort: false`) if a model returns 400s on reasoning params.
