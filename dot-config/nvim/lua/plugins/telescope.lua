return {
  'nvim-telescope/telescope.nvim',
  lazy = true,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'BurntSushi/ripgrep',
    'sharkdp/fd',
    'nvim-tree/nvim-web-devicons',
    'nvim-telescope/telescope-fzf-native.nvim',
  },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files"},
    { "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find files tracked by git"},
    { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Find in previous files"},
  },
  init = function()
    defaults = {
      path_display = {
        shorten = {
          "smart",
          len = 3,
          exclude = { 2, -1 }
        }
      }
    }
  end,
}


