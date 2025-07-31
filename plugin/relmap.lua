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
  -- I am using the `vim.fn.substitute` specifically, as it handles UTF-8 characters
  -- transparently. There is no need to dissect the string byte by byte, as with any
  -- available native to Lua function.
  -- For example, in the `string.gsub(input, ".", function(s) return s end)`, the `s`
  -- will be a single byte in case of non-English characters.
  -- While not really explicitly stated anywhere, and no usage examples are provided,
  -- a Lua function works fine as a `Funcref` parameter.
  ---@param m string[]|nil
  ---@return string|nil
  ---@diagnostic disable-next-line: param-type-mismatch
  return vim.fn.substitute(input, ".", function(m)
    local char = m and m[1] or nil
    return M.ensure()[char] or char
  end, "g")
end

---@param type "line"|"char"|"block"|nil
---@return "g@"|nil
function M.operator(type)
  if type == nil then
    vim.o.operatorfunc = "v:lua.Relmap.operator"
    return "g@"
  end
  local start_pos = vim.api.nvim_buf_get_mark(0, "[")
  local end_pos = vim.api.nvim_buf_get_mark(0, "]")
  local p = {
    start_row = start_pos[1] - 1, -- get_mark is (1, 0) based, {get,set}_text is (0, 0) based
    start_col = type == "line" and 0 or start_pos[2],
    end_row = end_pos[1] - 1,
    end_col = type == "line" and -1 or end_pos[2] + 1, -- make selection inclusive
  }
  local text = vim.api.nvim_buf_get_text(0, p.start_row, p.start_col, p.end_row, p.end_col, {})
  local retext = vim.iter(text):map(M.relmap):totable()
  vim.api.nvim_buf_set_text(0, p.start_row, p.start_col, p.end_row, p.end_col, retext)
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
