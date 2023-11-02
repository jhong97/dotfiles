local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', telescope.find_files, {})
vim.keymap.set('n', '<leader>fl', telescope.live_grep, {})
vim.keymap.set('n', '<leader>fg', telescope.git_files, {})
vim.keymap.set('n', '<leader>fs', function()
	telescope.grep_string({ search = vim.fn.input("🔍 grep > ") })
end)
vim.keymap.set('n', '<leader>fo', telescope.oldfiles, {})

function LIVE_GREP_FROM_PROJECT_ROOT()
  local git_root = vim.fn.system('give rev-parse --show-toplevel')
  if vim.v.shell_error == 0 then
    git_root = string.gsub(git_root, '\n$', '')
    telescope.live_grep({ cwd = git_root })
  else
    telescope.live_grep()
  end
end

vim.api.nvim_set_keymap('n', '<leader>fg', [[:lua LIVE_GREP_FROM_PROJECT_ROOT()<CR>]], { noremap = true})




