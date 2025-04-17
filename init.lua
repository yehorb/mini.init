pcall(vim.loader.enable)

-- [[ Setting options ]]
vim.o.number = true

vim.o.undofile = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

vim.o.list = true
vim.o.wrap = false
vim.opt.listchars = {
  eol = "␤",
  tab = "→ ",
  trail = "␠",
  extends = "…",
  precedes = "…",
  conceal = "⬚",
  nbsp = "␣",
}

-- The initial popup menu is mostly used for preview and sanity checks. As I continue
-- typing, fewer options become available, allowing me to either select a completion
-- item or continue typing if I don't see the desired option.
vim.o.completeopt = "menu,menuone,preview,noselect"
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
for _, lower in ipairs { "a", "c", "i", "o", "r" } do
  local upper = lower:upper()
  for _, key in ipairs { lower, upper } do
    vim.keymap.set(
      "n",
      "U" .. key,
      "<Cmd>set iminsert=1 imsearch=1<CR>" .. key,
      { desc = "Turn on :lmap and IM and enter Insert mode" }
    )
  end
end
for _, key in ipairs { "<F4>", "<F5>", "<F6>" } do
  vim.keymap.set({ "i", "c" }, key, "<C-^>", { desc = "Toggle the use of typing language characters" })
end
vim.keymap.set(
  "i",
  "<Esc>",
  "<Esc><Cmd>set iminsert=0 imsearch=0<CR>",
  { desc = "Turn off :lmap and IM when leaving Insert mode" }
)
for _, key in ipairs { "'", "<F10>" } do
  vim.keymap.set({ "i", "c" }, key, function() return vim.o.iminsert == 1 and "<C-^>`" or "'" end, {
    expr = true,
    desc = "Turn off :lmap and IM when starting code blocks. Trigger keys correspond to the backtick charater in IM mode",
  })
end

vim.o.scrolloff = 8
vim.o.sidescrolloff = 8

-- Move the cursor to the first non-blank of the line to avoid erratic cursor movement
vim.o.startofline = true

-- Set <EOL> to <CR> by default
vim.o.fileformat = "unix"
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

-- Saner command-line history - recall the command-line whose beginning matches the current command-line
vim.cmd [[
cnoremap <expr> <c-n> wildmenumode() ? "\<c-n>" : "\<down>"
cnoremap <expr> <c-p> wildmenumode() ? "\<c-p>" : "\<up>"
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

vim.api.nvim_create_autocmd("InsertEnter", {
  group = augroup,
  callback = function(ev)
    -- Defer the execution to allow *lsp-defaults* to set omnifunc, if available
    vim.defer_fn(function()
      if vim.fn.bufexists(ev.buf) ~= 1 then return end
      if vim.bo[ev.buf].omnifunc == "" then vim.bo[ev.buf].omnifunc = "syntaxcomplete#Complete" end
    end, 0)
  end,
  desc = "Set *ft-syntax-omni* omnifunc",
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  pattern = "quickfix",
  callback = function() vim.wo.wrap = false end,
})

local filetype = {
  prose = { "markdown", "tex" },
}

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = filetype.prose,
  callback = function() vim.cmd.runtime "after/ftplugin/prose.lua" end,
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
require("lazy").setup({
  -- add your plugins here
  -- [[ Step one - load plugins with UI necessary to make initial screen draw ]]
  {
    "shaunsingh/nord.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- load the colorscheme here
      vim.g.nord_contrast = true
      vim.g.nord_uniform_diff_background = true
      vim.g.nord_italic = true
      vim.g.nord_bold = true

      require("nord").set()
      vim.cmd [[highlight! link Whitespace DiagnosticError]] -- Highlight nonprinting characters
    end,
  },
  {
    "AlexvZyl/nordic.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      require("nordic").load()
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

      -- Setup similar to 'tpope/vim-surround'
      require("mini.surround").setup {
        mappings = {
          add = "ys",
          delete = "ds",
          replace = "cs",
        },
        search_method = "cover_or_next",
      }
      -- Remap adding surrounding to Visual mode selection
      vim.keymap.del("x", "ys")
      vim.keymap.set("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
      -- Make special mapping for "add surrounding for line"
      vim.keymap.set("n", "yss", "ys_", { remap = true })

      require("mini.statusline").setup { use_icons = false }
      local latex_patterns = { "latex/**/*.json", "**/latex.json" }
      local lang_patterns = { tex = latex_patterns, plaintex = latex_patterns }
      local gen_loader = require("mini.snippets").gen_loader
      require("mini.snippets").setup {
        snippets = {
          gen_loader.from_lang { lang_patterns = lang_patterns },
        },
        mappings = { expand = "", jump_next = "<C-l>", jump_prev = "<C-h>" },
      }
      vim.api.nvim_create_autocmd("InsertLeave", {
        group = augroup,
        callback = function() MiniSnippets.session.stop() end,
      })
    end,
    event = "VeryLazy",
  },

  { "nvim-treesitter/nvim-treesitter-textobjects", lazy = true },
  { "nvim-treesitter/playground", lazy = true },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
      textobjects = {
        select = {
          enable = true,
          keymaps = {
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
          },
        },
      },
      highlight = {
        enable = true,
        disable = {
          "latex",
          "markdown",
          "markdown_inline",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.install").prefer_git = false
      require("nvim-treesitter.configs").setup(opts)
    end,
    build = function()
      local install = require "nvim-treesitter.install"
      local shell = require "nvim-treesitter.shell_command_selectors"
      local cc = shell.select_executable(install.compilers)
      if not cc then
        vim.api.nvim_echo({ { "No C compiler found!" } }, false, { err = true })
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
        registries = {
          "github:mason-org/mason-registry",
          "file:" .. path.concat { vim.fn.fnamemodify(vim.env.MYVIMRC, ":h"), "mason" },
        },
      }
      require("mason-lspconfig").setup()

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
        silent = true,
      })

      local on_attach = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client == nil then return end

        client.flags.debounce_text_changes = 500

        vim.keymap.set(
          "n",
          "<Leader>la",
          function() vim.lsp.buf.code_action() end,
          { buffer = ev.buf, desc = "[L]SP: Code [A]ction" }
        )

        if client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
          local hl_group = vim.api.nvim_create_augroup("vimrc-lsp-hl", { clear = true })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = ev.buf,
            group = hl_group,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = ev.buf,
            group = hl_group,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd("LspDetach", {
            group = hl_group,
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = "vimrc-lsp-hl", buffer = event2.buf }
            end,
          })
        end

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
        client.capabilities = capabilities

        -- Disable duplicate diagnostics from verible
        -- https://github.com/neovim/neovim/issues/29927
        -- if client.name == "verible" then client.server_capabilities.diagnosticProvider = nil end
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = augroup,
        callback = on_attach,
      })

      -- root_dir is evil now
      -- If a function, it is passed the buffer number and a callback argument which must be called with the value of root_dir to use.
      -- **The LSP server will not be started until the callback is called.**
      vim.lsp.config("lua_ls", {
        -- The default `root_dir` checks for Lua configuration files, the presence of the `lua/`
        -- directory, and only then for the `.git` directory. It finds my `Projects` directory
        -- before locating the actual project root, as I have a `lua/` directory for all my
        -- Lua projects. I find that only looking for the `.git` directory is more consistent.
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
      })
      vim.lsp.enable "lua_ls"
      vim.lsp.enable "basedpyright"
      vim.lsp.enable "ruff"
      vim.lsp.config("ltex", {
        cmd = { "ltex-ls-plus" },
      })
      vim.lsp.enable "ltex"
      vim.lsp.config("verible", {
        cmd = { "verible-verilog-ls", "--rules_config_search", "--indentation_spaces=4" },
        root_markers = { "verible.filelist", ".git" },
      })
      vim.lsp.enable "verible"
      vim.lsp.config("nixd", {
        settings = {
          nixd = {
            formatting = {
              command = { "nixfmt" },
            },
          },
        },
      })
      vim.lsp.enable "nixd"
      vim.lsp.enable "harper_ls"
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
        nix = { lsp_format = "prefer" },
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
  { "preservim/vim-pencil", enabled = false, ft = filetype.prose },

  { "nvim-lua/plenary.nvim", lazy = true },
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
        local id_date = string.match(note.id, "^[0-9]*")
        if #id_date > 0 then note:add_alias(id_date) end

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
      ui = {
        enable = false,
        checkboxes = {
          [" "] = { char = "📫", hl_group = "ObsidianTodo" }, -- closed mailbox with raised flag
          ["x"] = { char = "✅", hl_group = "ObsidianDone" }, -- check mark button
          ["!"] = { char = "❗", hl_group = "ObsidianImportant" }, -- exclamation mark
          ["?"] = { char = "❓", hl_group = "ObsidianImportant" }, -- question mark
        },
        external_link_icon = { char = "🕊", hl_group = "ObsidianExtLinkIcon" }, -- dove
      },
    },
    event = {
      "BufReadPre " .. vim.fs.normalize "~/Documents/Obsidian Vault" .. "/*.md",
      "BufNewFile " .. vim.fs.normalize "~/Documents/Obsidian Vault" .. "/*.md",
    },
    keys = {
      { "<Leader>on", "<Cmd>ObsidianNew<CR>" },
      { "<Leader>og", ":grep -g !.git -g !.obsidian -g '!04 - Archive' " },
    },
    version = "*", -- recommended, use latest release instead of latest commit
  },

  {
    "lervag/vimtex",
    lazy = false,
  },

  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer", enabled = false },
      { url = "https://codeberg.org/FelipeLema/cmp-async-path.git" },
      { "abeldekat/cmp-mini-snippets" },
    },
    opts = function()
      local cmp = require "cmp"
      return {
        snippet = {
          expand = function(args)
            local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
            insert { body = args.body } -- Insert at cursor
            cmp.resubscribe { "TextChangedI", "TextChangedP" }
            require("cmp.config").set_onetime { sources = {} }
          end,
        },
        completion = {
          completeopt = vim.o.completeopt,
        },
        mapping = {
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-y>"] = cmp.mapping.confirm { select = true },
        },
        sources = {
          {
            name = "lazydev",
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = "nvim_lsp" },
          { name = "mini_snippets" },
          { name = "async_path" },
        },
      }
    end,
  },
  { "rafamadriz/friendly-snippets" },

  { "stevearc/dressing.nvim", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },
  { "ibhagwan/fzf-lua", lazy = true },
  {
    "zbirenbaum/copilot.lua",
    lazy = true,
    opts = {},
  },
  {
    "yetone/avante.nvim",
    lazy = true,
    version = false,
    opts = {
      provider = "copilot",
    },
    build = vim.uv.os_uname().version:match "Windows"
        and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
  },

  {
    enabled = false,
    "jmbuhr/otter.nvim",
    opts = {
      buffers = {
        set_filetype = true,
        write_to_disk = true,
      },
    },
  },
}, {
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
})

-- vim: ts=2 sts=2 sw=2 et
