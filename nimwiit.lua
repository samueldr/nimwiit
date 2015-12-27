-- Boilerplate {{{
package.path = "?/init.lua;"..package.path
package.path = "lib/?.lua;"..package.path
package.path = "lib/?/init.lua;"..package.path
local inspect = require "inspect"
require "strict"
-- }}}

local function print_help()
	print([[
	Usage: luajit nimwiit.lua [idx]
	Where idx is a valid index.
	To view the list, simply use without arguments.
	]])
end

local args = {...}
local idx = nil
if #args > 0 then
	if args[1] == "--help" or args[1] == "-h" then
		print_help()
		os.exit(0)
	end
	idx = tonumber(args[1])
end

local Monitor   = require "xwii.Monitor"
local Interface = require "xwii.Interface"
local utils     = require "utils"
local JoyDevice = require "JoyDevice"

local mon = Monitor()
local motes = {}
print("Polling for Wiimotes...")
while true do
	local idx = mon:poll()
	if (idx == nil) then break end
	table.insert(motes, idx)
end

if not idx or idx < 1 then
	print("Found Wiiidxs: ".. #motes)
	for i,idx in pairs(motes) do
		print(' → #'.. i..": "..idx)
	end
	os.exit(0)
end

if idx > #motes then
	print("Could not use mote "..idx..", only "..#motes.." are available.")
	os.exit(1)
end
mon:destroy()

if idx then
	local device = JoyDevice()
	local mote = Interface(motes[idx])
	for _,led in pairs{1,2,3,4} do
		mote:set_led(led, false)
	end
	if idx < 5 then
		mote:set_led(idx, true)
	else
		mote:set_leds({false,true,false,true})
	end
	print("Device type: ", mote:get_devtype())
	print("Device extensions: ", mote:get_extension())

	while true do
	local ev = mote:dispatch_event()
		if ev then
			if ev.ev_name == 'KEY' then
				if ev.key.code > 3 then
					if ev.key.state == 1 then
						device:button_press(device.buttons['BTN_'..ev.key.code-3])
					else
						device:button_release(device.buttons['BTN_'..ev.key.code-3])
					end
				else
					local direction = ev.key.name
					-- To rotate the joystick 90°
					if     direction == 'LEFT' then direction = 'DOWN'
					elseif direction == 'UP' then direction = 'LEFT'
					elseif direction == 'RIGHT' then direction = 'UP'
					elseif direction == 'DOWN' then direction = 'RIGHT'
					else  end
					if ev.key.state == 1 then
						device:direction_press(direction)
					else
						device:direction_release(direction)
					end
				end
			elseif ev.ev_name == 'WATCH' then
				print(inspect(ev))
				-- Assumes 0 is bitmask of nothing connected.
				-- When adding hotplugging, this should handle a disconnection more gracefully.
				if ev.available == 0 then
					print("Wiimote has been disconnected.")
					os.exit(0)
				end
			else
				--print(ev.ev_name)
			end
		else
			--print("...")
			-- Don't burn that CPU.
			utils.usleep(20000)
		end
	end
end
