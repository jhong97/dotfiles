vim.g.mapleader = " "

-- for netrw
--vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- for everything window
vim.keymap.set("n", "<leader>w", "<C-w>")

-- for redoing
vim.keymap.set("n", "<leader>r", "<C-r>")

-- for copying to clipboard to paste outside of vim
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")

-- Enable nvim tree shortcut
vim.keymap.set("n", "<leader>f<leader>", vim.cmd.NvimTreeToggle)

-- Active File Directory expansion
vim.cmd[[cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%']]
