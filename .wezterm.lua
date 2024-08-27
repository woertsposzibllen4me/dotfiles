-- Pull in the wezterm API
local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

config.default_prog = { "pwsh" }
config.initial_cols = 120
config.initial_rows = 30

require("wezterm").on("format-window-title", function()
	return "Wezterm"
end)

config.use_fancy_tab_bar = false
config.tab_max_width = 35

wezterm.on("toggle-tabbar", function(window, _)
	local overrides = window:get_config_overrides() or {}
	if overrides.enable_tab_bar == false then
		wezterm.log_info("tab bar shown")
		overrides.enable_tab_bar = true
	else
		wezterm.log_info("tab bar hidden")
		overrides.enable_tab_bar = false
	end
	window:set_config_overrides(overrides)
end)

function tab_title(tab_info)
	local title = tab_info.tab_title
	if title and #title > 0 then
		return title
	end
	return tab_info.active_pane.title
end

local process_icons = {
	-- Shells
	["powershell"] = "\u{f0a0a} ", --
	["pwsh"] = "\u{f0a0a} ", --
	["cmd"] = "\u{ebc4} ", --
	["bash"] = "\u{e795} ", --
	["zsh"] = "\u{e795} ", --
	["fish"] = "\u{e795} ", --
	["nu"] = "\u{e795} ", --

	-- Programming languages and runtimes
	["python"] = "\u{e606} ", --
	["node"] = "\u{ed0d} ", --
	["ruby"] = "\u{e791} ", --
	["java"] = "\u{e738} ", --
	["perl"] = "\u{e769} ", --
	["php"] = "\u{e73d} ", --

	-- Text editors and IDEs
	["nvim"] = "\u{e62b} ", --
	["vim"] = "\u{e62b} ", --
	["code"] = "\u{e70c} ", --
	["emacs"] = "\u{e7b4} ", --

	-- Version control
	["git"] = "\u{f02a2} ", --
	["lazygit"] = "\u{f02a2} ", --

	-- System tools
	["htop"] = "\u{f85a} ", --
	["top"] = "\u{f85a} ", --
	["ssh"] = "\u{f817} ", --
	["docker"] = "\u{f308} ", --

	-- File operations
	["ranger"] = "\u{f413} ", --
	["fzf"] = "\u{f349} ", --

	-- Networking
	["ping"] = "\u{fb27} ", --
	["curl"] = "\u{f8c8} ", --

	-- Miscellaneous
	["lua"] = "\u{e620} ", --
	["terraform"] = "\u{e7b7} ", --

	-- Additional common tools
	["npm"] = "\u{e71e} ", --
	["yarn"] = "\u{e718} ", --
	["cargo"] = "\u{e7a8} ", --
	["rustc"] = "\u{e7a8} ", --
	["go"] = "\u{e626} ", --
	["dotnet"] = "\u{e77f} ", --

	-- Manual Additions
	["lua-language-server"] = "\u{f08b1} ",
	["oh-my-posh"] = "\u{f0a0a} ",
}

-- Updated function to get process name
local function get_process_name(process_name)
	-- Extract just the executable name without path or extension
	local name = process_name:match("([^\\]+)%.?[^.]*$")
	name = name:gsub("%.exe$", "")
	return name:lower()
end

wezterm.on("format-tab-title", function(tab, tabs, panes, hover, max_width)
	local process_name = get_process_name(tab.active_pane.foreground_process_name)
	local icon = process_icons[process_name] or ""

	-- Create tab number
	local tab_number = tab.tab_index + 1 -- Wezterm uses 0-based indexing, so we add 1

	-- Combine tab number, icon (if exists), and process name
	local title = string.format("%d: %s%s", tab_number, icon, process_name)

	return {
		{ Text = " " .. title .. " " },
	}
end)

config.font = wezterm.font("BerkeleyMono Nerd Font", { weight = "Regular" })
config.font_size = 12.0

config.color_scheme = "Navy and Ivory (terminal.sexy)"
config.colors = {
	tab_bar = {
		background = "#16161e", -- Darker background for the tab bar
		active_tab = {
			bg_color = "#1a1b26", -- Slightly lighter than the tab bar background
			fg_color = "#ff9e64", -- Orange pop color from Tokyo Night theme
			intensity = "Bold",
			italic = false,
		},
		inactive_tab = {
			bg_color = "#16161e", -- Same as tab bar background
			fg_color = "#4b94a6", -- Muted foreground
			italic = true,
		},
		inactive_tab_hover = {
			bg_color = "#1f2335", -- Slightly lighter on hover
			fg_color = "#73e3ff", -- Tokyo Night cyan
			italic = false,
		},
		new_tab = {
			bg_color = "#16161e", -- Same as tab bar background
			fg_color = "#545c7e", -- Same as inactive tab
			italic = false,
		},
		new_tab_hover = {
			bg_color = "#1f2335", -- Same as inactive tab hover
			fg_color = "#7dcfff", -- Same as inactive tab hover
			italic = false,
		},
	},
}

config.background = {
	{
		source = {
			File = "C:/Users/ville/OneDrive/Pictures/background/luffy_sit.jpg",
		},
		hsb = {
			brightness = 0.02,
		},
	},
	{
		source = {
			Color = "rgba(28, 33, 39, 0.55)",
		},
		height = "100%",
		width = "100%",
	},
}

config.leader = { key = "Space", mods = "CTRL" }
config.keys = {
	{ key = "F11", action = wezterm.action.ToggleFullScreen },

	-- Navigate between panes
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},

	-- Split panes
	{
		key = "H",
		mods = "LEADER",
		action = wezterm.action.SplitPane({
			direction = "Left",
			size = { Percent = 50 },
		}),
	},
	{
		key = "J",
		mods = "LEADER",
		action = wezterm.action.SplitPane({
			direction = "Down",
			size = { Percent = 50 },
		}),
	},
	{
		key = "K",
		mods = "LEADER",
		action = wezterm.action.SplitPane({
			direction = "Up",
			size = { Percent = 50 },
		}),
	},
	{
		key = "L",
		mods = "LEADER",
		action = wezterm.action.SplitPane({
			direction = "Right",
			size = { Percent = 50 },
		}),
	},

	-- Close the current pane
	{
		key = "x",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},

	{
		key = "z",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
	},

	{
		key = "c",
		mods = "LEADER",
		action = wezterm.action.ClearScrollback("ScrollbackAndViewport"),
	},
	{
		key = "r",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{
		key = "t",
		mods = "LEADER",
		action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }),
	},
	{ key = "1", mods = "LEADER", action = wezterm.action({ ActivateTab = 0 }) },
	-- Switch to tab 2
	{ key = "2", mods = "LEADER", action = wezterm.action({ ActivateTab = 1 }) },
	-- Switch to tab 3
	{ key = "3", mods = "LEADER", action = wezterm.action({ ActivateTab = 2 }) },
	-- Switch to tab 4
	{ key = "4", mods = "LEADER", action = wezterm.action({ ActivateTab = 3 }) },
	-- Switch to tab 5
	{ key = "5", mods = "LEADER", action = wezterm.action({ ActivateTab = 4 }) },

	{
		key = "T",
		mods = "LEADER",
		action = act.EmitEvent("toggle-tabbar"),
	},

	{ key = "U", mods = "CTRL", action = "DisableDefaultAssignment" },
}

return config
