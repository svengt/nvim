local function create_interactive_command(command, opts)
  opts = opts or {}
  local buf = vim.api.nvim_create_buf(false, true)

  -- Execute command and capture output
  local output = vim.fn.execute(command)
  local lines = vim.split(output, '\n')

  -- Put the output in the buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Create floating window
  local width = math.min(vim.o.columns - 4, math.max(80, vim.o.columns - 20))
  local height = math.min(vim.o.lines - 4, math.max(20, vim.o.lines - 10))
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win_opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  }
  vim.api.nvim_open_win(buf, true, win_opts)

  -- Set buffer options
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe' -- This will delete the buffer when it's hidden

  -- Buffer local mappings
  vim.keymap.set('n', 'q', ':close<CR>', {
    buffer = buf,
    noremap = true,
    silent = true,
  })

  -- Set buffer name if provided
  if opts.name then
    vim.api.nvim_buf_set_name(buf, opts.name)
  end
end

return {
  {
    'tpope/vim-fugitive',
    config = function()
      vim.keymap.set('n', '<leader>gg', ':tab split<CR>:Git<CR>:on<CR>', { desc = 'Open Git fullscreen in tab' })
      vim.keymap.set('n', '<leader>gp', function()
        create_interactive_command('Git push', {
          name = '[Git Push Output]',
        })
      end, { desc = 'Git push' })
      vim.keymap.set('n', '<leader>gP', function()
        create_interactive_command('Git push --force-with-lease', {
          name = '[Git Push Output]',
        })
      end, { desc = 'Git push --force-with-lease' })
      vim.keymap.set('n', '<leader>gu', function()
        vim.ui.input({
          prompt = 'Branch name: ',
          default = vim.fn.FugitiveHead(), -- Current branch as default
        }, function(branch)
          if branch then -- Only if user didn't cancel
            create_interactive_command(string.format('Git push --set-upstream origin %s', branch), { name = '[Git Push Upstream]' })
          end
        end)
      end, { desc = 'Git push --set-upstream' })
    end,
  },
}
