local ok, oil = pcall(require, "oil")
if not ok then vim.notify("oil.nvim is not available", vim.log.levels.WARN, {}) end

---@param filename string
---@return nil|string
local function get_h1(filename) return nil end

local cd = oil.get_current_dir(0)
local line_count = vim.api.nvim_buf_line_count(0)
-- Line 1 is the `..` entry
for lnum = 2, line_count do
  ---@type nil|oil.Entry
  local entry = oil.get_entry_on_line(0, lnum)
  if entry ~= nil then
    if entry.type == "file" then
      local filename = vim.fs.joinpath(cd, entry.name)
      local h1 = get_h1(filename)
      vim.print(h1)
    end
  end
end
-- vim: ts=2 sts=2 sw=2 et
