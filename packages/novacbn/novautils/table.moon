import ipairs, pairs, type from _G

-- ::clone(table sourceTable) -> table
-- Makes a recursive clone of the source table
-- export
export clone = (sourceTable) ->
    -- Make a new clone of the source table, recursively cloning sub-tables
    return {key, type(value) == "table" and clone(value) or value for key, value in pairs(sourceTable)}

-- ::copy(table sourceTable) -> table
-- Makes a shallow copy of the source table
-- export
export copy = (sourceTable) ->
    -- Make a new shallow clone of the source table
    return {key, value for key, value in pairs(sourceTable)}

-- ::deepMerge(table targetTable, sourceTable) -> table
-- Recursively merges missing keys in the target table from the source table
-- export
export deepMerge = (targetTable, sourceTable) ->
    for key, value in pairs(sourceTable)
        -- If target value is a table and source value is a table, perform a recursive merge
        if type(targetTable[key]) == "table" and type(value) == "table" then deepMerge(targetTable[key], value)
        if targetTable[key] == nil
            -- Clone source value tables before merging
            if type(value) == "table" then value = clone(value)
            targetTable[key] = value

    return targetTable

-- ::deepUpdate(table targetTable, table sourceTable) -> table
-- Recursively merges all keys from the source table to the target table
-- export
export deepUpdate = (targetTable, sourceTable) ->
    for key, value in pairs(sourceTable)
        if type(value) == "table"
            -- If the value is a table, and the target value is a table, perform a recursive update, otherwise clone
            if type(targetTable[key]) == "table" then deepUpdate(targetTable[key], value)
            else targetTable[key] = clone(value)

        -- Value is not a table, just assign it
        else targetTable[key] = value

    return targetTable

-- ::keysMeta(table sourceTable, table collectionTable?) -> table
-- Enumerates the metatable '__index' chain of the source table to collect every indexable key
-- export
export keysMeta = (sourceTable, collectionTable={}) ->
    -- If a metatable with an '__index' metaevent exists, recursively collect the keys
    metaTable = getmetatable(sourceTable)
    keysMeta(metaTable.__index, collectionTable) if metaTable and type(metaTable.__index) == "table"

    -- Collect every key in the source table
    collectionTable[key] = value for key, value in pairs(sourceTable)
    return collectionTable

-- ::isNumericTable(table sourceTable) -> boolean
-- Returns if the keys of the table are all numeric
-- export
export isNumericTable = (sourceTable) ->
    -- Loop through each key in the table, if a key is not a number, return false
    for key, value in pairs(sourceTable)
        return false unless type(key) == "number"

    return true

-- ::isSequentialTable(table sourceTable) -> boolean
-- Returns if the table is a numeric non-sparse table(i.e. an array)
-- export
export isSequentialTable = (sourceTable) ->
    countedLength, previousIndex = 0, nil
    for index, value in ipairs(sourceTable)
        -- If there was a previously searched index, check if the table is sparse
        if previousIndex
            return false if (previousIndex - index) > 1

        -- Store the previous index and increment the amount of keypairs counted
        previousIndex   = index
        countedLength   += 1

    -- Return true if the amount of keypairs counted matches the table's length
    return countedLength == #sourceTable

-- ::makeLookupMap(table lookupValues) -> table
-- Makes a new value->key map for faster reverse lookups
-- export
export makeLookupMap = (lookupValues) ->
    return {value, key for key, value in pairs(lookupValues)}

-- ::makeTruthpMap(table lookupValues) -> table
-- Makes a new value->true map for faster truthy lookups
-- export
export makeTruthMap = (lookupValues) ->
    -- Make a new truthy lookup map
    return {value, true for value in *lookupValues}

-- ::map(table targetTable, function func) -> table
-- Makes a shallow-copy of the table, remapping all the keys and values
-- export
export map = (targetTable, func) ->
    return {func(key, value) for key, value in pairs(targetTable)}

-- ::mapi(table targetTable, function func) -> table
-- Makes a shallow-copy of the table, remapping all the indexes and values
-- export
export mapi = (targetTable, func) ->
    remappedTable   = {}
    length          = 0

    local remappedValue
    for index, value in ipairs(targetTable)
        remappedValue = func(index, value)
        unless remappedValue == nil
            length                  += 1
            remappedTable[length]   = remappedValue

    return remappedTable

-- ::merge(table targetTable, table sourceTable) -> table
-- Merges missing keys in the target table from the source table
-- export
export merge = (targetTable, sourceTable) ->
    -- Merge missing keys from the source table into the target table
    for key, value in pairs(sourceTable)
        if targetTable[key] == nil then
            if type(value) == "table" then value = clone(value)
            targetTable[key] = value

    return targetTable

-- ::update(table targetTable, table sourceTable) -> table
-- Merges all keys in the source table to the target table
-- export
export update = (targetTable, sourceTable) ->
    -- Merge all keys in the target table
    for key, value in pairs(sourceTable)
        if type(value) == "table" then value = clone(value)
        targetTable[key] = value

    return targetTable

-- ::slice(table targetTable, number startIndex, number endIndex) -> table
-- Makes a shallow-copy of the target table, only containing values in the index range
-- export
export slice = (targetTable, startIndex, endIndex) ->
    return [targetTable[index] for index=startIndex, endIndex]