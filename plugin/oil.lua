local ok, oil = pcall(require, "oil")
if not ok then vim.notify("oil.nvim is not available", vim.log.levels.WARN, {}) end

local M = {}

---@param filename string
---@return nil|string
M.get_h1 = function(filename)
  ---@type nil|string
  local h1 = vim
    .iter(io.lines(filename))
    :take(50) -- Only check the first 50 lines
    :find(function(line) return vim.startswith(line, "# ") end)
  if h1 ~= nil then h1 = h1:sub(3) end -- Remove the `# ` prefix
  return h1
end

M.ns_id = vim.api.nvim_create_namespace "zk-virtual-h1"

M.set_virtulal_h1 = function()
  local cd = oil.get_current_dir(0)
  local line_count = vim.api.nvim_buf_line_count(0)
  -- Line 1 is the `..` entry
  for lnum = 2, line_count do
    ---@type nil|oil.Entry
    local entry = oil.get_entry_on_line(0, lnum)
    if entry ~= nil then
      if entry.type == "file" and vim.endswith(entry.name, ".md") then
        local filename = vim.fs.joinpath(cd, entry.name)
        local h1 = M.get_h1(filename)
        if h1 ~= nil then
          local opts = {
            virt_text = { { h1, "NonText" } },
          }
          vim.api.nvim_buf_set_extmark(0, M.ns_id, lnum - 1, 0, opts)
        end
      end
    end
  end
end

M.clear = function() vim.api.nvim_buf_clear_namespace(0, M.ns_id, 0, -1) end

M.augroup = vim.api.nvim_create_augroup("zk-virtual-h1", { clear = true })
vim.api.nvim_create_autocmd("User", {
  group = M.augroup,
  pattern = "OilEnter",
  callback = function()
    local cd = oil.get_current_dir(0)
    if vim.fn.finddir(".zk", vim.fn.escape(cd, " ") .. ";") ~= "" then M.set_virtulal_h1() end
  end,
})

_G.Oil = M

return M
-- vim: ts=2 sts=2 sw=2 et
