-- Disable Netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

local function my_on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)

  -- custom remaps
  vim.keymap.set('n', '<leader>cd', api.tree.change_root_to_node, opts('CD'))
  vim.keymap.set('n', '<leader>..', api.tree.change_root_to_parent, opts('Up'))
end

-- empty setup using defaults
require("nvim-tree").setup{
  live_filter = {
    prefix = "[FILTER]: ",
    always_show_folders = false,
  },
  on_attach = my_on_attach,
  update_focused_file = {
    enable = true,
  }
}

