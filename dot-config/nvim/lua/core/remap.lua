vim.g.mapleader = " "

-- freeing up the <C-a> by reassigning increment and decrement
vim.keymap.set("n", "+", "<C-a>")
vim.keymap.set("n", "-", "<C-x>")

-- selecting everything in file
vim.keymap.set("n", "<C-a>", "gg<S-v>G")

-- for netrw
--vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- for everything window
-- ie <leader>wv for vertical, <leader>ws for split
vim.keymap.set("n", "<leader>w", "<C-w>")

-- for redoing
vim.keymap.set("n", "<leader>r", "<C-r>")

-- for copying to clipboard to paste outside of vim
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")

-- Enable nvim tree shortcut
--vim.keymap.set("n", "<leader>f<leader>", vim.cmd.NvimTreeToggle)
--vim.api.nvim_set_keymap('n', '<leader>cd', [[:cd %:h <CR>]], { noremap = true })

-- Active File Directory expansion
vim.cmd[[cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%']]

