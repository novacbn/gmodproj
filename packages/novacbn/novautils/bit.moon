-- Support LuaJIT 'bit' library
if bit
    exports.arshift = bit.arshift
    exports.band    = bit.band
    exports.bnot    = bit.bnot
    exports.bor     = bit.bor
    exports.bxor    = bit.bxor
    exports.lshift  = bit.lshift
    exports.rol     = bit.rol
    exports.ror     = bit.ror
    exports.rshift  = bit.rshift

-- Support 'bit' Lua 5.2 standard library
elseif bit32
    exports.arshift = bit32.arshift
    exports.band    = bit32.band
    exports.bnot    = bit32.bnot
    exports.bor     = bit32.bor
    exports.bxor    = bit32.bxor
    exports.lshift  = bit32.lshift
    exports.rol     = bit32.lrotate
    exports.ror     = bit32.rrotate
    exports.rshift  = bit32.rshift

else error("could not find 'bit' LuaJIT or 'bit32' Lua 5.2 libraries")

import
    arshift, band, bor,
    lshift, rshift from exports

-- ::byteFromInt8(number value) -> number
-- Packs the 8-bit integer into a single byte
-- export
export byteFromInt8 = (value) ->
    return band(value, 255)

-- ::bytesFromInt16(number value) -> number, number
-- Packs the 16-bit integer into BigEndian-format two bytes
-- export
export bytesFromInt16 = (value) ->
    return band(rshift(value, 8), 255), band(value, 255)

-- ::bytesFromInt32(number value) -> number, number, number, number
-- Packs the 32-bit integer into BigEndian-format four bytes
-- export
export bytesFromInt32 = (value) ->
    return band(rshift(value, 24), 255), band(rshift(value, 16), 255), band(rshift(value, 8), 255), band(value, 255)

-- int32FromBytes(number byteOne, number byteTwo) -> number
-- Unpacks a single byte into a 8-bit integer
-- export
export int8FromByte = (byte) ->
    -- NOTE: this is here for the sake of completeness, nothing more
    return byte

-- int32FromBytes(number byteOne, number byteTwo) -> number
-- Unpacks BigEndian-format two bytes into a 16-bit integer
-- export
export int16FromBytes = (byteOne, byteTwo) ->
    return bor(
        lshift(byteOne, 8),
        byteTwo
    )

-- int32FromBytes(number byteOne, number byteTwo, number byteThree, number byteFour) -> number
-- Unpacks BigEndian-format four bytes into a 32-bit integer
-- export
export int32FromBytes = (byteOne, byteTwo, byteThree, byteFour) ->
    return bor(
        lshift(byteOne, 24),
        lshift(byteTwo, 16),
        lshift(byteThree, 8),
        byteFour
    )