pcall(vim.loader.enable)

-- [[ Setting options ]]
vim.o.list = true
vim.opt.listchars = { eol = "␤", tab = "→ ", trail = "␠", nbsp = "␣" }

-- The initial popup menu is mostly used for preview and sanity checks. As I continue
-- typing, fewer options become available, allowing me to either select a completion
-- item or continue typing if I don't see the desired option.
vim.o.completeopt = 'menuone,preview,noselect'

-- The default value `auto` causes signcolumn to flicker during analysis.
vim.o.signcolumn = 'yes'

if vim.uv.os_uname().version:match 'Windows' then
  vim.cmd [[
  let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
  let &shellcmdflag = '-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';Remove-Alias -Force -ErrorAction SilentlyContinue tee;'
  let &shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  let &shellpipe  = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
  set shellquote= shellxquote=
  ]]
end

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
-- I prefer 'mini.deps' over 'lazy.nvim'. I find the simpler and more explicit plugin management
-- provided by 'mini.deps' to be more enjoyable to work with. Manually managing the complexity of
-- loading modules in the correct order and at the right time is certainly not for everyone, but I
-- find it much easier to reason about and build upon.
-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.uv.fs_stat(mini_path) then
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

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- [[ Step one - load plugins with UI necessary to make initial screen draw ]]
now(function()
  add 'shaunsingh/nord.nvim'
  vim.cmd 'colorscheme nord'
  vim.cmd 'highlight! link Whitespace DiagnosticError' -- Highlight nonprinting characters
end)

-- [[ Step two - load other plugins ]]
-- `MiniDeps.later()` schedules code to be safely executed later.
-- `later(function() require(...).setup() end)` correctly postpones module loading.
-- `later(require(...).setup)` does not postpone module loading, but only postpones `setup()`.
later(function() require('mini.diff').setup() end)
later(function() require('mini.git').setup() end)

later(function()
  add('neovim/nvim-lspconfig')
  local lspconfig = require('lspconfig')
  lspconfig.lua_ls.setup {
    -- The default `root_dir` checks for Lua configuration files, the presence of the `lua/`
    -- directory, and only then for the `.git` directory. It finds my `Projects` directory
    -- before locating the actual project root, as I have a `lua/` directory for all my
    -- Lua projects. I find that only looking for the `.git` directory is more consistent.
    root_dir = lspconfig.util.find_git_ancestor,
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          path = vim.split(package.path, ';'),
        },
        workspace = {
          checkThirdParty = false,
          library = { vim.env.VIMRUNTIME }
        },
        telemetry = {
          enable = false,
        },
      },
    },
  }
  -- Manually trigger `lspconfig` autocommands, as `later()` defers `lspconfig.server.setup()`.
  -- If not triggered, an LSP client will not automatically attach to a buffer.
  vim.cmd 'doautocmd lspconfig FileType'
end)

-- vim: ts=2 sts=2 sw=2 et
