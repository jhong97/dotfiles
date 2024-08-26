local is_ruby_file = function()
  return vim.fn.expand('%:e') == 'rb'
end

if is_ruby_file() then
  vim.g.splitjoin_join_mapping = ''
  vim.g.splitjoin_split_mapping = ''
  vim.g.splitjoin_ruby_hanging_args = 0

  -- Remaps for gb and gB mnemonic for block
  vim.api.nvim_set_keymap('n', 'gB', [[:SplitjoinJoin<CR>]], { noremap = false, silent = true })
  vim.api.nvim_set_keymap('n', 'gb', [[:SplitjoinSplit<CR>]], {
    noremap = false,
    silent = true,
  })
end
