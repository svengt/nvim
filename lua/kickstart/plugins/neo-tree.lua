-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

local function grep_at(state, include_ignored)
  local node = state.tree:get_node()
  while node and node.type ~= 'directory' do
    local parent_id = node:get_parent_id()
    node = parent_id and state.tree:get_node(parent_id) or nil
  end

  if not node then
    return
  end

  local path = node:get_id()
  require('telescope.builtin').live_grep {
    search_dirs = { path },
    prompt_title = string.format('Grep in [%s]', vim.fs.basename(path)),
    additional_args = include_ignored and { '-u' } or {},
  }
end

local function find_files_at(state, include_ignored)
  local node = state.tree:get_node()
  while node and node.type ~= 'directory' do
    local parent_id = node:get_parent_id()
    node = parent_id and state.tree:get_node(parent_id) or nil
  end

  if not node then
    return
  end

  local path = node:get_id()
  require('telescope.builtin').find_files {
    cwd = path,
    no_ignore = include_ignored,
    prompt_title = string.format('Search files in [%s]', vim.fs.basename(path)),
  }
end

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '<c-\\>', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
      },
      window = {
        mappings = {
          ['<c-\\>'] = 'close_window',
          ['<space>'] = '',
          ['<space>g'] = 'grep_at',
          ['<space>G'] = 'grep_at_ignored',
          ['<space>f'] = 'find_files_at',
          ['<space>F'] = 'find_files_at_ignored',
        },
      },
      commands = {
        grep_at = function(state)
          grep_at(state, false)
        end,
        grep_at_ignored = function(state)
          grep_at(state, true)
        end,
        find_files_at = function(state)
          find_files_at(state, false)
        end,
        find_files_at_ignored = function(state)
          find_files_at(state, true)
        end,
      },
    },
  },
}
