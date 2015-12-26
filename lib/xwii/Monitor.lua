--- Monitor
-- http://dvdhrm.github.io/xwiimote/api/group__monitor.html

local ffi   = require "ffi"
local class = require "30log"
local Monitor = class("Monitor")
local Interface = require "xwii.Interface"

-- ffi imports {{{
ffi.cdef [[
struct xwii_monitor *xwii_monitor_new(bool poll, bool direct);
void xwii_monitor_ref(struct xwii_monitor *mon);
void xwii_monitor_unref(struct xwii_monitor *mon);
int xwii_monitor_get_fd(struct xwii_monitor *monitor, bool blocking);
char *xwii_monitor_poll(struct xwii_monitor *monitor);
]]
-- Load in global namespace
local xwiimote = ffi.load("xwiimote", true)
-- Doing this since xwiimote is collected since I, using "shortcuts".
-- THIS IS PROBABLY AN ANTIPATTERN AND SHOULD BE CHECKED.
-- FIXME : Duration of xwiimote.

-- Shortcuts to the monitor functions
local _new    = ffi.C.xwii_monitor_new;
local _ref    = ffi.C.xwii_monitor_ref;
local _unref  = ffi.C.xwii_monitor_unref;
local _get_fd = ffi.C.xwii_monitor_get_fd;
local _poll   = ffi.C.xwii_monitor_poll;
-- }}}

-- Creates a monitor.
-- poll: Whether it detects new wiimotes after init.
function Monitor:init(poll, direct)
	if poll == nil then poll = true end
	if direct == nil then direct = false end

	self._mon = _new(poll, direct)
	assert(self._mon, "Could not create monitor")
end

-- Returns an Interface when a new one is available.
-- Otherwise returns nil.
-- Is affected by the poll parameter of init.
function Monitor:poll()
	local entry = nil
	entry = _poll(self._mon)
	if (entry == nil) then
		return nil
	end
	entry = ffi.string(entry)
	return Interface(entry)
end

function Monitor:destroy()
	_unref(self._mon)
end

return Monitor
