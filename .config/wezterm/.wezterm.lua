-- Config location: %USERPROFILE%\.wezterm.lua
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
    window:gui_window():maximize()
    -- window:gui_window():set_inner_size(width, height)
end)

config.default_domain = 'WSL:Ubuntu-26.04'

config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 12
config.default_cursor_style = 'BlinkingBar'
config.animation_fps = 60

config.color_scheme = 'Catppuccin Mocha'
config.enable_tab_bar = false
config.window_decorations = "TITLE|RESIZE"
config.window_background_opacity = 1.0
config.window_close_confirmation = 'NeverPrompt'

-- Ctrl+click on a link opens it in Chrome (overrides the Windows default
-- browser, which is Edge). Ctrl+click is already a default WezTerm binding;
-- this only redirects the target.
wezterm.on('open-uri', function(window, pane, uri)
    wezterm.background_child_process({
        'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe', uri,
    })
    return false -- prevent the default open-uri handler
end)

return config
