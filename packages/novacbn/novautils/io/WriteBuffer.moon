import type from _G
import byte from string

import arshift, lshift, byteFromInt8, bytesFromInt16, bytesFromInt32 from "novacbn/novautils/bit"
import inRange from "novacbn/novautils/math"
import ByteArray from "novacbn/novautils/collections/ByteArray"

-- WriteBuffer::WriteBuffer()
-- Represents a generic byte writing buffer
-- export
export WriteBuffer = ByteArray\extend {
    -- WriteBuffer::write(number ...) -> void
    -- Appends each number in the varargs to the buffer as a byte
    --
    write: (...) =>
        -- Cache the provided bytes into a table for writing
        varArgs = {...}
        length  = @length

        local value
        for index=1, #varArgs
            -- Retrieve and validate the written byte
            value = varArgs[index]
            error("bad argument ##{index} to 'write' (expected number)") unless type(value) == "number"
            error("bad argument ##{index} to 'write' (expected number in range 0...255)") unless inRange(value, 0, 255)

            -- Assign the byte to the WriteBuffer using the current length as an offset
            self[index + length] = value

        -- Increment the WriteBuffer length by the amount of bytes written
        @length += #varArgs

    writeFloat32: (value) =>
    writeFloat64: (value) =>

    -- WriteBuffer::writeInt8(number value) -> void
    -- Appends the provided value as a byte signed integer
    --
    writeInt8: (value) =>
        @write(byteFromInt8(value))

    -- WriteBuffer::writeInt16(number value) -> void
    -- Appends the provided value as a two byte signed integer
    --
    writeInt16: (value) =>
        @write(bytesFromInt16(value))

    -- WriteBuffer:writeInt32(number value) -> void
    -- Appends the provided value as a four byte signed integer
    --
    writeInt32: (value) =>
        @write(bytesFromInt32(value))

    -- WriteBuffer::writeString(string value) -> void
    -- Converts the value into a byte table then appends it to the WriteBuffer
    --
    writeString: (value) =>
        -- Convert each character in the string into a byte, then append to buffer
        length = @length
        for index=1, #value
            self[length + index] = byte(value, index)

        @length += #value

    -- WriteBuffer::writeUInt8(number value) -> void
    -- Appends the provided value as a byte unsigned integer
    --
    writeUInt8: (value) =>
        @write(byteFromInt8(value))

    -- WriteBuffer::writeUInt16(number value) -> void
    -- Appends the provided value as a two byte unsigned integer
    --
    writeUInt16: (value) =>
        @write(bytesFromInt16(value))

    -- WriteBuffer:writeUInt32(number value) -> void
    -- Appends the provided value as a four byte unsigned integer
    --
    writeUInt32: (value) =>
        @write(bytesFromInt32(value))
}