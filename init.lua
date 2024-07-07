-- [[ Install `mini.nvim` ]]
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

local add, now = MiniDeps.add, MiniDeps.now

-- [[ Basic options ]]

now(function()
  vim.g.mapleader = " "
  vim.g.maplocalleader = "\\"

  vim.o.list = true
  vim.opt.listchars = { eol = "␤", tab = "→ ", trail = "␠", nbsp = "␣" }

  vim.o.linebreak = true
  vim.o.breakindent = true
  vim.o.showbreak = "␂"

  vim.o.number = true
  vim.o.relativenumber = true

  vim.o.shiftwidth = 4
  vim.o.tabstop = 4
  vim.o.expandtab = true

  vim.o.ignorecase = true
  vim.o.smartcase = true

  vim.o.scrolloff = 4

  vim.cmd([[filetype plugin indent on]])
end)

-- [[ Basic keymaps ]]

now(function()
  vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
  vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

  vim.keymap.set("n", "<Esc>", "<Cmd>noh<CR><Esc>", { desc = "Escape and clear hlsearch" })

  vim.keymap.set("n", "vv", "<C-v>", { desc = "Enter blockwise Visual mode" })
end)

-- [[ Colorscheme ]]

now(function()
  add("folke/tokyonight.nvim")
  vim.cmd([[colorscheme tokyonight]])
end)

-- [[ Lazy loading plugins ]]

local augroup = vim.api.nvim_create_augroup("Init", {})

vim.api.nvim_create_autocmd("InsertEnter", {
  group=augroup,
  callback=function()
    add("max397574/better-escape.nvim")
    require("better_escape").setup()
  end
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWritePre" }, {
  group=augroup,
  callback=function()
    require("mini.diff").setup()
    require("mini.git").setup()
    require("mini.files").setup {
      mappings = {
        go_in       = 'L',
        go_in_plus  = 'l',
        go_out      = 'H',
        go_out_plus = 'h',
      }
    }
    vim.keymap.set("n", "-", function()
      MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
      MiniFiles.reveal_cwd()
    end)
  end
})

-- vim: ts=2 sts=2 sw=2 et
