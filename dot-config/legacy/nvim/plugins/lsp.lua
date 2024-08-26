local servers = {
  'lua_ls',
  'solargraph',
  'pyright',
  'tsserver',
  'golangci_lint_ls',
  'bashls',
  'rust_analyzer'
}

require('mason').setup()
require('mason-lspconfig').setup{
  ensure_installed = servers
}

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require('lspconfig')

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
  }
end

lspconfig.lua_ls.setup{
  settings = {
    Lua = {
      diagnostics = {
        globals = {
          'vim'
        }
      }
    }
  }
}

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}
