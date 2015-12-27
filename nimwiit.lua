-- Boilerplate {{{
package.path = "?/init.lua;"..package.path
package.path = "lib/?.lua;"..package.path
package.path = "lib/?/init.lua;"..package.path
local inspect = require "inspect"
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

		print(idx , "Device type: ", mote:get_devtype())
		print(idx , "Device extensions: ", mote:get_extension())
	end
end
print("Found wiimotes: ",#motes)

-- FIXME : Add "global fd batch" thing so that they all can wait for fd.
while #motes > 0 do
	for i,mote in pairs(motes) do
		local ev = mote:dispatch_event()
		if ev then
			if ev.ev_name == 'KEY' then
				print(i, inspect(ev))
			end
		else
			--print("...")
			utils.usleep(20000)
		end
	end
end

mon:destroy()
print("All done")

