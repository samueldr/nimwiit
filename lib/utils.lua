local ffi   = require "ffi"
local utils = {}
ffi.cdef [[
struct timeval {
	long tv_sec;
	long tv_usec;
};
typedef int ssize_t;
unsigned int usleep(unsigned int usec);
unsigned int sleep(unsigned int seconds);

// Standard functions.
int open(const char *path, int oflag, ...);
int ioctl(int fildes, int request, ...);
ssize_t write(int fildes, const void *buf, size_t nbyte);

// Standard types
typedef unsigned int __u32;
typedef signed int __s32;
typedef unsigned short __u16;
typedef signed short __s16;
]]

utils.usleep = ffi.C.usleep
utils.sleep = ffi.C.sleep

-- Wrapper around ioctl to fix issues with default number → double conversion.
utils.ioctl = function(fd, req, additional_req)
	-- FIXME : More generic handling. Hardcoded to one va_arg, and dirty.
	local ioctl = ffi.C.ioctl
	if additional_req then
		-- Force int instead of conversion to double.
		return ioctl(fd, req, ffi.new("int", additional_req))
	end
	return ioctl(fd, req)
end

-- Wrapper, don't want to care about sizeof.
utils.write = function(fd, data)
	return ffi.C.write(fd, data, ffi.sizeof(data))
end
return utils
