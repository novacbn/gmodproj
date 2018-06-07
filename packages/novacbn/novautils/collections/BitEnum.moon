import band, bnot, bor from "novacbn/novautils/bit"

-- ::addFlag(number bitMask, bitFlag) -> number
-- Adds a bitwise flag to the bitwise mask
-- export
export addFlag = (bitMask, bitFlag) -> bor(bitMask, bitFlag)

-- ::hasFlag(number bitMask, number bitFlag) -> number
-- Returns if the bitwise flag is in the bitwise mask
-- export
export hasFlag = (bitMask, bitFlag) -> band(bitMask, bitFlag) == bitFlag

-- removeFlag(number bitMask, number bitFlag) -> number
-- Removes a bitwise flag from the bitwise mask
-- export
export removeFlag = (bitMask, bitFlag) -> bnot(bitMask, bitFlag)

-- ::BitEnum(table fieldName) -> table
-- Makes a table of enumerable incremental bitwise flags
--
-- ```lua
-- AttackFlags = BitEnum {
--     "none",
--     "physical",
--     "energy",
--     "heat",
--     "cold",
--     "toxic",
--     "electric"
-- }
--
-- print(AttackFlags.energy) -- Prints '2'
-- ```
-- export
export BitEnum = (fieldNames) ->
    nextFlag    = 0
    enumLookup  = {}

    for value in *fieldNames
        enumLookup[value] = nextFlag
        nextFlag = nextFlag == 0 and 1 or nextFlag * 2

    return enumLookup