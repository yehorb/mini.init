pcall(vim.loader.enable)

-- [[ Basic Keymaps ]]
-- Keybinds to make split navigation easier.
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })

vim.keymap.set({ 'n', 'v' }, 'Y', '"+y', { desc = 'Yank into the OS clipboard' })

-- [[ Basic Autocommands ]]
-- Nvim will always call a Lua function with a single table containing information
-- about the triggered autocommand. This means that if your callback itself takes
-- an (even optional) argument, you must wrap it in `function() end` to avoid an error.
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('vimrc', { clear = true }),
  callback = function() vim.highlight.on_yank() end,
  desc = 'Briefly highlight yanked text',
})

-- [[ Install 'mini.deps' plugin manager ]]
-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/echasnovski/mini.nvim', mini_path
  }
  vim.fn.system(clone_cmd)
  vim.cmd('packadd mini.nvim | helptags ALL')
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require('mini.deps').setup({ path = { package = path_package } })

add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- [[ Step one - load plugins with UI necessary to make initial screen draw ]]
now(function()
  add 'shaunsingh/nord.nvim'
  vim.cmd 'colorscheme nord'
end)

-- [[ Step two - load other plugins ]]
-- `MiniDeps.later()` schedules code to be safely executed later.
-- `later(function() require(...).setup() end)` correctly postpones module loading.
-- `later(require(...).setup)` does not postpone module loading, but only postpones `setup()`.
later(function() require('mini.diff').setup() end)
later(function() require('mini.git').setup() end)

-- vim: ts=2 sts=2 sw=2 et
