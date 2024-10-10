vim.opt_local.spell = true
vim.opt_local.spelllang = { "en", "uk" }

-- pencil#init will set conceallevel and textwidth options
vim.opt_local.colorcolumn = "+1"

vim.fn["pencil#init"] {
  conceallevel = 1,
  textwidth = 80,
  wrap = "hard",
}
