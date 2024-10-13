vim.wo.spell = true
-- Using en spelllang slows downg suggestions immensly
vim.bo.spelllang = "uk,en_gb,en_us"

vim.bo.textwidth = 79
vim.wo.colorcolumn = "+1"
vim.wo.conceallevel = 1

vim.api.nvim_create_user_command("ProseMode", function()
  -- Open the current buffer in the new tab
  vim.cmd.split { mods = { tab = 1 } }

  vim.wo.fillchars = "vert: ,eob: "
  vim.o.laststatus = 3

  local pain = require "no-neck-pain"
  pain.setup {
    width = 88,
    buffers = {
      wo = {
        fillchars = vim.wo.fillchars,
      },
    },
  }
  pain.enable()

  vim.fn["pencil#init"] {
    conceallevel = vim.wo.conceallevel,
    textwidth = vim.bo.textwidth,
    wrap = "soft",
  }
end, {})
