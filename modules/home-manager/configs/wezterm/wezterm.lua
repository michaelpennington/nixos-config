local wezterm = require("wezterm")

local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")

local config = wezterm.config_builder()

local font_size = 12
local hostname_file = io.open("/etc/hostname", "r")
if hostname_file ~= nil and hostname_file:read() == "COMPY10500" then
  font_size = 15.5
end

config.serial_ports = {
  {
    name = "duos",
    port = "/dev/ttyACM0",
    baud = 31250,
  },
}

-- local theme = require("colors/kanagawa-lotus")

config.color_scheme_dirs = { wezterm.config_dir .. "/colors" }
config.color_scheme = "kanagawa-paper-ink"
config.check_for_updates = false
-- config.colors = theme
-- config.color_scheme = "Zenburn (base16)"
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.font = wezterm.font({
  family = "FantasqueSansM Nerd Font Propo",
  harfbuzz_features = { "ss01" },
})
config.font_size = font_size -- 🦀 CRAB!
-- config.window_background_opacity = 0.92
config.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"
config.default_prog = { "fish" }
-- term = "wezterm"
-- config.xcursor_theme = "Phinger"
-- config.xcursor_size = 24
config.window_decorations = "NONE"
config.mux_enable_ssh_agent = false
config.keys = {
  {
    key = "_",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitVertical({ domain = "DefaultDomain" }),
  },
  {
    key = "|",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitHorizontal({ domain = "DefaultDomain" }),
  },
  {
    key = "_",
    mods = "CTRL|ALT|SHIFT",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "|",
    mods = "CTRL|ALT|SHIFT",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "h",
    mods = "CTRL|SHIFT",
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = "l",
    mods = "CTRL|SHIFT",
    action = wezterm.action.ActivateTabRelative(1),
  },
}

smart_splits.apply_to_config(config, {
  -- the default config is here, if you'd like to use the default keys,
  -- you can omit this configuration table parameter and just use
  -- smart_splits.apply_to_config(config)

  -- directional keys to use in order of: left, down, up, right
  direction_keys = { "h", "j", "k", "l" },
  -- if you want to use separate direction keys for move vs. resize, you
  -- can also do this:
  -- direction_keys = {
  --   move = { 'h', 'j', 'k', 'l' },
  --   resize = { 'LeftArrow', 'DownArrow', 'UpArrow', 'RightArrow' },
  -- },
  -- modifier keys to combine with direction_keys
  modifiers = {
    move = "CTRL", -- modifier to use for pane movement, e.g. CTRL+h to move left
    resize = "ALT", -- modifier to use for pane resize, e.g. META+h to resize to the left
  },
  -- log level to use: info, warn, error
  log_level = "info",
})
return config
