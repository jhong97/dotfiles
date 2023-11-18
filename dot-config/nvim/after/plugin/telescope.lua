local default = require('telescope')
local builtin = require('telescope.builtin')

default.setup{
  defaults = {
		path_display = {
      shorten = {
        "smart",
        len = 3,
        exclude = { 2, -1 } -- to update 
      },
    },
	}
}

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, {})

function LIVE_GREP_FROM_PROJECT_ROOT()
  local git_root = vim.fn.system('git rev-parse --show-toplevel')
  if vim.v.shell_error == 0 then
    git_root = string.gsub(git_root, '\n$', '')
    builtin.live_grep({ cwd = git_root })
  else
    builtin.live_grep()
  end
end

vim.api.nvim_set_keymap('n', '<leader>fs', [[:lua LIVE_GREP_FROM_PROJECT_ROOT()<CR>]], { noremap = true})
