local active_border_color = "rgba(6f9ed0ee)"
local inactive_border_color = "rgba(343832aa)"
local group_bg = "rgba(030403cc)"
local focus_bg = "rgba(0d1722ee)"

hl.config({
  general = {
    gaps_in = 3,
    gaps_out = 7,
    border_size = 2,
    layout = "dwindle",
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  decoration = {
    rounding = 0,
    active_opacity = 1.0,
    inactive_opacity = 0.96,
    shadow = {
      enabled = false,
    },
    blur = {
      enabled = false,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
    groupbar = {
      font_family = "JetBrains Mono Nerd Font",
      font_size = 11,
      height = 20,
      gaps_in = 0,
      gaps_out = 0,
      indicator_height = 0,
      text_color = "rgb(e7dec8)",
      text_color_inactive = "rgba(c8c2aa99)",
      col = {
        active = focus_bg,
        inactive = group_bg,
      },
      gradients = false,
      gradient_rounding = 0,
    },
  },

  animations = {
    enabled = true,
  },

  dwindle = {
    preserve_split = true,
    smart_split = true,
  },

  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    focus_on_activate = true,
  },
})

hl.curve("lainSnappy", { type = "bezier", points = { { 0.1, 1.0 }, { 0.1, 1.0 } } })

hl.animation({ leaf = "global", enabled = true, speed = 1, bezier = "lainSnappy" })
hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "lainSnappy", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "lainSnappy", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "lainSnappy" })
hl.animation({ leaf = "border", enabled = true, speed = 4, bezier = "lainSnappy" })
hl.animation({ leaf = "fade", enabled = false })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "lainSnappy", style = "slidevert" })
