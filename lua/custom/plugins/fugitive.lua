return {
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>gg', ':tab split<CR>:Git<CR>:on<CR>', { desc = 'Open Git fullscreen in tab' })
    end,
  },
}
