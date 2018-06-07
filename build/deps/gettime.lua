-- source: https://gist.github.com/starwing/1757443a1bd295653c39

local tonumber  = _G.tonumber
local ffi       = require("ffi")
local math      = require("math")

if jit.os == "Windows" then
   ffi.cdef [[
      unsigned __stdcall GetTickCount(void);
   ]]

   local lib = ffi.load "KERNEL32"
   gettime = lib.GetTickCount

else
   ffi.cdef [[
      typedef long time_t;
      typedef int clockid_t;

      typedef struct timespec {
         time_t   tv_sec;        /* seconds */
         long     tv_nsec;       /* nanoseconds */
      } nanotime;
      int clock_gettime(clockid_t clk_id, struct timespec *tp);
   ]]

   local pnano = assert(ffi.new("nanotime[?]", 1))
   function gettime()
      -- CLOCK_MONOTONIC -> 1
      ffi.C.clock_gettime(1, pnano)
      return tonumber(pnano[0].tv_sec * 1000
         + math.floor(tonumber(pnano[0].tv_nsec/1000000)))
   end
end

return {
    gettime = gettime
}