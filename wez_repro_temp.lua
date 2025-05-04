-- Pull in the wezterm API
local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

config.default_prog = { "pwsh" }
config.enable_kitty_keyboard = false
local function get_uri(window, pane)
  local uri = pane:get_current_working_dir()
  if uri then
    wezterm.log_info(uri)
  end
end

config.keys = {

  -- for testing
  {
    key = "?",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(get_uri),
  },
}
