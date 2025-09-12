vim.keymap.set(
  "n",
  "<Plug>(MarkdownTodayUk)",
  "<Cmd>read !$(Get-Date).ToString('dddd, dd/MM/yyyy', $(Get-Culture -Name uk-UA))<CR>J",
  { noremap = true }
)

---@param level integer
---@return string
local function date_header(level)
  local hash_symbols = level > 0 and string.rep("#", level) .. " " or ""
  local date_str = os.date "%F, %A, %B %d, %Y"
  return hash_symbols .. date_str
end

vim.api.nvim_create_user_command("MarkdownDateHeader", function(opts)
  local level
  if #opts.fargs > 0 then
    level = tonumber(opts.fargs[1])
    if level == nil then error(string.format("expected integer, but got [%s]", opts.fargs[1])) end
  else
    level = 2
  end
  vim.api.nvim_paste(date_header(level), false, -1)
end, {
  nargs = "?",
})
