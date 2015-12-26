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

function derp_leds(motes)
	local tot = 0
	local max = #motes * 4
	for _,mote in ipairs(motes) do
		mote:set_leds({false,false,false,false})
	end
	while true do
		for i=0,max-1 do
			tot = tot + 1
			local mote = math.floor(i/4 + 1)
			local idx  = i%4+1
			motes[mote]:set_led(idx,
				not motes[mote]:get_leds()[idx]
			)
			utils.usleep(20000)
		end
	end
end
derp_leds(motes)

mon:destroy()
