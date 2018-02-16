require("awful.autofocus")

local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")
local beautiful = require("beautiful")

awful.rules = require("awful.rules")

-- {{{ Error handling
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = err
		})

		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
local modkey = "Mod4"

local terminal = "tilda"
local editor = os.getenv("EDITOR") or "vim"

local layouts = {
	awful.layout.suit.max,
	awful.layout.suit.tile,
}
-- }}}

-- {{{ Wallpaper
beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")
-- beautiful.wallpaper = '/usr/share/awesome/wallpapers/arch_linux.jpg'
-- for s = 1, screen.count() do
-- 	gears.wallpaper.maximized(beautiful.wallpaper, nil, true)
-- end
--}}}

-- {{{ Tags
local tags = {
	names  = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
	layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1],
		   layouts[1], layouts[1], layouts[1], layouts[1],
	}
}
for s = 1, screen.count() do
	-- Each screen has its own tag table.
	tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Wibox
-- Create a textclock widget
local textclock = awful.widget.textclock("%a %b %d, %H:%M:%S ", 1)

local function text_color(color, text)
	return string.format("<span color='%s'>%s</span>", color, text)
end

local memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, function(widget, args)
	local color = 'light green';
	local level = args[1];

	if (level > 25 and level <= 75) then
		color = 'yellow'
	elseif (level > 75) then
		color = 'red'
	end

	return string.format("Mem: %s%% | ", text_color(color, level))
end, 10)

local cpuwidget = wibox.widget.textbox()
vicious.register(cpuwidget, vicious.widgets.cpu, function(widget, args)
	local status = 'Cpu: ['

	local delim = '';
	for i = 1, 4 do
		local color = 'light green';
		local value = args[i] or 0;

		if (value > 30 and value <= 65) then
			color = 'yellow'
		elseif (value > 65) then
			color = 'red'
		end

		status = status .. delim .. text_color(color, value) .. "%"
		delim = " "
	end

	return status .. '] | '
end)

local batwidget = wibox.widget.textbox()
do
	vicious.register(batwidget, vicious.widgets.bat, function(widget, args)
		local value = args[2]
		local time = args[3]
		local color = 'light green'

		if (value > 40 and value < 75) then
			color = 'yellow'
		elseif (value <= 40) then
			color = 'red'
		end

		return string.format("Bat: %s%% (%s) | ", text_color(color, value), time)
	end, 10, "BAT1")
end

local volumewidget = wibox.widget.textbox()
vicious.register(volumewidget, vicious.widgets.volume, function(widget, args)
	local label = { ["♫"] = false, ["♩"] = "mute" }
	local val = label[args[2]] or (args[1] .. "%")
	return "Vol: " .. val .. " | "
end, 1, "Master")

local kbdwidget = wibox.widget.textbox("[us] | ")

dbus.request_name("session", "ru.gentoo.kbdd")
dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
dbus.connect_signal("ru.gentoo.kbdd", function(...)
	local kbdstrings = {[0] = "[en]", [1] = "[ru]"}
	local data = {...}
	local layout = data[2]

	kbdwidget:set_markup(kbdstrings[layout] .. " | ")
end)

-- Create a wibox for each screen and add it
local mywibox = {}
local mypromptbox = {}
for s = 1, screen.count() do
	mypromptbox[s] = awful.widget.prompt()
	local taglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, nil)
	local tasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, nil)

	-- Create the wibox
	mywibox[s] = awful.wibox({ position = "top", screen = s })

	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(taglist)
	left_layout:add(mypromptbox[s])

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	right_layout:add(kbdwidget)
	right_layout:add(volumewidget)
	right_layout:add(batwidget)
	right_layout:add(memwidget)
	right_layout:add(cpuwidget)
	right_layout:add(textclock)
	if s == 1 then right_layout:add(wibox.widget.systray()) end

	-- Now bring it all together (with the tasklist in the middle)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(tasklist)
	layout:set_right(right_layout)

	mywibox[s]:set_widget(layout)
end
-- }}}

do
	local several_screens = screen.count() > 1
	function toggle_screen_count()
		if several_screens == true then
			awful.util.spawn("xrandr --output VGA1 --off")
		else
			awful.util.spawn("xrandr --output VGA1 --auto --above LVDS1")
		end

		several_screens = not several_screens
	end
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
	awful.key({ modkey,			  }, "Escape",
		function () awful.util.spawn("xscreensaver-command -lock") end),

	awful.key({ modkey,			  }, "F6", toggle_screen_count),

	awful.key({ modkey,			  }, "F2",
		function () awful.util.spawn("amixer sset Master toggle") end),
	awful.key({ modkey,			  }, "F3",
		function () awful.util.spawn("amixer -c0 set Master 1%-") end),
	awful.key({ modkey,			  }, "F4",
		function () awful.util.spawn("amixer -c0 set Master 1%+") end),

	awful.key({ modkey,			  }, "F5",
		function () awful.util.spawn("xbacklight -5") end),
	awful.key({ modkey,			  }, "F6",
		function () awful.util.spawn("xbacklight +5") end),

	awful.key({ modkey,			  }, "Print",
		function () awful.util.spawn("xfce4-screenshooter") end),

	awful.key({ modkey,			  }, "Left",   awful.tag.viewprev),
	awful.key({ modkey,			  }, "Right",  awful.tag.viewnext),

	awful.key({ modkey,			  }, "j",
		function ()
			awful.client.focus.byidx( 1)
			if client.focus then client.focus:raise() end
		end),
	awful.key({ modkey,			  }, "k",
		function ()
			awful.client.focus.byidx(-1)
			if client.focus then client.focus:raise() end
		end),

	-- Layout manipulation
	awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end),
	awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end),
	awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
	awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
	awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
	awful.key({ modkey,           }, "Tab",
		function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end),

	-- Standard program
	awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
	awful.key({ modkey, "Control" }, "r", awesome.restart),
	awful.key({ modkey, "Shift"   }, "q", awesome.quit),

	awful.key({ modkey,           }, "l", function () awful.tag.incmwfact( 0.05) end),
	awful.key({ modkey,           }, "h", function () awful.tag.incmwfact(-0.05) end),
	awful.key({ modkey, "Shift"   }, "h", function () awful.tag.incnmaster( 1) end),
	awful.key({ modkey, "Shift"   }, "l", function () awful.tag.incnmaster(-1) end),
	awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol( 1) end),
	awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1) end),
	awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
	awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

	awful.key({ modkey, "Control" }, "n", awful.client.restore),

	-- Prompt
	awful.key({ modkey            }, "r", function () mypromptbox[mouse.screen]:run() end),
	awful.key({ modkey }, "x",
		function ()
			awful.prompt.run({ prompt = "Run Lua code: " },
			mypromptbox[mouse.screen].widget,
			awful.util.eval, nil,
			awful.util.getdir("cache") .. "/history_eval")
		end),

	-- Menubar
	awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
	awful.key({ modkey,           }, "f", function (c) c.fullscreen = not c.fullscreen  end),
	awful.key({ modkey, "Shift"   }, "c", function (c) c:kill() end),
	awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle),
	awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
	awful.key({ modkey,           }, "o", awful.client.movetoscreen),
	awful.key({ modkey,           }, "t", function (c) c.ontop = not c.ontop end),
	awful.key({ modkey,           }, "n",
		function (c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end),
	awful.key({ modkey,           }, "m",
		function (c)
			c.maximized_horizontal = not c.maximized_horizontal
			c.maximized_vertical   = not c.maximized_vertical
		end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = awful.util.table.join(globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9,
				function ()
						local screen = mouse.screen
						local tag = awful.tag.gettags(screen)[i]
						if tag then
							awful.tag.viewonly(tag)
						end
				end),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9,
				function ()
					if client.focus then
						local tag = awful.tag.gettags(client.focus.screen)[i]
						if tag then
							awful.client.movetotag(tag)
						end
					end
				end))
end

clientbuttons = awful.util.table.join(
	awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({ modkey }, 1, awful.mouse.client.move),
	awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = { },
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons
		}
	},

	{ rule = { class = "gimp" }, properties = { floating = true } },
	{ rule = { class = "tilda" }, properties = { tag = tags[1][1] } },

	{ rule = { class = "Firefox" }, properties = { tag = tags[1][2] } },
	{ rule = { class = "Chromium" }, properties = { tag = tags[1][2] } },

	{ rule = { class = "Skype" }, properties = { tag = tags[1][3] } },
	{ rule = { class = "Pidgin" }, properties = { tag = tags[1][3] } },
	{ rule = { class = "Wine" }, properties = { tag = tags[1][3], floating = true } },

	{ rule = { class = "Deadbeef" }, properties = { tag = tags[1][4] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
	-- Enable sloppy focus
	c:connect_signal("mouse::enter", function(c)
		if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
			and awful.client.focus.filter(c) then
			client.focus = c
		end
	end)

	if not startup then
		-- Put windows in a smart way, only if they does not set an initial position.
		if not c.size_hints.user_position and not c.size_hints.program_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
	end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


-- {{{ startup
awful.util.spawn("/usr/bin/setxkbmap -option 'caps:ctrl_modifier'")
awful.util.spawn('/usr/bin/setxkbmap -layout "us,ru(winkeys)" -option grp:alt_shift_toggle')
awful.util.spawn("/usr/bin/xcape -e 'Caps_Lock=Control_L'")

awful.util.spawn("/usr/bin/xscreensaver -no-splash")
awful.util.spawn("/usr/bin/nm-applet")
awful.util.spawn("/usr/bin/tilda")
awful.util.spawn("/usr/bin/kbdd")
-- }}}
