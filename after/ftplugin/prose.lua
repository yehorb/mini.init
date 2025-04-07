local M = {}

function M.init()
  M.micropencil()

  vim.wo.spell = true
  vim.bo.spelllang = "uk,en_us,en_gb" -- Using en spelllang slows down suggestions immensely

  vim.wo.list = true

  vim.o.laststatus = 3 -- Show single saturnine for all windows. Makes focused pane look better

  vim.bo.expandtab = true
  vim.bo.tabstop = 2
  vim.bo.shiftwidth = 2
end

function M.micropencil()
  vim.cmd [[
    setl textwidth=0
    setl wrap
    setl linebreak
    setl breakat-=*         " avoid breaking footnote*
    setl breakat-=@         " avoid breaking at email addresses
    setl colorcolumn=0      " doesn't align as expected
    setl breakindent
    setl display+=lastline
    setl backspace=indent,eol,start

    setl whichwrap+=<,>,b,s,h,l,[,]
    aug pencil_cursorwrap
        au BufEnter <buffer> set virtualedit+=onemore
        au BufLeave <buffer> set virtualedit-=onemore
    aug END

    setl wrapmargin=0
    setl autoindent         " needed by formatoptions=n
    setl formatoptions+=n   " recognize numbered lists
    setl formatoptions+=1   " don't break line before 1 letter word
    setl formatoptions+=t   " autoformat of text (vim default)

    " clean out stuff we likely don't want
    setl formatoptions-=v   " only break line at blank entered during insert
    setl formatoptions-=w   " avoid erratic behavior if mixed spaces
    setl formatoptions-=a   " autoformat will turn on with Insert in HardPencil mode
    setl formatoptions-=2   " doesn't work with with fo+=n, says docs
  ]]
end

function M.focus_current_pane()
  -- Open the current buffer in the new tab
  vim.cmd.split { mods = { tab = 1 } }

  local fillchars = "vert: ,eob: "

  local focus_pane = require "no-neck-pain"
  focus_pane.setup {
    width = 88,
    buffers = {
      colors = {
        background = require("nord.named_colors").black,
        blend = -0.1,
      },
      wo = {
        fillchars = fillchars,
      },
    },
  }
  focus_pane.enable()

  vim.wo.fillchars = fillchars
end

M.init()
_G["ProseMode"] = M

return M
