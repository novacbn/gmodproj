import unpack from _G
import char from string

import arshift, lshift, int16FromBytes, int32FromBytes from "novacbn/novautils/bit"
import ByteArray from "novacbn/novautils/collections/ByteArray"

-- ReadBuffer::ReadBuffer()
-- Represents a generic byte reading buffer
-- export
export ReadBuffer = ByteArray\extend {
    -- ReadBuffer::cursor -> number
    -- Represents the current position of the ReadBuffer
    --
    cursor: 0

    -- ReadBuffer::read(number length?) -> number ...
    -- Reads and returns the amount of bytes specified
    --
    read: (length=1) =>
        -- Validate the amount of bytes being read
        cursor      = @cursor
        newCursor   = cursor + length
        error("bad argument #1 to 'read' (read length exceeds buffer length)") if newCursor > @length

        -- Store the new cursor then slice the request buffer bytes
        @cursor = newCursor
        return unpack(self, cursor + 1, newCursor)

    readFloat32: () =>
    readFloat64: () =>

    -- ReadBuffer::readInt8() -> number
    -- Reads the next byte as a 8-bit signed integer
    --
    readInt8: () =>
        return arshift(lshift(@readUInt8(), 24), 24)

    -- ReadBuffer::readInt16() -> number
    -- Reads the next two bytes as a 16-bit signed integer
    --
    readInt16: () =>
        return arshift(lshift(@readUInt16(), 16), 16)

    -- ReadBuffer::readInt32() -> number
    -- Reads the next four bytes as a 32-bit signed integer
    --
    readInt32: () =>
        return arshift(lshift(@readUInt32(), 32), 32)

    -- ReadBuffer::readString(number length?) -> string
    -- Reads the amount of bytes specified, converted into an ASCII string
    --
    readString: (length) =>
        -- Read the given amount of bytes and remap into an ASCII string
        return char(@read(length))

    -- ReadBuffer::readUInt8() -> number
    -- Reads the next byte as an 8-bit unsigned integer
    --
    readUInt8: () =>
        return @read(1)

    -- ReadBuffer::readUInt16() -> number
    -- Reads the next two bytes as a 16-bit unsigned integer
    --
    readUInt16: () =>
        return int16FromBytes(@read(2))

    -- ReadBuffer::readUInt32() -> number
    -- Reads the next four bytes as a 32-bit unsigned integer
    --
    readUInt32: () =>
        return int32FromBytes(@read(4))

    -- ReadBuffer::remaining() -> number
    -- Returns the remaining amount of bytes pending to be read
    --
    remaining: () => @length - @cursor
}