-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
-- User Modules
require("src/config")
local dat = require("src/database")
TESTING = os.getenv("AWESOME_TEST")
if TESTING then
   pcall(function () require("tests/test") end)
end
-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal(
      "debug::error",
      function (err)
         -- Make sure we don't go into an endless error loop
         if in_error then return end
         in_error = true

         naughty.notify({ preset = naughty.config.presets.critical,
                          title = "Oops, an error happened!",
                          text = tostring(err) })
         in_error = false
   end)
end
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir().."default/theme.lua")
-- Startup
local function startup_apps()
   for _, x_executable in pairs(dat.autostart_list) do
      awful.spawn(x_executable)
   end
end
-- Don't let an app startup failiure stall the WM
pcall(startup_apps)
