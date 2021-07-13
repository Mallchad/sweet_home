local naughty = require("naughty")
local debug = {}
-- Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
   naughty.notify({ preset = naughty.config.presets.critical,
                    title = "Oops, there were errors during startup!",
                    text = awesome.startup_errors })
end
function debug:new()
   debug.loud_fail = true
   return self
end
-- @param failure_description a string describing what happned with the failiure
function debug.silent_fail(failiure_description)
   assert(type(failiure_description == "string"),
          "'failiure_description is not of type string")
   if debug.loud_fail == true then
      local fail_notification = {}
      fail_notification.preset = naughty.config.presets.critical
      fail_notification.title = "A Silent Failiure Has Occured"
      fail_notification.text = failiure_description
      naughty.notify(fail_notification)
   end
end

return debug:new()
