-- Pull in the wezterm API
local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

config.default_prog = { "pwsh" }
config.initial_cols = 120
config.initial_rows = 30
config.enable_kitty_keyboard = true

require("wezterm").on("format-window-title", function()
	return "Wezterm"
end)

config.use_fancy_tab_bar = false
config.tab_max_width = 45
-- config.default_cursor_style = "SteadyBar"

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
	["starship"] = "\u{f427} ",
}

-- Updated function to get process name
local function get_process_name(process_name)
	-- Extract just the executable name without path or extension
	wezterm.log_info("process_name : " .. tostring(process_name))
	local name
	if process_name and process_name ~= "" then
		name = process_name:match("([^\\]+)%.?[^.]*$")
		name = name:gsub("%.exe$", "")
	else
		name = "nil"
	end

	return name:lower()
end

local function get_current_working_directory(tab)
	-- Get the current working directory
	local cwd_url = tab.active_pane.current_working_dir

	wezterm.log_info("Original CWD object: " .. tostring(cwd_url))

	if cwd_url then
		-- Access the path field of the URL
		local path = cwd_url.path
		wezterm.log_info("CWD path: " .. tostring(path))

		-- Extract just the last part of the path (current folder name)
		local folder_name = string.match(path, "([^/\\]+)$")
		wezterm.log_info("Extracted folder name: " .. tostring(folder_name))

		return folder_name or ""
	else
		wezterm.log_info("CWD is nil")
		return ""
	end
end

wezterm.on("format-tab-title", function(tab, tabs, panes, hover, max_width)
	wezterm.log_info("\n")
	local process_name = get_process_name(tab.active_pane.foreground_process_name)
	local icon = process_icons[process_name] or ""
	local cwd = get_current_working_directory(tab)

	-- Create tab number
	local tab_number = tab.tab_index + 1 -- Wezterm uses 0-based indexing, so we add 1

	local zoom_icon = ""
	if tab.active_pane.is_zoomed then
		zoom_icon = " "
	end

	-- Combine tab number, icon (if exists), and process name
	local title = string.format("%s%d: %s%s - (../%s/)", zoom_icon, tab_number, icon, process_name, cwd)

	return {
		{ Text = " " .. title .. " " },
	}
end)

config.font = wezterm.font("BerkeleyMono Nerd Font", { weight = "Regular" })
config.font_size = 12.0

config.inactive_pane_hsb = {
	hue = 1.0,
	saturation = 0.8,
	brightness = 0.8,
}

local scheme_name = "tokyonight_moon"
local scheme = wezterm.color.get_builtin_schemes()[scheme_name]

-- config.color_scheme = scheme_name

scheme.brights[1] = "#ff69b4" -- Set pwsh args comments to pink !
scheme.brights[2] = "#fc5858" -- more saturated reds
scheme.ansi[2] = "#fc5858"
scheme.brights[3] = "#b4ed77" -- more saturated greens
scheme.ansi[3] = "#b4ed77"
scheme.brights[8] = "#67e6e6" -- more saturated greens

scheme.ansi[8] = "#c2d0f2"

config.colors = scheme

config.colors.tab_bar = {
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

config.leader = { key = " ", mods = "CTRL" }
config.keys = {
	{ key = "F11", action = wezterm.action.ToggleFullScreen },

	-- Navigate between panes
	{
		key = "h",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "CTRL|SHIFT",
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

	-- Zoom
	{
		key = "z",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
	},

	-- Rename tab
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

	-- New tab
	{
		key = "t",
		mods = "LEADER",
		action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }),
	},

	-- Switch to tabs
	{ key = "1", mods = "LEADER", action = wezterm.action({ ActivateTab = 0 }) },
	{ key = "2", mods = "LEADER", action = wezterm.action({ ActivateTab = 1 }) },
	{ key = "3", mods = "LEADER", action = wezterm.action({ ActivateTab = 2 }) },
	{ key = "5", mods = "LEADER", action = wezterm.action({ ActivateTab = 4 }) },
	{ key = "6", mods = "LEADER", action = wezterm.action({ ActivateTab = 5 }) },
	{ key = "7", mods = "LEADER", action = wezterm.action({ ActivateTab = 6 }) },
	{ key = "8", mods = "LEADER", action = wezterm.action({ ActivateTab = 7 }) },

	-- Toggle tabs
	{
		key = "T",
		mods = "LEADER",
		action = act.EmitEvent("toggle-tabbar"),
	},

	-- Custom bind for nvim
	{
		key = "Enter",
		mods = "ALT",
		action = "DisableDefaultAssignment",
	},
	-- Disable for Pwsh
	{
		key = "Tab",
		mods = "CTRL",
		action = "DisableDefaultAssignment",
	},
}

-- Add tab movement keybindings
for i = 1, 8 do
	-- CTRL+ALT + number to move to that position
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL|ALT",
		action = wezterm.action.MoveTab(i - 1),
	})
end

return config
