--- Interface
-- http://dvdhrm.github.io/xwiimote/api/group__device.html

local ffi   = require "ffi"
local class = require "30log"
local Interface = class("Interface")

-- ffi imports {{{
ffi.cdef [[
	char *strerror(int errnum);
]]
ffi.cdef [[
struct xwii_iface;
enum xwii_iface_type {
	/** Core interface */
	XWII_IFACE_CORE			= 0x000001,
	/** Accelerometer interface */
	XWII_IFACE_ACCEL		= 0x000002,
	/** IR interface */
	XWII_IFACE_IR			= 0x000004,

	/** MotionPlus extension interface */
	XWII_IFACE_MOTION_PLUS		= 0x000100,
	/** Nunchuk extension interface */
	XWII_IFACE_NUNCHUK		= 0x000200,
	/** ClassicController extension interface */
	XWII_IFACE_CLASSIC_CONTROLLER	= 0x000400,
	/** BalanceBoard extension interface */
	XWII_IFACE_BALANCE_BOARD	= 0x000800,
	/** ProController extension interface */
	XWII_IFACE_PRO_CONTROLLER	= 0x001000,
	/** Drums extension interface */
	XWII_IFACE_DRUMS		= 0x002000,
	/** Guitar extension interface */
	XWII_IFACE_GUITAR		= 0x004000,

	/** Special flag ORed with all valid interfaces */
	XWII_IFACE_ALL			= XWII_IFACE_CORE |
					  XWII_IFACE_ACCEL |
					  XWII_IFACE_IR |
					  XWII_IFACE_MOTION_PLUS |
					  XWII_IFACE_NUNCHUK |
					  XWII_IFACE_CLASSIC_CONTROLLER |
					  XWII_IFACE_BALANCE_BOARD |
					  XWII_IFACE_PRO_CONTROLLER |
					  XWII_IFACE_DRUMS |
					  XWII_IFACE_GUITAR,
	/** Special flag which causes the interfaces to be opened writable */
	XWII_IFACE_WRITABLE		= 0x010000,
};

const char *xwii_get_iface_name(unsigned int iface);
enum xwii_led {
	XWII_LED1 = 1,
	XWII_LED2 = 2,
	XWII_LED3 = 3,
	XWII_LED4 = 4,
};
int xwii_iface_new(struct xwii_iface **dev, const char *syspath);
void xwii_iface_ref(struct xwii_iface *dev);
void xwii_iface_unref(struct xwii_iface *dev);
const char *xwii_iface_get_syspath(struct xwii_iface *dev);
int xwii_iface_get_fd(struct xwii_iface *dev);
int xwii_iface_watch(struct xwii_iface *dev, bool watch);
int xwii_iface_open(struct xwii_iface *dev, unsigned int ifaces);
void xwii_iface_close(struct xwii_iface *dev, unsigned int ifaces);
unsigned int xwii_iface_opened(struct xwii_iface *dev);
unsigned int xwii_iface_available(struct xwii_iface *dev);
int xwii_iface_poll(struct xwii_iface *dev, struct xwii_event *ev);
int xwii_iface_dispatch(struct xwii_iface *dev, struct xwii_event *ev,
			size_t size);
int xwii_iface_rumble(struct xwii_iface *dev, bool on);
int xwii_iface_get_led(struct xwii_iface *dev, unsigned int led, bool *state);
int xwii_iface_set_led(struct xwii_iface *dev, unsigned int led, bool state);
int xwii_iface_get_battery(struct xwii_iface *dev, uint8_t *capacity);
int xwii_iface_get_devtype(struct xwii_iface *dev, char **devtype);
int xwii_iface_get_extension(struct xwii_iface *dev, char **extension);
void xwii_iface_set_mp_normalization(struct xwii_iface *dev, int32_t x,
				     int32_t y, int32_t z, int32_t factor);
void xwii_iface_get_mp_normalization(struct xwii_iface *dev, int32_t *x,
				     int32_t *y, int32_t *z, int32_t *factor);

]]

-- Load in global namespace
local xwiimote = ffi.load("xwiimote", true)
-- Doing this since xwiimote is collected since I, using "shortcuts".
-- THIS IS PROBABLY AN ANTIPATTERN AND SHOULD BE CHECKED.
-- FIXME : Duration of xwiimote.

-- Shortcuts to the monitor functions
local _new                  = ffi.C.xwii_iface_new;
local _ref                  = ffi.C.xwii_iface_ref;
local _unref                = ffi.C.xwii_iface_unref;
local _get_syspath          = ffi.C.xwii_iface_get_syspath;
local _get_fd               = ffi.C.xwii_iface_get_fd;
local _watch                = ffi.C.xwii_iface_watch;
local _open                 = ffi.C.xwii_iface_open;
local _close                = ffi.C.xwii_iface_close;
local _opened               = ffi.C.xwii_iface_opened;
local _available            = ffi.C.xwii_iface_available;
--local _poll                 = ffi.C.xwii_iface_poll; -- Deprecated
local _dispatch             = ffi.C.xwii_iface_dispatch;
local _rumble               = ffi.C.xwii_iface_rumble;
local _get_led              = ffi.C.xwii_iface_get_led;
local _set_led              = ffi.C.xwii_iface_set_led;
local _get_battery          = ffi.C.xwii_iface_get_battery;
local _get_devtype          = ffi.C.xwii_iface_get_devtype;
local _get_extension        = ffi.C.xwii_iface_get_extension;
local _set_mp_normalization = ffi.C.xwii_iface_set_mp_normalization;
local _get_mp_normalization = ffi.C.xwii_iface_get_mp_normalization;
local XWII_IFACE_WRITABLE   = ffi.C.XWII_IFACE_WRITABLE

local strerror = ffi.C.strerror
local function err(num)
	return ffi.string(strerror(-1*num))
end

local function struct_iface_in()
	return ffi.typeof("struct xwii_iface*[1]")()
end
local function out_bool()
	return ffi.typeof("bool[1]")()
end
local function out_char()
	return ffi.typeof("char*[1]")()
end
-- }}}

function Interface:init(path)
	assert(path, "No path given for Interface to init.")
	local x = {}
	local iface = struct_iface_in()
	local ret = nil
	ret = _new(iface, path)
	assert(ret == 0, "Cannot create xwii_iface '"..path.."'. "..err(ret))
	self._iface = iface[0]

	-- FIXME : Add watching to watch for all (new or removed) interfaces.
	ret = _open(self._iface,
		bit.bor(_available(self._iface), XWII_IFACE_WRITABLE))
	--assert(ret == 0, "Cannot open xwii_iface '"..path.."'. "..err(ret))
end

-- devtype {{{
function Interface:get_devtype()
	local p_devtype = out_char()
	local ret = _get_devtype(self._iface, p_devtype)
	assert(ret == 0, "Cannot read devtype..., "..err(ret))
	local devtype = ffi.string(p_devtype[0])
	return devtype
end
-- }}}

-- LEDS {{{
function Interface:get_leds()
	local leds = {}
	for _,led in ipairs({1,2,3,4}) do
		local out = out_bool()
		local ret = _get_led(self._iface, led, out)
		assert(ret == 0, "Cannot read led state..., "..err(ret))
		leds[led] = out[0]
	end
	return leds
end

function Interface:set_led(led, state)
	assert(led>0 and led<5, "Invalid range for led in set_led.")
	assert(state == true or state == false, "Invalid state in set_led.")
	local ret = _set_led(self._iface, led, state)
	assert(ret == 0, "Cannot set led state..., "..err(ret))
end

function Interface:set_leds(leds)
	assert(#leds < 5, "Too many states given to set_leds.")
	for led,state in ipairs(leds) do
		self:set_led(led,state)
	end
end
-- }}}

function Interface:destroy()
	_unref(self._iface)
end

return Interface
