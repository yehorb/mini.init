local M = {}

function M.init()
  vim.wo.spell = true
  vim.bo.spelllang = "uk,en_us,en_gb" -- Using en spelllang slows downg suggestions immensly

  vim.wo.conceallevel = 1
  vim.wo.list = true

  vim.o.laststatus = 3 -- Show single statusline for all windows. Makes focused pane look better

  vim.bo.expandtab = true
  vim.bo.tabstop = 2
  vim.bo.shiftwidth = 2
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
