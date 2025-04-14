vim.keymap.set(
  "n",
  "<Plug>(MarkdownTodayUk)",
  "<Cmd>read !$(Get-Date).ToString('dddd, dd/MM/yyyy', $(Get-Culture -Name uk-UA))<CR>J",
  { noremap = true }
)
