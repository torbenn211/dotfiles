vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true

pcall(vim.cmd.colorscheme, "habamax")

local set = vim.api.nvim_set_hl
local bg = "#030403"
local bg_alt = "#090a08"
local fg = "#c8c2aa"
local muted = "#343832"
local red = "#c94f37"
local red_dark = "#241815"
local focus = "#6f9ed0"
local focus_bg = "#0d1722"

set(0, "Normal", { fg = fg, bg = bg })
set(0, "NormalFloat", { fg = fg, bg = bg })
set(0, "FloatBorder", { fg = focus, bg = bg })
set(0, "LineNr", { fg = muted, bg = bg })
set(0, "CursorLineNr", { fg = "#e7dec8", bg = bg })
set(0, "CursorLine", { bg = bg_alt })
set(0, "Visual", { fg = "#8fb6dd", bg = focus_bg })
set(0, "Search", { fg = "#030403", bg = red })
set(0, "IncSearch", { fg = "#030403", bg = "#e7dec8" })
set(0, "StatusLine", { fg = "#8fb6dd", bg = focus_bg, bold = true })
set(0, "StatusLineNC", { fg = muted, bg = bg_alt })
set(0, "Pmenu", { fg = fg, bg = bg_alt })
set(0, "PmenuSel", { fg = "#8fb6dd", bg = focus_bg })
set(0, "DiagnosticError", { fg = red })
set(0, "DiagnosticWarn", { fg = "#e6c06f" })
set(0, "DiagnosticInfo", { fg = "#76b7a8" })
set(0, "DiagnosticHint", { fg = "#8ba36f" })
set(0, "Comment", { fg = muted, italic = true })
set(0, "String", { fg = "#8ba36f" })
set(0, "Function", { fg = focus })
set(0, "Keyword", { fg = red, bold = true })
set(0, "Type", { fg = "#d0a85a" })
