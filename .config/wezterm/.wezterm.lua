-- Config location: ~/.wezterm.lua on every platform.
local wezterm = require 'wezterm'
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

wezterm.on("gui-startup", function(cmd)
    local _, _, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

if wezterm.target_triple:find('windows') then
    config.default_prog = { 'pwsh.exe', '-NoLogo' }
    -- Optional: DOTFILES_WSL_DISTRO=Ubuntu-26.04 restores a WSL default.
    if os.getenv('DOTFILES_WSL_DISTRO') then
        config.default_domain = 'WSL:' .. os.getenv('DOTFILES_WSL_DISTRO')
        config.default_prog = nil
    end
else
    config.default_prog = { 'zsh', '-l' }
end

config.font = wezterm.font_with_fallback { 'JetBrainsMono Nerd Font', 'JetBrains Mono' }
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
    if wezterm.target_triple:find('windows') then
        local chrome = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
        local file = io.open(chrome, 'r')
        if file then
            file:close()
            wezterm.background_child_process({ chrome, uri })
            return false
        end
    end
    -- Other platforms (or no Chrome): let WezTerm use the system browser.
end)

return config
