import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

// ---------------------------------------------------------------------------
// Self-populating Ollama Cloud provider
// ---------------------------------------------------------------------------
// Fetches the live model catalog at startup and derives per-model metadata
// from the API so no hand-maintained models.json entry is needed.
// ---------------------------------------------------------------------------

const BASE = "https://ollama.com";
const DEFAULT_CONTEXT_WINDOW = 128_000;
const MAX_OUTPUT_TOKENS = 32_000;
const REQUEST_TIMEOUT_MS = 10_000;

interface OllamaModel {
  id: string;
}

interface ModelShowResponse {
  capabilities?: string[];
  model_info?: Record<string, string | number>;
}

interface ModelsListResponse {
  data: OllamaModel[];
}

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

function authHeaders(): Record<string, string> {
  return { Authorization: `Bearer ${process.env.OLLAMA_API_KEY ?? ""}` };
}

async function fetchJson<T>(url: string, init?: RequestInit): Promise<T> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

  try {
    const res = await fetch(url, {
      ...init,
      headers: { ...authHeaders(), ...init?.headers },
      signal: controller.signal,
    });

    if (!res.ok) {
      throw new Error(`${url} returned HTTP ${res.status}`);
    }

    return (await res.json()) as T;
  } finally {
    clearTimeout(timer);
  }
}

// ---------------------------------------------------------------------------
// extension entry point
// ---------------------------------------------------------------------------

export default async function (pi: ExtensionAPI): Promise<void> {
  // 1. list all cloud models ------------------------------------------------
  let modelsList: ModelsListResponse;

  try {
    modelsList = await fetchJson<ModelsListResponse>(`${BASE}/v1/models`);
  } catch (err) {
    console.warn("ollama-cloud: /v1/models unreachable — provider empty.", err);
    pi.registerProvider("ollama-cloud", {
      baseUrl: `${BASE}/v1`,
      apiKey: "OLLAMA_API_KEY",
      api: "openai-completions",
      models: [],
    });
    return;
  }

  // 2. enrich each model with metadata from /api/show -----------------------
  const models = (
    await Promise.all(
      modelsList.data.map(async ({ id }) => {
        try {
          const show = await fetchJson<ModelShowResponse>(`${BASE}/api/show`, {
            method: "POST",
            body: JSON.stringify({ model: id }),
          });

          const caps: string[] = show.capabilities ?? [];
          if (!caps.includes("tools")) return null; // unusable in agent loop

          const ctxKey = Object.keys(show.model_info ?? {}).find((k) =>
            k.endsWith(".context_length"),
          );
          const contextWindow = ctxKey
            ? Number(show.model_info![ctxKey])
            : DEFAULT_CONTEXT_WINDOW;

          return {
            id,
            name: id,
            reasoning: caps.includes("thinking"),
            input: (
              caps.includes("vision") ? ["text", "image"] : ["text"]
            ) as ("text" | "image")[],
            cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
            contextWindow,
            maxTokens: Math.min(MAX_OUTPUT_TOKENS, Math.floor(contextWindow / 4)),
          };
        } catch (err) {
          console.warn(`ollama-cloud: /api/show failed for "${id}" — skipping.`, err);
          return null;
        }
      }),
    )
  ).filter((m): m is NonNullable<typeof m> => m !== null);

  pi.registerProvider("ollama-cloud", {
    baseUrl: `${BASE}/v1`,
    apiKey: "OLLAMA_API_KEY",
    api: "openai-completions",
    models,
  });
}
