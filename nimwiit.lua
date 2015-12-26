-- Boilerplate {{{
package.path = "?/init.lua;"..package.path
package.path = "lib/?.lua;"..package.path
package.path = "lib/?/init.lua;"..package.path
require "strict"
-- }}}

local Monitor   = require "xwii.Monitor"
local Interface = require "xwii.Interface"
local utils     = require "utils"

local mon = Monitor()

local motes = {}

print("Polling for wiimotes...")
while true do
	local mote = mon:poll()
	if (mote == nil) then break end
	table.insert(motes, mote)
	local idx = #motes
	if mote then
		for _,led in pairs{1,2,3,4} do
			mote:set_led(led, false)
		end
		if idx < 5 then
			mote:set_led(idx, true)
		else
			mote:set_leds({false,true,false,true})
		end
	end
end
print("Found wiimotes: ",#motes)


mon:destroy()
print("All done")

