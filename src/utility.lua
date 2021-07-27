local string = require("string")
-- Silence some global variable warnings
local awful = require("awful")
local utility = {}
--- Convert a number to a float
-- Lua pretends that there is only one type, "number", but in reality there
-- actually distinct floating point and integer type numbers.
-- This can cause quite bad issues when working with numbers,
-- this functions allows for some determinism by being explicit about the kind
-- of number
_G.float = function (int)
   return int + 0e0
end
--- Linearly interpolate a value between min and max
-- @param progress how far as a 0-1 percentage between min and max to solve for
-- Only runs for single numbers
_G.lerp = function (progress, min, max)
   local distance = math.abs(max-min)
   local t = 1.0 / float(distance)
   return t * float(progress)
end
--- Mixing linear interpolation that returns the halfway point between two values
-- Only runs for single numbers
_G.mlerp = function (min, max)
   local distance = math.abs(max-min)
   local t = 1.0 / float(distance)
   return t * 0.5
end
function utility.create_key()

end
--- Convert a rgba table into a hexidecimal string prefixed with a hashtag '#'
_G.rgbatohex = function (rgba, byte_input)
   local use_byte_representation = byte_input or true
   local hexadecimal = '#'
   for _, channel in pairs(rgba) do
      local hex = ''
      local color = channel
      if use_byte_representation and color - 1 < 0 then
         color = color * 255
      end
      if (channel > 0) then
         local hex_index = math.fmod(channel, 16) + 1
         hex_index = math.floor(channel / 16)
         hex = string.sub('0123456789ABCDEF', hex_index, hex_index) .. hex
      end
      if (string.len(hex) == 0) then
         hex = '00'
      elseif (string.len(hex) == 1) then
         hex = '0' .. hex
      end
      hexadecimal = hexadecimal .. hex
   end

   return hexadecimal
end
--- Create a space seperated command from vargs
function utility.build_cmd(...)
   local vargs = {...}
   local command = ""
   for _, x_arg in pairs(vargs) do
      command = command.." "..x_arg
   end
   return command
end
--- Create a lambda for a command to be called on the terminal and returns it
function utility.terminal_call(command)
   return function () awful.spawn.easy_async(command,function() end) end
end
--- Create a lambda to call a command with a shell
function utility.shell_call(command)
   return function () awful.spawn_with_shell(command) end
end
-- Create a lambda for a callback to capture terminal output and return it
-- @param _metadata a table containing
function utility.terminal_callback(command)
   local callback = function (_stdout, _stderr, _exitreason, _exitcode)
      awful.spawn(command)
      local callback_return =
         {
            stdout = _stdout,
            stderr = _stderr,
            exitreason = _exitreason,
            exitcode = _exitcode,
         }
      return callback_return
   end
   return callback
end
function utility.hide_client_callback(sig_client)
   if sig_client.metadata.auto_hide == true then
      sig_client.minimized = true
   end
   -- Report that we successfully auto-hid at least one client
   -- also try to clean up if the client is minimized without unfocus
   _G.database.tdrop_terminal_main_auto_hide = false
   sig_client.metadata.auto_hide = false
end
-- A function that does nothing but can eat arguments and satify integer returns
function utility.stub(...)
   local _ = ...                -- silence unused variable warnings
   return 42
end
return utility
