--- Interface
-- http://dvdhrm.github.io/xwiimote/api/group__device.html

local ffi   = require "ffi"
local class = require "30log"
local Interface = class("Interface")

-- ffi imports {{{
-- Global C stuff {{{
ffi.cdef [[
	static const int EAGAIN = 11;
	static const int POLLIN = 1;
	static const int POLLPRI = 2;
	static const int POLLOUT = 4;
	struct pollfd {
		int fd;
		short int events;
		short int revents;
	};
	typedef unsigned long int nfds_t;
	int poll(struct pollfd fds[], nfds_t nfds, int timeout);
	char *strerror(int errnum);
	struct timeval {
		long tv_sec;
		long tv_usec;
	};
]]
local EAGAIN = ffi.C.EAGAIN
local POLLIN = ffi.C.POLLIN
local function poll(pfds, timeout)
	if not timeout or timeout < -1 then
		timeout = 0
	end
	local nfds = #pfds
	pfds = ffi.new("struct pollfd["..#pfds.."]", pfds)
	return ffi.C.poll(pfds, nfds, timeout)
end
local function struct_pollfd()
	return ffi.typeof("struct pollfd")()
end
-- }}}
-- Events {{{
ffi.cdef [[
enum xwii_event_types {
	XWII_EVENT_KEY,
	XWII_EVENT_ACCEL,
	XWII_EVENT_IR,
	XWII_EVENT_BALANCE_BOARD,
	XWII_EVENT_MOTION_PLUS,
	XWII_EVENT_PRO_CONTROLLER_KEY,
	XWII_EVENT_PRO_CONTROLLER_MOVE,
	XWII_EVENT_WATCH,
	XWII_EVENT_CLASSIC_CONTROLLER_KEY,
	XWII_EVENT_CLASSIC_CONTROLLER_MOVE,
	XWII_EVENT_NUNCHUK_KEY,
	XWII_EVENT_NUNCHUK_MOVE,
	XWII_EVENT_DRUMS_KEY,
	XWII_EVENT_DRUMS_MOVE,
	XWII_EVENT_GUITAR_KEY,
	XWII_EVENT_GUITAR_MOVE,
	XWII_EVENT_GONE,
	XWII_EVENT_NUM
};

//Key Event Identifiers
enum xwii_event_keys {
	XWII_KEY_LEFT,
	XWII_KEY_RIGHT,
	XWII_KEY_UP,
	XWII_KEY_DOWN,
	XWII_KEY_A,
	XWII_KEY_B,
	XWII_KEY_PLUS,
	XWII_KEY_MINUS,
	XWII_KEY_HOME,
	XWII_KEY_ONE,
	XWII_KEY_TWO,
	XWII_KEY_X,
	XWII_KEY_Y,
	XWII_KEY_TL,
	XWII_KEY_TR,
	XWII_KEY_ZL,
	XWII_KEY_ZR,

	XWII_KEY_THUMBL,
	XWII_KEY_THUMBR,

	XWII_KEY_C,
	XWII_KEY_Z,

	XWII_KEY_STRUM_BAR_UP,

	XWII_KEY_STRUM_BAR_DOWN,

	XWII_KEY_FRET_FAR_UP,
	XWII_KEY_FRET_UP,
	XWII_KEY_FRET_MID,
	XWII_KEY_FRET_LOW,
	XWII_KEY_FRET_FAR_LOW,

	XWII_KEY_NUM
};

/**
 * Key Event Payload
 *
 * A key-event always uses this payload.
 */
struct xwii_event_key {
	/** key identifier defined as enum xwii_event_keys */
	unsigned int code;
	/** key state copied from kernel (0: up, 1: down, 2: auto-repeat) */
	unsigned int state;
};

struct xwii_event_abs {
	int32_t x;
	int32_t y;
	int32_t z;
};

enum xwii_drums_abs {
	XWII_DRUMS_ABS_PAD,
	XWII_DRUMS_ABS_CYMBAL_LEFT,
	XWII_DRUMS_ABS_CYMBAL_RIGHT,
	XWII_DRUMS_ABS_TOM_LEFT,
	XWII_DRUMS_ABS_TOM_RIGHT,
	XWII_DRUMS_ABS_TOM_FAR_RIGHT,
	XWII_DRUMS_ABS_BASS,
	XWII_DRUMS_ABS_HI_HAT,
	XWII_DRUMS_ABS_NUM,
};

// /** Number of ABS values in an xwii_event_union */
// #define XWII_ABS_NUM 8

union xwii_event_union {
	struct xwii_event_key key;
	struct xwii_event_abs abs[8];
	uint8_t reserved[128];
};
]]
ffi.cdef [[
/**
 * Event Object
 *
 * Every event is reported via this structure.
 * Note that even though this object reserves some space, it may grow in the
 * future. It is not guaranteed to stay at this size. That's why functions
 * dealing with it always accept an additional size argument, which is used
 * for backwards-compatibility to not write beyond object-boundaries.
 */
struct xwii_event {
	/** timestamp when this event was generated (copied from kernel) */
	struct timeval time;
	/** event type ref xwii_event_types */
	unsigned int type;

	/** data payload */
	union xwii_event_union v;
};

// /**
//  * Test whether an IR event is valid
//  *
//  * If you receive an IR event, you can use this function on the first 4
//  * absolute motion payloads. It returns true iff the given slot currently tracks
//  * a valid IR source. false is returned if the slot is invalid and currently
//  * disabled (due to missing IR sources).
//  */
// static inline bool xwii_event_ir_is_valid(const struct xwii_event_abs *abs)
// {
// 	return abs->x != 1023 || abs->y != 1023;
// }
]]
-- }}}
-- Interface {{{
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
-- }}}

-- Load in global namespace
local xwiimote = ffi.load("xwiimote", true)
-- Doing this since xwiimote is collected since I, using "shortcuts".
-- THIS IS PROBABLY AN ANTIPATTERN AND SHOULD BE CHECKED.
-- FIXME : Duration of xwiimote.

-- Shortcuts to the monitor functions
local iface_new                  = ffi.C.xwii_iface_new;
local iface_ref                  = ffi.C.xwii_iface_ref;
local iface_unref                = ffi.C.xwii_iface_unref;
local iface_get_syspath          = ffi.C.xwii_iface_get_syspath;
local iface_get_fd               = ffi.C.xwii_iface_get_fd;
local iface_watch                = ffi.C.xwii_iface_watch;
local iface_open                 = ffi.C.xwii_iface_open;
local iface_close                = ffi.C.xwii_iface_close;
local iface_opened               = ffi.C.xwii_iface_opened;
local iface_available            = ffi.C.xwii_iface_available;
--local iface_poll                 = ffi.C.xwii_iface_poll; -- Deprecated
local iface_dispatch             = ffi.C.xwii_iface_dispatch;
local iface_rumble               = ffi.C.xwii_iface_rumble;
local iface_get_led              = ffi.C.xwii_iface_get_led;
local iface_set_led              = ffi.C.xwii_iface_set_led;
local iface_get_battery          = ffi.C.xwii_iface_get_battery;
local iface_get_devtype          = ffi.C.xwii_iface_get_devtype;
local iface_get_extension        = ffi.C.xwii_iface_get_extension;
local iface_set_mp_normalization = ffi.C.xwii_iface_set_mp_normalization;
local iface_get_mp_normalization = ffi.C.xwii_iface_get_mp_normalization;
local XWII_IFACE_WRITABLE   = ffi.C.XWII_IFACE_WRITABLE

local events_by_name = {}
local events = {}
for k,v in pairs
	{
		'KEY',
		'ACCEL',
		'IR',
		'BALANCE_BOARD',
		'MOTION_PLUS',
		'PRO_CONTROLLER_KEY',
		'PRO_CONTROLLER_MOVE',
		'WATCH',
		'CLASSIC_CONTROLLER_KEY',
		'CLASSIC_CONTROLLER_MOVE',
		'NUNCHUK_KEY',
		'NUNCHUK_MOVE',
		'DRUMS_KEY',
		'DRUMS_MOVE',
		'GUITAR_KEY',
		'GUITAR_MOVE',
		'GONE',
	} do
	events[v] = ffi.C['XWII_EVENT_'..v]
	events_by_name[ffi.C['XWII_EVENT_'..v]] = v
end

local keys_by_name = {}
local keys = {}
for k,v in pairs
	{
		'LEFT',
		'RIGHT',
		'UP',
		'DOWN',
		'A',
		'B',
		'PLUS',
		'MINUS',
		'HOME',
		'ONE',
		'TWO',
		'X',
		'Y',
		'TL',
		'TR',
		'ZL',
		'ZR',
		'THUMBL',
		'THUMBR',
		'C',
		'Z',
		'STRUM_BAR_UP',
		'STRUM_BAR_DOWN',
		'FRET_FAR_UP',
		'FRET_UP',
		'FRET_MID',
		'FRET_LOW',
		'FRET_FAR_LOW',
	} do
	keys[v] = ffi.C['XWII_KEY_'..v]
	keys_by_name[ffi.C['XWII_KEY_'..v]] = v
end



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
local function struct_event()
	return ffi.new("struct xwii_event")
end
-- }}}

Interface.event_types = events

function Interface:init(path)
	assert(path, "No path given for Interface to init.")
	local x = {}
	local iface = struct_iface_in()
	local ret = nil
	ret = iface_new(iface, path)
	assert(ret == 0, "Cannot create xwii_iface '"..path.."'. "..err(ret))
	self._iface = iface[0]
	self:open()
end

function Interface:open()
	local ret = iface_open(self._iface,
		bit.bor(iface_available(self._iface), XWII_IFACE_WRITABLE))
	assert(ret == 0, "Cannot open xwii_iface. "..err(ret))
end

-- devtype {{{
function Interface:get_devtype()
	local p_devtype = out_char()
	local ret = iface_get_devtype(self._iface, p_devtype)
	assert(ret == 0, "Cannot read devtype..., "..err(ret))
	local devtype = ffi.string(p_devtype[0])
	return devtype
end
-- }}}
-- extension {{{
function Interface:get_extension()
	local p_extension = out_char()
	local ret = iface_get_extension(self._iface, p_extension)
	assert(ret == 0, "Cannot read extension..., "..err(ret))
	local extension = ffi.string(p_extension[0])
	return extension
end
-- }}}
-- LEDS {{{
function Interface:get_leds()
	local leds = {}
	for _,led in ipairs({1,2,3,4}) do
		local out = out_bool()
		local ret = iface_get_led(self._iface, led, out)
		assert(ret == 0, "Cannot read led state..., "..err(ret))
		leds[led] = out[0]
	end
	return leds
end

function Interface:set_led(led, state)
	assert(led>0 and led<5, "Invalid range for led in set_led.")
	assert(state == true or state == false, "Invalid state in set_led.")
	local ret = iface_set_led(self._iface, led, state)
	assert(ret == 0, "Cannot set led state..., "..err(ret))
end

function Interface:set_leds(leds)
	assert(#leds < 5, "Too many states given to set_leds.")
	for led,state in ipairs(leds) do
		self:set_led(led,state)
	end
end
-- }}}
-- Events dispatch {{{
-- Can be called at any time. When no events are available, returns nil.
function Interface:dispatch_event()
	local fds = {
		struct_pollfd()
	}
	fds[1].fd = iface_get_fd(self._iface)
	fds[1].events = POLLIN;
	local polled = poll(fds, 0)
	assert(polled >= 0, err(ffi.errno()))
	if polled > 0 then
		local ev = struct_event()
		local ret = iface_dispatch(self._iface, ev, ffi.sizeof(ev))
		if (ret == -EAGAIN) then return nil end
		assert(ret >= 0, "Error with iface_dispatch, "..err(ret))
		local event = {
			['type'] = ev.type,
			['ev_name'] = events_by_name[ev.type]
		}
		if ev.type == events.KEY then
			event['key'] = {
				code  = ev.v.key.code,
				name  = keys_by_name[ev.v.key.code],
				state = ev.v.key.state,
			}
		elseif ev.type == events.WATCH then
			self:open()
			event['available'] = iface_available(self._iface)
		end
		return event
	end
	return nil
end
-- }}}

function Interface:destroy()
	iface_unref(self._iface)
end

return Interface
