-- Reverse language mapping

local M = {}

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

_G["Relmap"] = M

return M
