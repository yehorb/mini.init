pcall(vim.loader.enable)

-- [[ Setting options ]]
vim.o.number = true

vim.o.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.o.list = true
vim.opt.listchars = { eol = "␤", tab = "→ ", trail = "␠", nbsp = "␣" }

-- The initial popup menu is mostly used for preview and sanity checks. As I continue
-- typing, fewer options become available, allowing me to either select a completion
-- item or continue typing if I don't see the desired option.
vim.o.completeopt = "menuone,preview,noselect"
-- Limit the height of the popup menu.
vim.o.pumheight = 15

-- The default value `auto` causes signcolumn to flicker during analysis.
vim.o.signcolumn = "yes"

if vim.uv.os_uname().version:match "Windows" then
  vim.cmd [[
  let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
  let &shellcmdflag = '-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues[''Out-File:Encoding'']=''utf8'';Remove-Alias -Force -ErrorAction SilentlyContinue tee;'
  let &shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
  let &shellpipe  = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
  set shellquote= shellxquote=
  ]]
end

-- Switch to Ukrainian using *i_CTRL-^*
vim.o.keymap = "ukrainian-jcuken"
vim.o.iminsert = 0
vim.o.imsearch = 0
vim.keymap.set(
  "n",
  "<F6>",
  "<Cmd>set iminsert=1 imsearch=1 <Bar> startinsert<CR>",
  { desc = "Turn on :lmap and IM and enter Insert mode" }
)
vim.keymap.set({ "i", "c" }, "<F6>", "<C-^>", { desc = "Toggle the use of typing language characters" })
vim.keymap.set(
  { "i", "c" },
  "<Esc>",
  "<Esc><Cmd>set iminsert=0 imsearch=0<CR>",
  { desc = "Turn off :lmap and IM when leaving Insert mode" }
)

vim.o.scrolloff = 8
vim.o.sidescrolloff = 8

-- Move the cursor to the first non-blank of the line to avoid erratic cursor movement
vim.o.startofline = true

-- Set <EOL> to <CR> by default
vim.opt.fileformat = "unix"
-- Allow the detection of <CR><LF> <EOL>
vim.opt.fileformats = { "unix", "dos" }

-- [[ Basic Keymaps ]]
-- Keybinds to make split navigation easier.
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })

vim.keymap.set({ "n", "v" }, "Y", '"+y', { desc = "Yank into the OS clipboard" })
vim.keymap.set({ "n", "v" }, "+", '"+p', { desc = "Paste form the OS clipboard" })

vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR><Esc>", { desc = "Clear 'hlsearch' using <Esc>" })

-- Builtin search tools
vim.opt.path:append "**"
vim.keymap.set("n", "<C-b>", ":buffer ", { desc = "Invoke the buffer search" })
vim.keymap.set("n", "<C-p>", ":find ", { desc = "Invoke the file search" })

-- Make * and # stay on the current word.
vim.cmd [[
nmap <silent> * <Cmd>let @/='\<'.expand('<cword>').'\>' <Bar> set hlsearch<CR>
nmap <silent> # <Cmd>let @/='\<'.expand('<cword>').'\>' <Bar> set hlsearch<CR>
]]

-- [[ Basic Autocommands ]]
-- Nvim will always call a Lua function with a single table containing information
-- about the triggered autocommand. This means that if your callback itself takes
-- an (even optional) argument, you must wrap it in `function() end` to avoid an error.
local augroup = vim.api.nvim_create_augroup("vimrc", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function() vim.highlight.on_yank() end,
  desc = "Briefly highlight yanked text",
})

vim.api.nvim_create_autocmd("Filetype", {
  group = augroup,
  callback = function(ev)
    -- Defer the execution to allow *lsp-defaults* to set omnifunc, if available
    vim.defer_fn(function()
      if vim.fn.bufexists(ev.buf) ~= 1 then return end
      if vim.bo[ev.buf].omnifunc == "" then vim.bo[ev.buf].omnifunc = "syntaxcomplete#Complete" end
    end, 1000)
  end,
  desc = "Set *ft-syntax-omni* omnifunc",
})

-- [[ Install lazy.nvim plugin manager ]]
-- mini.deps plugin manager provides simpler and more explicit plugin management. Manually managing the complexity of
-- loading modules in the correct order and at the right time is certainly not for everyone, but it may be easier to
-- reason about and build upon.
--
-- mini.deps benefits - full control over the load order, help is always loaded, managing mini.nvim specifically is
-- easier with `now()` and `later()` to load different modules independently.
--
-- mini.deps drawbacks - sequential install, minimalistic UI and UX, `later()` unintuitive interaction with
-- autocommands.
--
-- I want to try and reproduce mini.deps benefits with more focused lazy.nvim configuration.
--
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Setup lazy.nvim
require("lazy").setup {
  spec = {
    -- add your plugins here
    -- [[ Step one - load plugins with UI necessary to make initial screen draw ]]
    {
      "shaunsingh/nord.nvim",
      lazy = false, -- make sure we load this during startup if it is your main colorscheme
      priority = 1000, -- make sure to load this before all the other start plugins
      config = function()
        -- load the colorscheme here
        vim.cmd [[colorscheme nord]]
        vim.cmd [[highlight! link Whitespace DiagnosticError]] -- Highlight nonprinting characters
      end,
    },
    -- [[ Step two - load other plugins ]]
    { "tpope/vim-unimpaired", event = "VeryLazy" },

    {
      "echasnovski/mini.nvim",
      config = function()
        require("mini.diff").setup()
        require("mini.git").setup()
        require("mini.ai").setup { n_lines = 500 }
        require("mini.surround").setup()
        require("mini.statusline").setup { use_icons = false }
      end,
      event = "VeryLazy",
    },

    { "nvim-treesitter/nvim-treesitter-textobjects", lazy = true },
    { "nvim-treesitter/playground", lazy = true },
    {
      "nvim-treesitter/nvim-treesitter",
      config = function()
        require("nvim-treesitter.install").prefer_git = false
        require("nvim-treesitter.configs").setup { ---@diagnostic disable-line:missing-fields
          ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
          textobjects = {
            select = {
              enable = true,
              keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
              },
            },
          },
        }
      end,
      build = function()
        local install = require "nvim-treesitter.install"
        local shell = require "nvim-treesitter.shell_command_selectors"
        local cc = shell.select_executable(install.compilers)
        if not cc then
          vim.api.nvim_err_writeln "No C compiler found!"
          return
        end
        vim.cmd [[TSUpdate]]
      end,
      event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
    },

    { "j-hui/fidget.nvim", opts = {}, event = "VeryLazy" },
    { "williamboman/mason-lspconfig.nvim", lazy = true },
    { "williamboman/mason.nvim", lazy = true },
    {
      "neovim/nvim-lspconfig",
      config = function()
        local path = require "mason-core.path"
        require("mason").setup {
          install_root_dir = path.concat { vim.env.USERPROFILE or vim.env.HOME, "Tools", "mason" },
        }
        require("mason-lspconfig").setup()

        local lspconfig = require "lspconfig"
        lspconfig.lua_ls.setup {
          -- The default `root_dir` checks for Lua configuration files, the presence of the `lua/`
          -- directory, and only then for the `.git` directory. It finds my `Projects` directory
          -- before locating the actual project root, as I have a `lua/` directory for all my
          -- Lua projects. I find that only looking for the `.git` directory is more consistent.
          root_dir = lspconfig.util.find_git_ancestor,
          settings = {
            Lua = {
              runtime = {
                version = "LuaJIT",
                path = vim.split(package.path, ";"),
              },
              workspace = {
                checkThirdParty = false,
                library = { vim.env.VIMRUNTIME },
              },
              telemetry = {
                enable = false,
              },
            },
          },
        }
        lspconfig.basedpyright.setup {}
        lspconfig.ruff_lsp.setup {}
      end,
      event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
    },
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "luvit-meta/library", words = { "vim%.uv" } },
        },
      },
    },
    { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings

    {
      "stevearc/conform.nvim",
      opts = {
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "black" },
          hcl = { "terragrunt_hclfmt" },
        },
        format_on_save = {},
      },
      event = "VeryLazy",
    },

    {
      "stevearc/oil.nvim",
      opts = {
        view_options = {
          show_hidden = true,
        },
      },
      event = "VeryLazy",
      keys = {
        { "-", "<Cmd>Oil<CR>", desc = "Open parent directory" },
      },
    },

    {
      "folke/zen-mode.nvim",
      opts = {
        plugins = {
          options = {
            ruler = true,
            laststatus = 3,
          },
          twilight = { enabled = false },
        },
      },
      event = "VeryLazy",
      keys = {
        { "<C-w>z", function() require("zen-mode").toggle() end, desc = "Toggle *Zen Mode*" },
        { "<C-z>", function() require("zen-mode").toggle() end, desc = "Toggle *Zen Mode*" },
      },
    },
    { "folke/twilight.nvim", lazy = true },

    {
      "m4xshen/hardtime.nvim",
      enabled = false,
      opts = {},
    },
    { "MunifTanjim/nui.nvim", lazy = true },
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
}

-- vim: ts=2 sts=2 sw=2 et
