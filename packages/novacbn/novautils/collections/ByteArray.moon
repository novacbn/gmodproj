import unpack from _G
import byte, char from string
import concat from table

import mapi from "novacbn/novautils/table"
import Object from "novacbn/novautils/utilities/Object"

-- TODO:
--  add encoding options for from/toString, UTF-8(if available on the platform), and hex
--  byte range check, 0..255

-- ByteArray::ByteArray()
-- Represents a generic array of bytes
-- export
export ByteArray = Object\extend {
    -- ByteArray::length -> number
    -- Represents the number of bytes within the ByteArray
    --
    length: 0

    -- ByteArray::fromString(string value) -> table
    -- Makes a new ByteArray converting the string value into bytes
    -- static
    fromString: (value) =>
        -- Make a new ByteArray with the string remapped into an array of bytes
        byteArray           = self\new()
        byteArray[index]    = byte(value, index) for index=1, #value
        byteArray.length    = #value
        return byteArray

    -- ByteArray::fromTable(table byteTable) -> table
    -- Makes a new ByteArray cloning the bytes from the provided table
    -- static
    fromTable: (byteTable) =>
        -- Make a new ByteArray cloning the bytes in the provided table
        byteArray           = self\new()
        byteArray[index]    = byteTable[index] for index=1, #byteTable
        byteArray.length    = #byteTable
        return byteArray

    -- ByteArray::toString() -> string
    -- Returns the ByteArray as an ASCII string
    --
    toString: () =>
        -- Unpack the array of bytes and convert into string
        byteTable = mapi(self, (i, v) -> char(v))
        return concat(byteTable, "")
}