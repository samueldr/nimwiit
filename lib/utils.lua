local ffi   = require "ffi"
local utils = {}
ffi.cdef [[
unsigned int usleep(unsigned int usec);
]]
utils.usleep = ffi.C.usleep
return utils
