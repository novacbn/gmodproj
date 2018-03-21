import tostring from _G
import insert, remove from table

import getIndex from "gmodproj/lib/utilities"

-- ::getCollectionKey(any value) -> string
-- Returns a safe key to use to store the value
getCollectionKey = (value) ->
    return "__collection_#{value}"

-- Set::Set()
-- A generic collection containing only unique values
export class Set
    -- Set::tableCollection -> table
    -- Collection of items within the Set
    tableCollection: nil

    -- Set::constructor()
    -- Constructor for Set
    new: () =>
        @tableCollection = {}

    -- Set::__iterator(table tableCollection, number index) -> number, any
    -- Stateless function to handle iteration of the Set
    __iterator: (tableCollection, index, a, b, c) ->
        -- Select the next value and return if not nil
        index   += 1
        value   = tableCollection[index]
        return index, value unless value == nil

    -- Set::add(any value) -> void
    -- Add the unique value to the Set
    add: (value) =>
        -- Validate that the value is not nil
        error("bad argument #1 to 'add' (value is nil)") if value == nil

        -- Ignore the value if in the Set
        collectionKey = getCollectionKey(value)
        unless @[collectionKey]
            -- Add the unique value to the Set
            @[collectionKey] = true
            insert(@tableCollection, value)

    -- Set::clear() -> void
    -- Clears the Set of all unique values
    clear: () =>
        -- Clear all the values stored in lookup
        local collectionKey
        for value in *@tableCollection
            collectionKey       = getCollectionKey(value)
            @[collectionKey]    = nil

        -- Empty the collection via making new table
        @tableCollection = {}

    -- Set::has(any value) -> boolean
    -- Returns if the Set contains the value
    has: (value) =>
        -- Get the collection key of the value and validate its existance
        collectionKey = getCollectionKey(value)
        return @[collectionKey] and true or false

    -- Set::iter() -> function, table, number
    -- Returns a stateless iterator required for a for loop
    iter: () =>
        -- Return the iterator with initial arguments
        return @__iterator, @tableCollection, 0

    -- Set::remove(any value) -> void
    -- Removes the unique value from the Set if it exists
    remove: (value) =>
        -- Validate that the value is in the collection
        collectionKey = getCollectionKey(value)
        error("bad argument #1 to 'remove' (value not in collection)") if @[collectionKey] == nil

        -- Remove the value from the collection
        valueIndex = getIndex(@tableCollection, value)
        remove(@tableCollection, value)
        @[collectionKey] = nil

    -- Set::values() -> table
    -- Returns a copy of values within the Set
    values: () =>
        -- Return a copy of the values in the Set
        return [value for value in *@tableCollection]