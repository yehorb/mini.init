-- `:hi` Roller - gambling for highlights.
-- Actually, it just a tool to help me test colorschemes.

local augroup = vim.api.nvim_create_augroup("hiroller", { clear = true })

-- Just make sure that all of these are installed.
-- Failure is not an option for now.
local colorschemes = {
  "tokyonight-night",
  "tokyonight-storm",
  "tokyonight-day",
  "tokyonight-moon",
  "catppuccin-latte",
  "catppuccin-frappe",
  "catppuccin-macchiato",
  "catppuccin-mocha",
  "kanagawa-wave",
  "kanagawa-dragon",
  "kanagawa-lotus",
  "nightfox",
  "dayfox",
  "dawnfox",
  "duskfox",
  "nordfox",
  "terafox",
  "carbonfox",
  "aura-dark",
  "aura-dark-soft-text",
  "aura-soft-dark",
  "aura-soft-dark-soft-text",
  "rose-pine-main",
  "rose-pine-moon",
  "rose-pine-dawn",
  "nord",
  "everforest",
  "gruvbox-material",
  "sonokai",
}

local function roll_colorscheme()
  local idx = vim.fn.rand() % #colorschemes + 1
  vim.g.colorscheme = colorschemes[idx]
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  callback = function()
    roll_colorscheme()
    vim.notify("Selected colorscheme `" .. vim.g.colorscheme .. "` for the current session", vim.log.levels.INFO, {})
    vim.cmd.colorscheme(vim.g.colorscheme)
    vim.cmd [[highlight! link Whitespace DiagnosticError]] -- Highlight nonprinting characters
  end,
})

vim.api.nvim_create_user_command("RollColorscheme", function(opts)
  if #opts.fargs > 0 then
    vim.g.colorscheme = opts.fargs[1]
  else
    roll_colorscheme()
  end
  vim.notify("Selected colorscheme `" .. vim.g.colorscheme .. "` for the current session", vim.log.levels.INFO, {})
  vim.cmd.colorscheme(vim.g.colorscheme)
  vim.cmd [[highlight! link Whitespace DiagnosticError]] -- Highlight nonprinting characters
end, {
  nargs = "?",
  complete = function(ArgLead, _, _)
    return vim
      .iter(ipairs(colorschemes))
      :map(function(_, name) return name:sub(1, #ArgLead) == ArgLead and name or nil end)
      :totable()
  end,
  desc = "Select a random colorscheme from a manually curated list, or pass a desired colorscheme name",
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  pattern = "*",
  group = augroup,
  callback = function()
    local stats_path = vim.fs.joinpath(vim.fn.stdpath "data", "colorscheme_stats.txt")
    local stats_file = assert(io.open(stats_path, "a"))
    stats_file:write((vim.g.colorscheme or "default") .. "\n")
    stats_file:flush()
    stats_file:close()
  end,
})
