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
for _, key in ipairs { "O", "a", "c", "i", "o", "r" } do
  vim.keymap.set(
    "n",
    "U" .. key,
    "<Cmd>set iminsert=1 imsearch=1<CR>" .. key,
    { desc = "Turn on :lmap and IM and enter Insert mode" }
  )
end
vim.keymap.set({ "i", "c" }, "<F6>", "<C-^>", { desc = "Toggle the use of typing language characters" })
vim.keymap.set(
  "i",
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

-- Keybinds to make navigation easier when lines wrap
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })

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

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  callback = function(ev)
    -- Defer the execution to allow *lsp-defaults* to set omnifunc, if available
    vim.defer_fn(function()
      if vim.fn.bufexists(ev.buf) ~= 1 then return end
      if #vim.lsp.get_clients() > 0 then return end
      if vim.bo[ev.buf].omnifunc == "" then vim.bo[ev.buf].omnifunc = "syntaxcomplete#Complete" end
    end, 1000)
  end,
  desc = "Set *ft-syntax-omni* omnifunc",
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  pattern = "quickfix",
  callback = function() vim.opt_local.wrap = false end,
})

-- Custom filetype prose-oriented file types
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "markdown" },
  callback = function() vim.api.nvim_exec_autocmds("FileType", { pattern = "prose" }) end,
})

-- Make the lowest line stay at least g:scrolloff lines from the bottom of the screen
-- inspired by https://github.com/Aasim-A/scrollEOF.nvim
vim.g.scrolloff = 8
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "WinScrolled" }, {
  group = augroup,
  callback = function()
    local win_height = vim.fn.winheight(0)
    local win_view = vim.fn.winsaveview()
    local actual_scrolloff = win_view.topline + win_height - win_view.lnum - 1
    if actual_scrolloff > vim.g.scrolloff then return end
    -- solve for win_view.topline from equation above
    vim.fn.winrestview { topline = vim.g.scrolloff - win_height + win_view.lnum + 1 }
  end,
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
                library = { vim.env.VIMRUNTIME, vim.fn.stdpath "data" .. "/lazy" },
              },
              telemetry = {
                enable = false,
              },
            },
          },
        }
        lspconfig.basedpyright.setup {}
        lspconfig.ruff_lsp.setup {}
        lspconfig.marksman.setup {}
        lspconfig.ltex.setup {}
        lspconfig.verible.setup {
          root_dir = lspconfig.util.root_pattern { "verible.filelist", ".git" },
        }
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
      init = function()
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
      end,
      opts = {
        default_file_explorer = true,
        view_options = {
          show_hidden = true,
        },
        keymaps = {
          ["<C-h>"] = false,
          ["<C-l>"] = false,
          ["<C-p>"] = false,
        },
      },
      event = "VeryLazy",
      keys = {
        { "-", "<Cmd>Oil<CR>", desc = "Open parent directory" },
      },
    },

    { "shortcuts/no-neck-pain.nvim", version = "*", event = "VeryLazy" },
    { "preservim/vim-pencil", ft = "prose" },

    {
      "epwalsh/obsidian.nvim",
      opts = {
        workspaces = {
          {
            name = "Vault",
            path = vim.fs.normalize "~/Documents/Obsidian Vault",
          },
        },
        notes_subdir = "00 - Inbox",
        new_notes_location = "notes_subdir",
        ---@param title string|?
        ---@return string
        note_id_func = function(title)
          local suffix = ""
          if title ~= nil then
            suffix = title:gsub("[^A-Za-z0-9- ]", "")
          else
            for _ = 1, 4 do
              suffix = suffix .. string.char(math.random(65, 90))
            end
          end
          return tostring(os.date "%Y%m%d%H%M%S") .. " " .. suffix
        end,
        ---@param note obsidian.Note
        note_frontmatter_func = function(note)
          -- Add the title of the note as an alias.
          if note.title then note:add_alias(note.title) end
          -- Add the date of the note as an alias.
          note:add_alias(string.match(note.id, "^[0-9]*"))

          local out = { id = note.id, aliases = note.aliases, tags = note.tags }

          -- `note.metadata` contains any manually added fields in the frontmatter.
          -- So here we just make sure those fields are kept in the frontmatter.
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end

          return out
        end,
        wiki_link_func = "use_alias_only",
        picker = false,
      },
      event = {
        "BufReadPre " .. vim.fs.normalize "~/Documents/Obsidian Vault" .. "/*.md",
        "BufNewFile " .. vim.fs.normalize "~/Documents/Obsidian Vault" .. "/*.md",
      },
      keys = {
        { "<Leader>on", "<Cmd>ObsidianNew<CR>" },
      },
      version = "*", -- recommended, use latest release instead of latest commit
    },

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
