local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local utility = require("src/utility")
-- local awesome = require("core/xawesome")
-- local test_background = load("/home/mallchad/userdata/creative/fun/avatar_burned.png")
test_popup = awful.popup {
   widget = awful.widget.tasklist {
      screen   = screen[1],
      filter   = awful.widget.tasklist.filter.allscreen,
      buttons  = tasklist_buttons,
      style    = {
         shape = gears.shape.rounded_rect,
      },
      layout   = {
         spacing = 5,
         forced_num_rows = 2,
         layout = wibox.layout.grid.horizontal
      },
      widget_template = {
         {
            {
               id     = 'clienticon',
               widget = awful.widget.clienticon,
            },
            margins = 4,
            widget  = wibox.container.margin,
         },
         id              = 'background_role',
         forced_width    = 400,
         forced_height   = 400,
         x = 1920/2.2,
         y = 1080/2.2,
         widget          = wibox.container.background,
         create_callback = function(self, c, index, objects) --luacheck: no unused
            self:get_children_by_id('clienticon')[1].client = c
         end,
      },
   },
   border_color = '#777777',
   border_width = 2,
   ontop        = true,
   placement    = awful.placement.centered,
   shape        = gears.shape.rounded_rect
}
print("made popup")
local buttons_example = wibox ({
      visible = true,
      bg = '#2a2e32',
      fg = '#EEE',
      ontop = true,
      width = 200,
      height = 100,
      -- Center box around origin
      x = (1920/2)-(200/2),
      y = (1080/2)-(100/2),
      text = [[SOME REALLY FUCKING LONG STRING OF ]],
      bgimage = test_background,
      shape = function(cr, width, height)
         gears.shape.rounded_rect(cr, width, height, 3)
      end,
      widget = wibox.widget.textbox("hmmm")
})
local button = buttons_example
button:buttons(gears.table.join(
                  button:buttons(),
                  awful.button({}, 1, nil, function ()
                        print("Mouse was clicked")
                  end)
))
local generic_box = awful.widget.launcher:new()

-- utility.detect_window_properties = function()
--    if lock.detect_window_properties == false then
--       lock.detect_window_properties = true
--       awful.spawn.easy_async(
--          "xprop",
--          function (stdout, stderr, reason, exit_code)
--             local buttons_example = wibox ({
--                   visible = true,
--                   bg = '#2a2e32',
--                   fg = '#EEE',
--                   ontop = true,
--                   height = 100,
--                   width = 200,
--                   x = 960,
--                   y = 400,
--                   text = [[SOME REALLY FUCKING LONG STRING OF ]],
--                   bgimage = test_background,
--                   shape = function(cr, width, height)
--                      gears.shape.rounded_rect(cr, width, height, 3)
--                   end,
--                   widget = wibox.widget.textbox(stdout)
--             })
--             lock.detect_window_properties = false
--          end
--       )
--    end
-- end

-- local button = {} -- <- code examples go here

-- buttons_example:setup {
--    button,
--    valigh = 'center',
--    layout = wibox.container.place
-- }

-- awful.placement.top(buttons_example, { margins = {top = 40}, parent = awful.screen.focused()})
-- local button = wibox.widget{
--    {
--       {
--          text = "I'm a button!",
--          widget = wibox.widget.textbox
--       },
--       top = 4, bottom = 4, left = 8, right = 8,
--       widget = wibox.container.margin
--    },
--    bg = '#4C566A', -- basic
--    bg = '#00000000', --tranparent
--    shape_border_width = 1, shape_border_color = '#4C566A', -- outline
--    shape = function(cr, width, height)
--       gears.shape.rounded_rect(cr, width, height, 4)
--    end,
--    widget = wibox.container.background
-- }
lerp_result = lerp(50, 0, 100)
print(lerp_result)
gears.protected_call(function () print(_G.null_index)
end)
gears.debug.print_warning("This is a test warning")
