require('nvim-treesitter.configs').setup {
  highlight = { enable = true },
  ensure_installed = {
    'ruby',
    'lua'
  }
}
