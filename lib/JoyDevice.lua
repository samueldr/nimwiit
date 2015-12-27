--- JoyDevice
-- Implements a virtual joystick, using uinput.

local utils = require "utils"
local ffi = require "ffi"
local class = require "30log"

-- Buttons {{{
local buttons = {}
local function define_button(name, value)
	while type(value) == "string" do
		value = buttons[value]
	end
	ffi.cdef("static const int "..name.." = "..value..";")
	buttons[name] = ffi.C[name]
end
define_button("BTN_MISC", 0x100)
define_button("BTN_0", 0x100)
define_button("BTN_1", 0x101)
define_button("BTN_2", 0x102)
define_button("BTN_3", 0x103)
define_button("BTN_4", 0x104)
define_button("BTN_5", 0x105)
define_button("BTN_6", 0x106)
define_button("BTN_7", 0x107)
define_button("BTN_8", 0x108)
define_button("BTN_9", 0x109)
define_button("BTN_MOUSE", 0x110)
define_button("BTN_LEFT", 0x110)
define_button("BTN_RIGHT", 0x111)
define_button("BTN_MIDDLE", 0x112)
define_button("BTN_SIDE", 0x113)
define_button("BTN_EXTRA", 0x114)
define_button("BTN_FORWARD", 0x115)
define_button("BTN_BACK", 0x116)
define_button("BTN_TASK", 0x117)
define_button("BTN_JOYSTICK", 0x120)
define_button("BTN_TRIGGER", 0x120)
define_button("BTN_THUMB", 0x121)
define_button("BTN_THUMB2", 0x122)
define_button("BTN_TOP", 0x123)
define_button("BTN_TOP2", 0x124)
define_button("BTN_PINKIE", 0x125)
define_button("BTN_BASE", 0x126)
define_button("BTN_BASE2", 0x127)
define_button("BTN_BASE3", 0x128)
define_button("BTN_BASE4", 0x129)
define_button("BTN_BASE5", 0x12a)
define_button("BTN_BASE6", 0x12b)
define_button("BTN_DEAD", 0x12f)
define_button("BTN_GAMEPAD", 0x130)
define_button("BTN_SOUTH", 0x130)
define_button("BTN_A", "BTN_SOUTH")
define_button("BTN_EAST", 0x131)
define_button("BTN_B", "BTN_EAST")
define_button("BTN_C", 0x132)
define_button("BTN_NORTH", 0x133)
define_button("BTN_X", "BTN_NORTH")
define_button("BTN_WEST", 0x134)
define_button("BTN_Y", "BTN_WEST")
define_button("BTN_Z", 0x135)
define_button("BTN_TL", 0x136)
define_button("BTN_TR", 0x137)
define_button("BTN_TL2", 0x138)
define_button("BTN_TR2", 0x139)
define_button("BTN_SELECT", 0x13a)
define_button("BTN_START", 0x13b)
define_button("BTN_MODE", 0x13c)
define_button("BTN_THUMBL", 0x13d)
define_button("BTN_THUMBR", 0x13e)
define_button("BTN_DIGI", 0x140)
define_button("BTN_TOOL_PEN", 0x140)
define_button("BTN_TOOL_RUBBER", 0x141)
define_button("BTN_TOOL_BRUSH", 0x142)
define_button("BTN_TOOL_PENCIL", 0x143)
define_button("BTN_TOOL_AIRBRUSH", 0x144)
define_button("BTN_TOOL_FINGER", 0x145)
define_button("BTN_TOOL_MOUSE", 0x146)
define_button("BTN_TOOL_LENS", 0x147)
define_button("BTN_TOOL_QUINTTAP", 0x148)
define_button("BTN_TOUCH", 0x14a)
define_button("BTN_STYLUS", 0x14b)
define_button("BTN_STYLUS2", 0x14c)
define_button("BTN_TOOL_DOUBLETAP", 0x14d)
define_button("BTN_TOOL_TRIPLETAP", 0x14e)
define_button("BTN_TOOL_QUADTAP", 0x14f)
define_button("BTN_WHEEL", 0x150)
define_button("BTN_GEAR_DOWN", 0x150)
define_button("BTN_GEAR_UP", 0x151)
define_button("BTN_DPAD_UP", 0x220)
define_button("BTN_DPAD_DOWN", 0x221)
define_button("BTN_DPAD_LEFT", 0x222)
define_button("BTN_DPAD_RIGHT", 0x223)
define_button("BTN_TRIGGER_HAPPY", 0x2c0)
define_button("BTN_TRIGGER_HAPPY1", 0x2c0)
define_button("BTN_TRIGGER_HAPPY2", 0x2c1)
define_button("BTN_TRIGGER_HAPPY3", 0x2c2)
define_button("BTN_TRIGGER_HAPPY4", 0x2c3)
define_button("BTN_TRIGGER_HAPPY5", 0x2c4)
define_button("BTN_TRIGGER_HAPPY6", 0x2c5)
define_button("BTN_TRIGGER_HAPPY7", 0x2c6)
define_button("BTN_TRIGGER_HAPPY8", 0x2c7)
define_button("BTN_TRIGGER_HAPPY9", 0x2c8)
define_button("BTN_TRIGGER_HAPPY10", 0x2c9)
define_button("BTN_TRIGGER_HAPPY11", 0x2ca)
define_button("BTN_TRIGGER_HAPPY12", 0x2cb)
define_button("BTN_TRIGGER_HAPPY13", 0x2cc)
define_button("BTN_TRIGGER_HAPPY14", 0x2cd)
define_button("BTN_TRIGGER_HAPPY15", 0x2ce)
define_button("BTN_TRIGGER_HAPPY16", 0x2cf)
define_button("BTN_TRIGGER_HAPPY17", 0x2d0)
define_button("BTN_TRIGGER_HAPPY18", 0x2d1)
define_button("BTN_TRIGGER_HAPPY19", 0x2d2)
define_button("BTN_TRIGGER_HAPPY20", 0x2d3)
define_button("BTN_TRIGGER_HAPPY21", 0x2d4)
define_button("BTN_TRIGGER_HAPPY22", 0x2d5)
define_button("BTN_TRIGGER_HAPPY23", 0x2d6)
define_button("BTN_TRIGGER_HAPPY24", 0x2d7)
define_button("BTN_TRIGGER_HAPPY25", 0x2d8)
define_button("BTN_TRIGGER_HAPPY26", 0x2d9)
define_button("BTN_TRIGGER_HAPPY27", 0x2da)
define_button("BTN_TRIGGER_HAPPY28", 0x2db)
define_button("BTN_TRIGGER_HAPPY29", 0x2dc)
define_button("BTN_TRIGGER_HAPPY30", 0x2dd)
define_button("BTN_TRIGGER_HAPPY31", 0x2de)
define_button("BTN_TRIGGER_HAPPY32", 0x2df)
define_button("BTN_TRIGGER_HAPPY33", 0x2e0)
define_button("BTN_TRIGGER_HAPPY34", 0x2e1)
define_button("BTN_TRIGGER_HAPPY35", 0x2e2)
define_button("BTN_TRIGGER_HAPPY36", 0x2e3)
define_button("BTN_TRIGGER_HAPPY37", 0x2e4)
define_button("BTN_TRIGGER_HAPPY38", 0x2e5)
define_button("BTN_TRIGGER_HAPPY39", 0x2e6)
define_button("BTN_TRIGGER_HAPPY40", 0x2e7)
-- }}}

-- uinput ffi {{{
ffi.cdef [[
	// #defines converted to const ints, from input.h
	static const int O_WRONLY = 1;
	static const int O_NONBLOCK = 2048;
	static const int EV_SYN = 0;
	static const int EV_KEY = 1;
	static const int EV_REL = 2;
	static const int EV_ABS = 3;
	static const int REL_X = 0;
	static const int REL_Y = 1;
	static const int ABS_X = 0;
	static const int ABS_Y = 1;
	static const int KEY_LEFTSHIFT = 42;
	static const int KEY_A = 30;


	// uinput bus types
	static const int BUS_USB = 3;

	// uinput defines
	// TODO : Find a way to /compute/ those.
	static const int UI_SET_EVBIT  = 1074025828;
	static const int UI_SET_KEYBIT = 1074025829;
	static const int UI_SET_RELBIT = 1074025830;
	static const int UI_SET_ABSBIT = 1074025831;

	static const int UI_DEV_CREATE  = 21761;
	static const int UI_DEV_DESTROY = 21762;

	struct input_id {
		__u16 bustype;
		__u16 vendor;
		__u16 product;
		__u16 version;
	};
	struct uinput_user_dev {
		char name[80];
		struct input_id id;
		__u32 ff_effects_max;
		__s32 absmax[64];
		__s32 absmin[64];
		__s32 absfuzz[64];
		__s32 absflat[64];
	};
	struct input_event {
		struct timeval time;
		__u16 type;
		__u16 code;
		__s32 value;
	};
]]
-- }}}
-- Importing in local scope {{{
local O_WRONLY       = ffi.C.O_WRONLY
local O_NONBLOCK     = ffi.C.O_NONBLOCK

local EV_KEY         = ffi.C.EV_KEY
local EV_SYN         = ffi.C.EV_SYN
local EV_REL         = ffi.C.EV_REL
local EV_ABS         = ffi.C.EV_ABS

local UI_SET_EVBIT   = ffi.C.UI_SET_EVBIT
local UI_SET_KEYBIT  = ffi.C.UI_SET_KEYBIT
local UI_SET_RELBIT  = ffi.C.UI_SET_RELBIT
local UI_SET_ABSBIT  = ffi.C.UI_SET_ABSBIT

local UI_DEV_CREATE  = ffi.C.UI_DEV_CREATE
local UI_DEV_DESTROY = ffi.C.UI_DEV_DESTROY

local KEY_LEFTSHIFT  = ffi.C.KEY_LEFTSHIFT
local KEY_A          = ffi.C.KEY_A

local REL_X          = ffi.C.REL_X
local REL_Y          = ffi.C.REL_Y
local ABS_X          = ffi.C.ABS_X
local ABS_Y          = ffi.C.ABS_Y

local BUS_USB        = ffi.C.BUS_USB

-- }}}

local ioctl = utils.ioctl
local write = utils.write

local JoyDevice = class("JoyDevice")

function JoyDevice:init()
	print("Opening /dev/uinput...")
	local fd = ffi.C.open("/dev/uinput", bit.bor(O_WRONLY, O_NONBLOCK))
	if (fd < 0) then
		print("Failed to open uinput file #{fd}")
		os.exit(1)
	end
	self._fd = fd
	print("... opened.")
	self:prepare_joystick()
end

function JoyDevice:prepare_joystick()
	print("Configuring uinput...")
	assert(0 <= ioctl(self._fd, UI_SET_EVBIT,  EV_SYN))
	assert(0 <= ioctl(self._fd, UI_SET_EVBIT,  EV_KEY))
	-- Buttons
	self.buttons = {}
	for i=1,7 do
		local val = buttons['BTN_'..i]
		assert(0 <= ioctl(self._fd, UI_SET_KEYBIT, val))
		self.buttons['BTN_'..i] = val
	end
	-- Absolute axes
	assert(0 <= ioctl(self._fd, UI_SET_EVBIT,  EV_ABS))
	assert(0 <= ioctl(self._fd, UI_SET_ABSBIT, ABS_X))
	assert(0 <= ioctl(self._fd, UI_SET_ABSBIT, ABS_Y))

	local device = ffi.new("struct uinput_user_dev")
	device.name = "NimWiit input device."
	device.id.bustype = BUS_USB
	device.id.version = 1
	device.id.vendor  = 1
	device.id.product = 1
	device.absmin[ABS_X] = -255;
	device.absmax[ABS_X] = 255;
	device.absmin[ABS_Y] = -255;
	device.absmax[ABS_Y] = 255;
	assert(0 <= write(self._fd, device))
	assert(0 <= ioctl(self._fd, UI_DEV_CREATE))
	print("... finished configuring. Device should be ready")
end

function JoyDevice:send_event(ev_type, code, value)
	local ev = ffi.new("struct input_event")
	if (ev_type) then ev.type  = ev_type end
	if (code)    then ev.code  = code end
	if (value)   then ev.value = value end
	assert(0 <= write(self._fd, ev))
end

function JoyDevice:button_press(button)
	self:send_event(EV_KEY, button, 1)
	self:send_event(EV_SYN)
end
function JoyDevice:button_release(button)
	self:send_event(EV_KEY, button, 0)
	self:send_event(EV_SYN)
end

function JoyDevice:direction_press(direction)
	local axis = ABS_Y
	if direction == 'LEFT' or direction == 'RIGHT' then
		axis = ABS_X
	end
	local value = 255
	if direction == 'LEFT' or direction == 'UP' then
		value = -value
	end
	self:send_event(EV_ABS, axis, value)
	self:send_event(EV_SYN)
end
function JoyDevice:direction_release(direction)
	local axis = ABS_Y
	if direction == 'LEFT' or direction == 'RIGHT' then
		axis = ABS_X
	end
	self:send_event(EV_ABS, axis, 0)
	self:send_event(EV_SYN)
end

function JoyDevice:destroy()
	ioctl(self._fd, UI_DEV_DESTROY)
end



-- -- Mouse move
-- for k,v in pairs{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20} do
-- 	send_event(EV_REL, REL_X, v)
-- 	send_event(EV_SYN)
-- end
-- 

return JoyDevice
