-- Secret Shared 67 Bits key. (53 + 14 = 67)
local Key53 = 40000
local Key14 = 45000

  local inv256

  function Hash(str)
    if not inv256 then
      inv256 = {}
      for M = 0, 127 do
        local inv = -1
        repeat inv = inv + 2
        until inv * (2*M + 1) % 256 == 1
        inv256[M] = inv
      end
    end
    local K, F = Key53, 16384 + Key14
    return (str:gsub('.',
      function(m)
        local L = K % 274877906944  -- 2^38
        local H = (K - L) / 274877906944
        local M = H % 128
        m = m:byte()
        local c = (m * inv256[M] - (H - M) / 128) % 256
        K = L * F + H + c + m
        return ('%02x'):format(c)
      end
    ))
  end

  function DecodeHash(str)
    local K, F = Key53, 16384 + Key14
    return (str:gsub('%x%x',
      function(c)
        local L = K % 274877906944  -- 2^38
        local H = (K - L) / 274877906944
        local M = H % 128
        c = tonumber(c, 16)
        local m = (c + (H - M) / 128) * (2*M + 1) % 256
        K = L * F + H + c + m
        return string.char(m)
      end
    ))
  end

local String = "Hello, World!"
print(tostring(Hash(String))) --> 486508150bd8891a0985ce54bc
print(tostring(DecodeHash("486508150bd8891a0985ce54bc"))) --> Hello, World!
