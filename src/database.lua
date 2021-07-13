local util = require("src/utility")
local debug = require("src/debug")
local gears = require("gears")
-- Sanity Aliases
local xdg_config = gears.filesystem.get_xdg_config_home
-- Main Module
_G.keysym =
   {
      prtsc = "#107"
   }
local database =
   {
      alt_l = nil,
      super_l = nil,
      terminal = nil,
      editor = nil,
      editor_command = nil,
      tdrop_floating_args = nil,
      tdrop_terminal_command = nil,
      rofi_global_args = nil,
      rofi_drun_command = nil,
      flameshot_folder = nil,
      flameshot_gui_comamnd = nil,
      flameshot_screencap_command = nil,
      border_width = nil,
      border_color = nil,
      widget_background_color = nil,
      notification_font_name = nil,
      notification_font_size = nil,
      notification_font = nil,
      focus_blacklist = {},
      autostart_list = {},
      tick_functions = {},
      tick_objects = {},
   }
-- Global Variables
-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
function database:new()
   -- Constants
   self.alt_l = "Mod1"
   -- self.hyper_l = "Mod5"
   -- self.meta_l = "Mod3"
   self.super_l = "Mod4"
   self.modkey = self.super_l
   -- Variables
   -- This is used later as the default terminal and editor to run.
   self.terminal = os.getenv("TERMINAL") or "alacritty"
   self.editor = os.getenv("EDITOR") or "vim"
   self.editor_command = self.terminal.." -e "..self.editor
   self.tdrop_floating_args = "--monitor-aware --auto-detect-wm --width 100% --height 100% --pointer-monitor-detection"
   self.tdrop_tiling_args = "--monitor-aware --pointer-monitor-detection"
   self.tdrop_terminal_main_command = util.build_cmd("tdrop", self.tdrop_tiling_args, self.terminal)
   self.rofi_global_args = "-show-icons -width 30 -font 'MesloLGS NF 16'"
   self.rofi_drun_command = util.build_cmd("rofi", self.rofi_global_args, "-show drun")
   self.flameshot_folder = os.getenv("HOME").."/pictures/screenshots"
   self.flameshot_gui_command = "flameshot gui  --path "..self.flameshot_folder
   self.flameshot_screencap_command = "flameshot screen --clipboard --path "..self.flameshot_folder
   if (gears.filesystem.is_dir(self.flameshot_folder) == false) then
      self.screenshot_folder = nil
      debug.silent_fail("'screenshot_folder' directory could not be found")
   end
   if not self.screenshot_folder then
      self.gui_command = "flameshot gui --clipboard"
      self.screen_command = "flameshot screen --clipboard"
   end
   self.border_width     = 0
   self.border_color     = "#11111100"
   self.widget_background_color = "#12171eEA"
   self.notification_font_name  = "MesloLGS NF"
   self.notification_font_size  = 12
   self.notification_font       =
      self.notification_font_name.." "..tostring(self.notification_font_size)
   self.focus_blacklist =
      {
         "UnrealEditor",
         "Origin"
      }
   self.autostart_list = {
      xdg_config().."/autostart/awesome_startup",
      xdg_config().."/mallchad/xorg-start-hook.lua"
   }
   self.tick_functions = {}
   self.tick_objects = {}
   return self
end
---
-- Ths is an alias for for database:new
database.reset = database.new
return database:new()
