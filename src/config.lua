-- Standard awesome library
-- Silence undeclared variable warnings, since they are loaded by awesome
local awesome   = _G.awesome
local root      = _G.root
local client    = _G.client
local screen    = _G.screen
-- Load Awesome Libraries
local gears     = require("gears")
local gtable    = require("gears.table")
local awful     = require("awful")
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
_G.database = require("src/database")
local dat = _G.database
local debug = require("src/debug")

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts =
   {
      awful.layout.suit.tile,
      awful.layout.suit.floating,
      -- awful.layout.suit.fair,
      -- awful.layout.suit.spiral.dwindle
   }
local function set_tags_all(q_client)
   local screen_tags = q_client.screen.tags
   q_client:tags(screen_tags)
end
local function kill_client_hard(doomed_client)
   local doomed_pid = tostring(doomed_client.pid)
   awful.spawn.easy_async("kill -KILL "..doomed_pid, utility.stub)
end
local function focus_cycle_screen(include_primary)
   include_primary = include_primary or false
   awful.screen.focus_relative(1)
   if screen.count() <= 2 and include_primary then
      -- Jump straight to the next non-primary screen
      for _, x_screen in screen:screen() do
         if x_screen.index ~= screen.primary.index then
            screen.focus(x_screen)
         end
      end
   elseif include_primary == false and
      -- Cycle through screens
      awful.screen.focused().index == screen.primary.index then
      awful.screen.focus_relative(1)
   end
end
local function focus_primary_screen()
   local primary_screen = screen.primary or nil
   if primary_screen then
      awful.screen.focus(primary_screen)
   else
      debug.silent_fail("Failed to find a primary screen")
   end
end
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
local function tdrop_terminal_volatile()
   utility.terminal_call(dat.tdrop_terminal_volatile_command)()
   _G.database.tdrop_terminal_main_auto_hide = true
end

-- Setup Tag tables
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
                -- awful.button({ }, 4, awful.tag.viewnext),
                -- awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}
-- {{{ Key bindings
local globalkeys = gears.table.join(
   awful.key({ dat.modkey }, "/",      hotkeys_popup.show_help,
      {description="show help", group="awesome"}),
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
   -- Layout manipulation
   awful.key({ dat.modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
      {description = "swap with next client by index", group = "client"}),
   awful.key({ dat.modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
      {description = "swap with previous client by index", group = "client"}),
   awful.key({ dat.modkey }, "a", focus_primary_screen,
      {description = "focus the primary screen", group = "screen"}),
   awful.key({ dat.modkey }, "d", focus_cycle_screen,
      {description = "cycle focus through non-priamry screens", group = "screen"}),
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
   awful.key({ dat.modkey, "Shift" }, "w",
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
   -- Standard Programs
   awful.key({ dat.modkey}, "Return",
      utility.terminal_call(dat.tdrop_terminal_main_command),
      {description = "open a terminal", group = "launcher"}),
   awful.key({ dat.modkey}, "=",
      utility.terminal_call(dat.calculator_tdrop_command),
      {description = "open a calculator", group = "launcher"}),
   awful.key({ dat.modkey, "Shift" }, "Return", tdrop_terminal_volatile,
      {description = "open an auto-closing terminal", group = "launcher"}),
   awful.key({ dat.modkey, "Control" }, "r", awesome.restart,
      {description = "reload awesome", group = "awesome"}),
   awful.key({"Shift"}, keysym.prtsc, flameshot.invoke_gui,
      {description = "open screenshot editor"}),
   awful.key({}, keysym.prtsc, flameshot.invoke_screen,
      {description = "take screenshot of current screen"}),
   -- Window Management
   awful.key({ dat.modkey }, "-",  function () awful.tag.incmwfact(-0.05) end,
      {description = "decrease master width factor", group = "layout"}),
   awful.key({ dat.modkey }, "=", function () awful.tag.incmwfact(10.05) end,
      {description = "decrease number of master clients", group = "layout"}),
   awful.key({ dat.modkey, "Shift" }, "-",  function () awful.tag.incnmaster( 1, nil, true) end,
      {description = "increase number of master clients", group = "layout"}),
   awful.key({ dat.modkey, "Shift" }, "=",     function () awful.tag.incnmaster(-1, nil, true) end,
      {description = "increase number of master clients", group = "layout"}),
   awful.key({ dat.modkey, "Shift" }, "q",
      function () awful.layout.set(awful.layout.suit.tile) end,
      {description = "set the layout tag to tiling", group = "layout"}),
   awful.key({ dat.modkey, "Shift" }, "e",
      function () awful.layout.set(awful.layout.suit.floating) end,
      {description = "set layout floating", group = "layout"}),
   awful.key({dat.modkey}, "#", xprop,
      { description = "Check a window's properties with xprop"}),
   awful.key({ dat.modkey }, "p", function() awful.spawn(dat.rofi_drun_command) end,
      {description = "show rofi app menu", group = "launcher"}),
   awful.key({ dat.modkey }, "s", function() awful.spawn(dat.rofi_drun_command) end,
      {description = "show rofi app menu (Windows alias)", group = "launcher"}),
   awful.key({ dat.modkey }, "space", utility.terminal_call(dat.rofi_window_command),
      {description = "show rofi window menu", group = "launcher"}),
   awful.key({ dat.modkey }, "r", utility.terminal_call(dat.media_playpause_command),
      {description = "playerctl play/pause media", group = "media"}),
   awful.key({ dat.modkey }, "y", utility.terminal_call(dat.media_previous_command),
      {description = "playerctl previous track", group = "media"}),
   awful.key({ dat.modkey }, "u", utility.terminal_call(dat.media_next_command),
      {description = "playerctl next track", group = "media"})
)

local clientkeys = gears.table.join(
   awful.key({ dat.modkey }, "f",
      function (c)
         c.fullscreen = not c.fullscreen
         c:raise()
         if c.fullscreen == true then
            c.border_width = dat.border_width
         else
            c.border_width = 0 end
      end,
      {description = "toggle fullscreen", group = "client"}),
   awful.key({ dat.modkey }, "g", set_tags_all,
      {description = "put client on all tags", group = "client"}),
   awful.key({dat.alt_l}, "F4", function (focused_client) focused_client:kill() end,
      {description = "close", group = "client"}),
   awful.key({dat.modkey}, "F4", kill_client_hard,
      {description = "close", group = "client"}),
   awful.key({ dat.modkey }, "q",
      function (focused_client) focused_client.floating = false end,
      {description = "tile client", group = "client"}),
   awful.key({ dat.modkey }, "e",
      function (focused_client) focused_client.floating = true end,
      {description = "float client", group = "client"}),
   awful.key({ dat.modkey, "Control" }, "Return",
      function (c) c:swap(awful.client.getmaster()) end,
      {description = "move to master", group = "client"}),
   awful.key({ dat.modkey }, "o",
      function (c) c:move_to_screen() end,
      {description = "move to screen", group = "client"}),
   awful.key({ dat.modkey }, "t",
      function (c) c.ontop = not c.ontop end,
      {description = "toggle keep on top", group = "client"}),
   awful.key({ dat.modkey }, "n",
      function (c)
         -- The client currently has the input focus, so it cannot be
         -- minimized, since minimized clients can't have the focus.
         c.minimized = true
      end ,
      {description = "minimize", group = "client"}),

   awful.key({ dat.modkey }, "w",
      function (c)
         -- The client currently has the input focus, so it cannot be
         -- minimized, since minimized clients can't have the focus.
         c.minimized = true
      end,
      {description = "minimize", group = "client"}),
   awful.key({ dat.modkey }, "m",
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
globalkeys = gears.table.join(
   globalkeys,
   -- View tag only
   awful.key({ dat.modkey }, "\\",
      function (_)
         awful.screen.connect_for_each_screen(
            function (x_screen)
               local tag = x_screen.tags[1]
               tag:view_only()
         end)
      end,
      {description = "visit tag #1 on all screens", group = "tag"}
   ),
   awful.key({ dat.modkey }, "z",
      function (_)
         awful.screen.connect_for_each_screen(
            function (x_screen)
               local tag = x_screen.tags[2]
               tag:view_only()
         end)
      end,
      {description = "visit tag #2 on all screens", group = "tag"}
   ),
   awful.key({ dat.modkey }, "x",
      function (_)
         awful.screen.connect_for_each_screen(
            function (x_screen)
               local tag = x_screen.tags[3]
               tag:view_only()
         end)
      end,
      {description = "visit tag #3 on all screens", group = "tag"}
   ),
   awful.key({ dat.modkey }, "c",
      function (_)
         awful.screen.connect_for_each_screen(
            function (x_screen)
               local tag = x_screen.tags[4]
               tag:view_only()
         end)
      end,
      {description = "visit tag #4 on all screens", group = "tag"}
   )
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
            local q_screen = awful.screen.focused()
            local tag = q_screen.tags[i]
            if tag then
               tag:view_only()
            end
         end,
         {description = "view tag #"..i, group = "tag"}),
      -- Toggle tag display.
      awful.key({ dat.modkey, "Control" }, "#" .. i + 9,
         function ()
            local q_screen = awful.screen.focused()
            local tag = q_screen.tags[i]
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
         {description = "toggle focused client on tag #" .. i, group = "tag"})
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
awful.ewmh.add_activate_filter(function(q_client)
      local matched = gears.table.hasitem(dat.focus_blacklist, q_client.name) or
         gears.table.hasitem(dat.focus_blacklist, q_client.class)
      if matched then
         return false
      end
end, "ewmh")
awful.ewmh.add_activate_filter(function(q_client)
      local matched = gears.table.hasitem(dat.focus_blacklist, q_client.name) or
         gears.table.hasitem(dat.focus_blacklist, q_client.class)
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
      }
   },
   {
      rule = {class = "krunner"},
      properties = {
         sticky = true,
         -- Prevent krunner widgets filling the screen
         floating = true,
      }
   }
   -- Set Firefox to always map on the tag named "2" on screen 1.
   -- { rule = { class = "Firefox" },
   --   properties = { screen = 1, tag = "2" } },
}

-- Theme Config
naughty.config.defaults.fg              = dat.widget_fg_color
naughty.config.defaults.bg              = dat.widget_bg_color
naughty.config.defaults.font            = dat.notification_font
naughty.config.defaults.border_width    = dat.border_width
naughty.config.defaults.border_width    = dat.border_width

-- Notification Config
naughty.config.defaults.timeout         = dat.border_width

-- Signals
-- Signal function to execute when a new client appears.
local function new_client_setup(new_client)
   -- Apply some default variables metadata
   new_client.metadata = {}
   -- Set the windows at the slave,
   -- i.e. put it at the end of others instead of setting it master.
   -- if not awesome.startup then awful.client.setslave(c) end
   if awesome.startup
      and not new_client.size_hints.user_position
      and not new_client.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(new_client)
   end
   awful.titlebar.hide(new_client);
   if new_client.name == dat.tdrop_terminal_main_wm_name then
      -- A volatile terminal has been connected
      if _G.database.tdrop_terminal_main_auto_hide == true then
         new_client.metadata.auto_hide = true
      else
         new_client.metadata.auto_hide = false
      end
      if new_client.metadata.auto_hide_signal_connected == nil then
         new_client.metadata.auto_hide_signal_connected = true
         new_client:connect_signal("unfocus", utility.hide_client_callback)
      end
   end
end
local function focused_client_setup(focused_client)
   if focused_client.metadata == nil then
      focused_client.metadata = {}
   end
   if focused_client.name == dat.tdrop_terminal_main_wm_name and
      _G.database.tdrop_terminal_main_auto_hide == true then
      -- A volatile terminal has been connected
      focused_client.metadata.auto_hide = true
   end
end
local function raised_client_update(raised_client)
   if raised_client.name == dat.tdrop_terminal_main_wm_name then
      -- A volatile terminal has been raised
      client.focus = raised_client
   end
end
client.connect_signal("manage", new_client_setup)
client.connect_signal("focus", focused_client_setup)
client.connect_signal("raised", raised_client_update)
-- Aggressive rule templates
-- Switch to viewing accessible tags
-- | Final Startup Setup |
awful.screen.connect_for_each_screen(function (x_screen)
      local first_tag = x_screen.tags[1]
      if first_tag then
         first_tag:view_only()
      end
end)
