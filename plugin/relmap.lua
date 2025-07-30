-- Reverse language mapping

local M = {}

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
  local output, _ = string.gsub(input, ".", function(s) return M.ensure()[s] or s end)
  return output
end

return M
