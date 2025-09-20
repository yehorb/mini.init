local ok, oil = pcall(require, "oil")
if not ok then vim.notify("oil.nvim is not available", vim.log.levels.WARN, {}) end
-- vim: ts=2 sts=2 sw=2 et
