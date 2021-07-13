-- Standard awesome library
-- Silence undeclared variable warnings, since they are loaded by awesome
_G.awesome = _G.awesome
_G.root = _G.root
_G.client = _G.client
-- Load Awesome Libraries
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
local hotkeys_popup = require("awful/hotkeys_popup")
require("awful/hotkeys_popup/keys")

-- User Defined Libraries
local utility = require("src/utility")
local dat = require("src/database")
local debug = require("src/debug")
-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts =
   {
      awful.layout.suit.tile,
      awful.layout.suit.floating,
      -- awful.layout.suit.fair,
      -- awful.layout.suit.spiral.dwindle
   }
local function xprop()
   if dat.xprop_lock ~= true then
      dat.xprop_lock = true
      awful.spawn.easy_async(
         "xprop _NET_WM_PID WM_NAME WM_CLASS",
         function (stdout, ...)
            _ = ...             -- Silence unused variable warnings and eat args
            naughty.notify(
               {
                  preset = naughty.config.presets.normal,
                  title = "Detect Window Propeties",
                  text = stdout,
                  -- Don't timeout so fast so the user has  time to read
                  timeout = 20,
                  font = dat.notification_font,
                  fg = '#C0C0C0',
                  bg = dat.widget_background_color,
                  border_width = 0
               }
            )
            dat.xprop_lock = false
         end
      )
   end
end
local flameshot = {}
function flameshot.invoke_gui()
   awful.spawn(dat.flameshot_gui_command)
end
function flameshot:invoke_screen()
   awful.spawn(dat.flameshot_screencap_command)
end
local function tdrop_terminal()
   awful.spawn(dat.screencapterminal_command);
end
-- Create a launcher widget and a main menu
local myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", dat.terminal .. " -e man awesome" },
   { "edit config", dat.editor_command .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}
local mymainmenu = awful.menu({
      items = {
         { "awesome", myawesomemenu, beautiful.awesome_icon },
         { "open terminal", dat.terminal }
      }
})
local mylauncher = awful.widget.launcher({
      image = beautiful.awesome_icon,
      menu = mymainmenu
})
awful.screen.connect_for_each_screen(function(s)
      -- Each screen has its own tag table.
      awful.tag.add("Graphically Intensive", {
                       -- icon               = "/path/to/icon1.png",
                       layout             = awful.layout.suit.floating,
                       gap_single_client  = false,
                       gap                = 0,
                       screen             = s,
      })
      awful.tag.add("System", {
                       -- icon = "/path/to/icon2.png",
                       layout = awful.layout.suit.tile,
                       screen = s,
      })
      awful.tag.add("Browser", {
                       -- icon = "/path/to/icon2.png",
                       layout = awful.layout.suit.tile,
                       screen = s,
      })
      awful.tag.add("Social", {
                       -- icon = "/path/to/icon2.png",
                       layout = awful.layout.suit.tile,
                       screen = s,
      })
      awful.tag.add("Other", {
                       -- icon = "/path/to/icon2.png",
                       layout = awful.layout.suit.tile,
                       screen = s,
      })
      awful.tag.add("Other 2", {
                       -- icon = "/path/to/icon2.png",
                       layout = awful.layout.suit.tile,
                       screen = s,
      })
      awful.tag.add("Graphically Intensive 2", {
                       -- icon = "/path/to/icon2.png",
                       layout = awful.layout.suit.tile,
                       screen = s,
      })
end)
-- }}}
-- {{{ Mouse bindings
root.buttons(gears.table.join(
                awful.button({ }, 3, function () mymainmenu:toggle() end),
                awful.button({ }, 4, awful.tag.viewnext),
                awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}
-- {{{ Key bindings
local globalkeys = gears.table.join(
   awful.key({ dat.modkey,           }, "s",      hotkeys_popup.show_help,
      {description="show help", group="awesome"}),
   awful.key({ dat.modkey,           }, "q",   awful.tag.viewprev,
      {description = "view previous", group = "tag"}),
   awful.key({ dat.modkey,           }, "e",  awful.tag.viewnext,
      {description = "view next", group = "tag"}),
   awful.key({ dat.modkey,           }, "Escape", awful.tag.history.restore,
      {description = "go back", group = "tag"}),
   awful.key({ dat.modkey,           }, "j",
      function ()
         awful.client.focus.byidx( 1)
      end,
      {description = "focus next by index", group = "client"}
   ),
   awful.key({ dat.modkey,           }, "k",
      function ()
         awful.client.focus.byidx(-1)
      end,
      {description = "focus previous by index", group = "client"}
   ),
   awful.key({ dat.modkey,           }, "w", function () mymainmenu:show() end,
      {description = "show main menu", group = "awesome"}),

   -- Layout manipulation
   awful.key({ dat.modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
      {description = "swap with next client by index", group = "client"}),
   awful.key({ dat.modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
      {description = "swap with previous client by index", group = "client"}),
   awful.key({ dat.modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
      {description = "focus the next screen", group = "screen"}),
   awful.key({ dat.modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
      {description = "focus the previous screen", group = "screen"}),
   awful.key({ dat.modkey,           }, "u", awful.client.urgent.jumpto,
      {description = "jump to urgent client", group = "client"}),
   awful.key({ dat.modkey,           }, "Tab",
      function ()
         awful.client.focus.history.previous()
         if client.focus then
            client.focus:raise()
         end
      end,
      {description = "go back", group = "client"}),
   -- Standard Programs
   awful.key({ dat.modkey}, "Return",
      utility.terminal_call(dat.tdrop_terminal_main_command),
      {description = "open a terminal", group = "launcher"}),
   awful.key({ dat.modkey, "Control" }, "r", awesome.restart,
      {description = "reload awesome", group = "awesome"}),
   awful.key({ dat.modkey, "Shift"   }, "q", awesome.quit,
      {description = "quit awesome", group = "awesome"}),
   awful.key({"Shift"}, keysym.prtsc, flameshot.invoke_gui,
      {description = "open screenshot editor"}),
   awful.key({}, keysym.prtsc, flameshot.invoke_screen,
      {description = "take screenshot of current screen"}),
   -- Window Management
   awful.key({ dat.modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
      {description = "decrease master width factor", group = "layout"}),
   awful.key({ dat.modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
      {description = "increase the number of master clients", group = "layout"}),
   awful.key({ dat.modkey, "Shift"   }, "=",     function () awful.tag.incnmaster(-1, nil, true) end,
      {description = "decrease the number of master clients", group = "layout"}),
   awful.key({ dat.modkey }, "space", function () awful.layout.set(awful.layout.suit.tile) end,
      {description = "select next", group = "layout"}),
   awful.key({ dat.modkey, "Shift" }, "space", function () awful.layout.set(awful.layout.suit.floating) end,
      {description = "select previous", group = "layout"}),
   awful.key({ dat.modkey, "Control" }, "n",
      function ()
         local c = awful.client.restore()
         -- Focus restored client
         if c then
            c:emit_signal(
               "request::activate", "key.unminimize", {raise = true}
            )
         end
      end,
      {description = "restore minimized", group = "client"}),
   -- Prompt
   awful.key({ dat.modkey }, "r", function () awful.spawn(dat.tdrop_terminal_main_command) end,
      {description = "run prompt", group = "launcher"}),

   awful.key({ dat.modkey }, "x",
      function ()
         -- TODO placeholder for a volatile command prompt
      end,
      {description = "lua execute prompt", group = "awesome"}),
   -- Menubar
   awful.key({ dat.modkey }, "p", function() awful.spawn(dat.rofi_drun_command) end,
      {description = "show rofi desktop menu", group = "launcher"}),
   awful.key({ dat.modkey }, "b",
      function ()
         local myscreen = awful.screen.focused()
         myscreen.mywibox.visible = not myscreen.mywibox.visible
      end,
      {description = "toggle statusbar"}
   )
   -- awful.key({modkey}, "y", function() awful.spawn("xdotool key ctrl+b o") end
   -- )
)

local clientkeys = gears.table.join(
   awful.key({ dat.modkey,           }, "f",
      function (c)
         c.fullscreen = not c.fullscreen
         c:raise()
         if c.fullscreen == true then
            c.border_width = dat.border_width
         else
            c.border_width = 0 end
      end,
      {description = "toggle fullscreen", group = "client"}),
   awful.key({dat.alt_l}, "F4", function (c) c:kill()                         end,
      {description = "close", group = "client"}),
   awful.key({ dat.modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
      {description = "toggle floating", group = "client"}),
   awful.key({ dat.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
      {description = "move to master", group = "client"}),
   awful.key({ dat.modkey,           }, "o",      function (c) c:move_to_screen()               end,
      {description = "move to screen", group = "client"}),
   awful.key({ dat.modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
      {description = "toggle keep on top", group = "client"}),
   awful.key({ dat.modkey,           }, "n",
      function (c)
         -- The client currently has the input focus, so it cannot be
         -- minimized, since minimized clients can't have the focus.
         c.minimized = true
      end ,
      {description = "minimize", group = "client"}),
   awful.key({ dat.modkey,           }, "m",
      function (c)
         c.maximized = not c.maximized
         c:raise()
      end ,
      {description = "(un)maximize", group = "client"}),
   awful.key({ dat.modkey, "Control" }, "m",
      function (c)
         c.maximized_vertical = not c.maximized_vertical
         c:raise()
      end ,
      {description = "(un)maximize vertically", group = "client"}),
   awful.key({ dat.modkey, "Shift"   }, "m",
      function (c)
         c.maximized_horizontal = not c.maximized_horizontal
         c:raise()
      end ,
      {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
   globalkeys = gears.table.join(
      globalkeys,
      -- View tag only.
      awful.key({ dat.modkey }, "#" .. i + 9,
         function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
               tag:view_only()
            end
         end,
         {description = "view tag #"..i, group = "tag"}),
      -- Toggle tag display.
      awful.key({ dat.modkey, "Control" }, "#" .. i + 9,
         function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
               awful.tag.viewtoggle(tag)
            end
         end,
         {description = "toggle tag #" .. i, group = "tag"}),
      -- Move client to tag.
      awful.key({ dat.modkey, "Shift" }, "#" .. i + 9,
         function ()
            if client.focus then
               local tag = client.focus.screen.tags[i]
               if tag then
                  client.focus:move_to_tag(tag)
               end
            end
         end,
         {description = "move focused client to tag #"..i, group = "tag"}),
      -- Toggle tag on focused client.
      awful.key({ dat.modkey, "Control", "Shift" }, "#" .. i + 9,
         function ()
            if client.focus then
               local tag = client.focus.screen.tags[i]
               if tag then
                  client.focus:toggle_tag(tag)
               end
            end
         end,
         {description = "toggle focused client on tag #" .. i, group = "tag"}),
      awful.key({dat.modkey}, "#", xprop,
         { description = "Check a window's properties with xprop"})
   )
end

local clientbuttons = gears.table.join(
   awful.button({ }, 1, function (c)
         c:emit_signal("request::activate", "mouse_click", {raise = true})
   end),
   awful.button({ dat.modkey }, 1, function (c)
         c:emit_signal("request::activate", "mouse_click", {raise = true})
         awful.mouse.client.move(c)
   end),
   awful.button({ dat.modkey }, 3, function (c)
         c:emit_signal("request::activate", "mouse_click", {raise = true})
         awful.mouse.client.resize(c)
   end)
)
-- Set keys
root.keys(globalkeys)
-- Prevnt focus stealing from new clients
awful.ewmh.add_activate_filter(function(client)
      local matched = gears.table.hasitem(dat.focus_blacklist, client.name) or
         gears.table.hasitem(dat.focus_blacklist, client.class)
      if matched then
         return false
      end
end, "ewmh")
awful.ewmh.add_activate_filter(function(client)
      local matched = gears.table.hasitem(dat.focus_blacklist, client.name) or
         gears.table.hasitem(dat.focus_blacklist, client.class)
      if matched then return false
      end
end, "rules")
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
   -- All clients will match this rule.
   { rule = { },
     properties = {
        border_width = dat.border_width,
        border_color  = beautiful.border_normal,
        focus = awful.client.focus.filter,
        raise = true,
        keys = clientkeys,
        buttons = clientbuttons,
        screen = awful.screen.preferred,
        placement = awful.placement.no_offscreen,
        size_hints_honor = false,
     }
   },
   -- Floating clients.
   { rule_any = {
        instance = {
           "DTA",  -- Firefox addon DownThemAll.
           "copyq",  -- Includes session name in class.
           "pinentry",
        },
        class = {
           "Arandr",
           "Blueman-manager",
           "Gpick",
           "Kruler",
           "MessageWin",  -- kalarm.
           "Sxiv",
           "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
           "Wpa_gui",
           "veromix",
           "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
           "Event Tester",  -- xev.
        },
        role = {
           "AlarmWindow",  -- Thunderbird's calendar.
           "ConfigManager",  -- Thunderbird's about:config.
           "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
   }, properties = { floating = true }
   },
   -- Groups
   -- Hide Annoying Origin Clients on start
   { rule = { name = "Origin" },
     properties = { minimized = true},
   },
   -- Fix Wine Application Sizing Issues
   { rule = { class = "*.exe" },
     properties = { floating = true }
   },
   -- Add titlebars to normal clients and dialogs
   { rule_any = {type = { "normal", "dialog" }
                }, properties = { titlebars_enabled = true }
   },
   -- App Specific Rules
   {
      rule = { class = "dolphin"},
      properties = {opacity = 0.95}
   },
   {
      rule = { class = "st-256color"},
      properties =
         {  maximized_horizontal = true,
            opacity = 0.95}
   },
   {
      rule = {class = "plasmashell"},
      properties = {
         sticky = true,
         -- Prevent plasmashell widgets filling the screen
         floating = true,
   }}
   -- Set Firefox to always map on the tag named "2" on screen 1.
   -- { rule = { class = "Firefox" },
   --   properties = { screen = 1, tag = "2" } },
}
-- Signals
-- Signal function to execute when a new client appears.
local function my_client_connect_signal(c)
   -- Set the windows at the slave,
   -- i.e. put it at the end of others instead of setting it master.
   -- if not awesome.startup then awful.client.setslave(c) end
   if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(c)
   end
   awful.titlebar.hide(c);
end
client.connect_signal("manage", my_client_connect_signal)
_G.flash_timer = 1          -- stub global
-- Aggressive rule templates
local function set_tags_all(client)
   -- client.set_tags
end
-- Custom Event Loop
--  Run in tandem with awesome's own event loop
local function tick()

end
awesome.connect_signal("refresh", tick)
-- | Final Startup Setup |

-- Switch to viewing accessible tags
awful.screen.connect_for_each_screen(function (x_screen)
      local first_tag = x_screen.tags[1]
      if first_tag then
         first_tag:view_only()
      end
end)
