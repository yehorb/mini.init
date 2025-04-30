vim.keymap.set({ "i", "c" }, "((", function() return (vim.o.iminsert == 1 and "<C-^>" or "") .. "\\(  \\)<C-o>3h" end, {
  expr = true,
  desc = "Turn off :lmap and enter inline math environment",
})

vim.keymap.set(
  { "i", "c" },
  "[[",
  function() return (vim.o.iminsert == 1 and "<C-^>" or "") .. "\\[\r\r\\]<C-o>k" end,
  {
    expr = true,
    desc = "Turn off :lmap and enter block math environment",
  }
)
