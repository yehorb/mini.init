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

---@param char string
---@return string
function M.re(char) return M.ensure()[char] or char end

---@param input string
---@return string
function M.relmap(input)
  return vim.iter(vim.fn.range(vim.fn.strchars(input))):fold("", function(acc, charnr)
    local char = vim.fn.nr2char(vim.fn.strgetchar(input, charnr))
    return acc .. (M.ensure()[char] or char)
  end)
end

_G["relmap"] = M

return M
