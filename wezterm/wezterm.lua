-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- color schemes
config.color_schemes = {
  ["josean-dev/coolnight"] = {
		foreground = "#CBE0F0",
		background = "#011423",
		cursor_bg = "#47FF9C",
		cursor_border = "#47FF9C",
		cursor_fg = "#011423",
		selection_bg = "#706b4e",
		selection_fg = "#f3d9c4",
		ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
		brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
	},
}

-- nice included options:
-- "Catppuccin Mocha"
-- "Catppuccin Macchiato"
-- "Catppuccin Frappe"
-- "Catppuccin Latte"
-- "ayu"
-- "Ayu Dark (Gogh)"
-- "Ayu Mirage"
-- "Ayu Mirage (Gogh)"

config.color_scheme = "josean-dev/coolnight"

-- font
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 16

-- disable tab bar
config.enable_tab_bar = false

-- cursor
config.default_cursor_style = "SteadyUnderline"

-- window
config.window_close_confirmation = "NeverPrompt"
config.window_padding = {
  left = 20,
  right = 20,
  top = 20,
  bottom = 20,
}
config.window_decorations = "TITLE | RESIZE"
config.window_background_opacity = 1

-- and finally, return the configuration to wezterm
return config
