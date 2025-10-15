local wezterm = require 'wezterm'
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

wezterm.on("gui-startup", function(cmd)
  local screen            = wezterm.gui.screens().active
  local ratio             = 0.7
  local width, height     = screen.width * ratio, screen.height * ratio
  local tab, pane, window = wezterm.mux.spawn_window {
    position = {
      x = (screen.width - width) / 2,
      y = (screen.height - height) / 2,
      origin = 'ActiveScreen' }
  }
  -- window:gui_window():maximize()
  window:gui_window():set_inner_size(width, height)
end)

config.default_domain = 'WSL:Ubuntu-24.04'

config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 12
config.default_cursor_style = 'SteadyUnderline'

config.color_scheme = 'Catppuccin Mocha'
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.85
config.window_close_confirmation = 'NeverPrompt'

return config
