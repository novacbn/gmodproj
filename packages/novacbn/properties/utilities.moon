import pairs, type from _G
import lower from string
import sort from table

-- ::sortingWeights -> table
-- Represents the sorting order weights for Lua types
--
sortingWeights = {
    boolean:    0,
    number:     1,
    string:     2,
    table:      3
}

-- ::getKeys(table tbl) -> table
-- Returns all the keys within the table as an array
-- export
export getKeys = (tbl) ->
    return [key for key, value in pairs(tbl)]

-- ::getSortedValues(table tbl, boolean isCaseSensitive) -> table
-- Returns all the keys within the table as an array, sorting them in the process
-- NOTE:
--     when sorting, the following rules apply
--         * if both values are booleans, false precedes true
--         * if both values are numbers, lower value precedes higher value
--         * if both values are strings, the values are alphabetized, optionally ignoring case
--         * if both values are mismatch types, the follow sorting order is applied: boolean < number < string
-- export
export getSortedValues = (tbl, isCaseSensitive) ->
    values = [value for value in *tbl]

    local aWeight, bWeight, aType, bType
    sort(values, (a, b) ->
        aType, bType = type(a), type(b)

        -- If both values are the same type, use special rules, otherwise use the predetermined type weights
        if aType == "string" and bType == "string"
            return lower(a) < lower(b) unless isCaseSensitive
            return a < b

        elseif aType == "boolean" and bType == "boolean"
            if aType == true and bType == false then return false
            return true

        elseif aType == "number" and bType == "number" then return a < b
        else return sortingWeights[aType] < sortingWeights[bType]
    )

    return values

-- ::isArray(table tbl) -> boolean
-- Returns if the table if a sequential non-sparse array
-- export
export isArray = (tbl) ->
    -- Check if the table has a first index
    return false if tbl[1] == nil

    -- Check if each key is a number
    count = 0
    for key, value in pairs(tbl)
        return false unless type(key) == "number"
    
        count += 1

    -- Check if the table is sparse, using the counted keys and the calculated table length
    return false unless count == #tbl

    return true
