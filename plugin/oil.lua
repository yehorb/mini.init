local ok, oil = pcall(require, "oil")
if not ok then vim.notify("oil.nvim is not available", vim.log.levels.WARN, {}) end

local line_count = vim.api.nvim_buf_line_count(0)
-- Line 1 is the `..` entry
for lnum = 2, line_count do
  ---@type nil|oil.Entry
  local entry = oil.get_entry_on_line(0, lnum)
  vim.print(entry)
end
-- vim: ts=2 sts=2 sw=2 et
