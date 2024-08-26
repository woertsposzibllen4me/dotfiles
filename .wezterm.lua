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
	["lua-language-server.exe"] = "",
	["powershell.exe"] = "", -- PowerShell icon
	["pwsh.exe"] = "", -- PowerShell Core icon
	["cmd.exe"] = "", -- Windows Command Prompt icon
	["bash.exe"] = "", -- Git Bash icon
	["wsl.exe"] = "", -- WSL icon
	["ssh"] = "", -- SSH sessions icon
	["nvim.exe"] = "", -- Neovim icon
	["vim.exe"] = "", -- Vim icon
	["htop.exe"] = "", -- htop icon
	["lazygit.exe"] = "󰊢",
	["less.exe"] = "",
}

local function get_process_icon(process_name, tab_name)
	wezterm.log_info("Process name: " .. (process_name or "unknown"))
	local icon = process_icons[process_name:lower()]

	-- Fallback to checking the tab name if no process icon was found
	if not icon and tab_name then
		wezterm.log_info("Tab name: " .. tab_name)
		if tab_name:lower():find("lazygit") then
			icon = "󰊢" -- Git nf icon
		end
	end
	return (icon or "") .. " "
end

wezterm.on("format-tab-title", function(tab, tabs, panes, hover, max_width)
	local title = tab_title(tab)
	local pane = tab.active_pane
	local process_name = tab.active_pane.foreground_process_name
	local process_icon = get_process_icon(process_name:match("[^\\]+$"))
	local zoom = ""
	local index = (tab.tab_index + 1) .. ": "
	if pane.is_zoomed then
		zoom = " "
	end
	return {
		{ Text = " " .. zoom .. index .. process_icon .. title .. " " },
	}
end)

config.font = wezterm.font("BerkeleyMono Nerd Font", { weight = "Regular" })
config.font_size = 12.0

config.color_scheme = "rose-pine-moon"

config.colors = {
	tab_bar = {
		background = "#182029",
		active_tab = {
			bg_color = "#112939",
			fg_color = "#ffc107",
			intensity = "Bold",
			italic = true,
		},

		inactive_tab = {
			bg_color = "#20232b",
			fg_color = "#b89f62",
			italic = true,
		},

		inactive_tab_hover = {
			bg_color = "#383b4b",
			fg_color = "#e4b42b",
			italic = true,
		},

		new_tab = {
			bg_color = "#20232b",
			fg_color = "#b89f62",
			italic = true,
		},

		new_tab_hover = {
			bg_color = "#383b4b",
			fg_color = "#e4b42b",
			italic = true,
		},
	},
}

config.background = {
	{
		source = {
			File = "C:/Users/ville/OneDrive/Pictures/background/one_piece_sailing.png",
		},
		hsb = {
			brightness = 1.0,
		},
	},
	{
		source = {
			Color = "rgba(28, 33, 39, 0.95)",
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
