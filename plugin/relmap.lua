-- Reverse language mapping

local M = {}
_G["Relmap"] = M

---@return table<string, string>
function M.ensure()
  if M._relmap == nil then
    M._relmap = vim
      .iter(ipairs(vim.fn.maplist()))
      :filter(function(_, map) return map.mode == "l" end)
      :fold({}, function(acc, _, map)
        acc[map.rhs] = map.lhs
        return acc
      end)
  end
  return M._relmap
end

---@param input string
---@return string
function M.relmap(input)
  -- While not really explicitly stated anywhere, and no usage examples are provided,
  -- a lua function works fine as a `Funcref` parameter.
  ---@param m string[]|nil
  ---@return string|nil
  ---@diagnostic disable-next-line: param-type-mismatch
  return vim.fn.substitute(input, ".", function(m)
    local char = m and m[1] or nil
    return M.ensure()[char] or char
  end, "g")
end

---@param type string|nil
---@return "g@"|nil
function M.operator(type)
  if type == nil then
    vim.o.operatorfunc = "v:lua.Relmap.operator"
    return "g@"
  end
  local start_row, start_col = unpack(vim.api.nvim_buf_get_mark(0, "["))
  local end_row, end_col = unpack(vim.api.nvim_buf_get_mark(0, "]"))
  local text = vim.api.nvim_buf_get_text(0, start_row - 1, start_col, end_row - 1, end_col + 1, {})
  local retext = vim.iter(text):map(M.relmap):totable()
  vim.api.nvim_buf_set_text(0, start_row - 1, start_col, end_row - 1, end_col + 1, retext)
end

vim.keymap.set(
  { "n", "x" },
  "<leader>rl",
  function() return M.operator() end,
  { expr = true, desc = "Reverse language mapping" }
)
vim.keymap.set(
  "n",
  "<leader>rll",
  function() return M.operator() .. "_" end,
  { expr = true, desc = "Reverse language mapping" }
)

return M
