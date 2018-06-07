import type from _G
import insert, remove from table

import Iterator from "novacbn/novautils/collections/Iterator"
import inRange from "novacbn/novautils/math"

-- ::getCacheKey(any value) -> any
-- Returns a non-conflict key for stored values
--
getCacheKey = (value) ->
    -- If the value is a string or number, prepend a prefix to it
    if type(value) == "string" then return "__set_s_"..value
    elseif type(value) == "number" then return "__set_i_"..value

    return value

-- Set::Set()
-- Represents a generic Array-like collection that only accepts unique values
-- export
export Set = Iterator\extend {
    -- Set::length -> number
    -- Represents the number of items in the Set
    --
    length: 0

    -- Set::fromTable(table sourceTable) -> Set
    -- Returns a new Set using the values from numerically indexed table
    -- static
    fromTable: (sourceTable) =>
        set = self\new()
        set\push(value) for value in *sourceTable
        return set

    -- Set::__iter(boolean reverse) -> function
    -- Metaevent for returning a stateful iterator for the Set, performs reverse iteration if specified
    -- metaevent 
    __iter: (reverse) =>
        index = reverse and @length + 1 or 0
        return () ->
            index += 1
            return self[index], index

    -- Set::clear() -> void
    -- Clears out all the values within the Set
    --
    clear: () =>
        -- Loop through each value and index in the Set, clearing the index and cache keys
        local key
        for value, index in @iter()
            key         = getCacheKey(value)
            self[index] = nil
            self[key]   = nil

    -- Set::find(any searchValue) -> number
    -- Returns the first index with a matching value, if any
    --
    find: (searchValue) =>
        -- Return the index of the matching value
        for value, index in @iter()
            return index if value == searchValue

        return nil

    -- Set::has(any value) -> boolean
    -- Returns if the value exists within the Set
    --
    has: (value) =>
        -- Get the cache key of the value and return if exists
        key = getCacheKey(value)
        return self[key] ~= nil

    -- Set::push(any value) -> number
    -- Appends the value into the Set, ignoring previously pushed values, returning the new index
    --
    push: (value) =>
        -- Raise errors on nil values
        error("bad argument #1 to 'push' (expected value)") if value == nil

        -- Ignore the value if already added
        key = getCacheKey(value)
        return unless self[key] == nil

        -- Calculate the new length and store the value
        length          = @length + 1
        self[key]       = true
        self[length]    = value
        @length         = length

        return length

    -- Set::pop() -> any
    -- Removes and returns the last value of the Set
    --
    pop: (value) =>
        return @remove(@length)

    -- Set::remove(number index) -> any
    -- Removes and returns the value at the given index
    --
    remove: (index) =>
        -- Raise error if the index isn't in the Set's range
        error("bad argument #1 to 'remove' (invalid index)") unless inRange(1, @length)

        -- Calculate the new length then remove and return the value
        key         = getCacheKey(self[index])
        self[key]   = nil
        @length     -= 1
        return @remove(self, index)

    -- Set::shift(any value) ->
    -- Prepends the value into the Set, ignoring previously shifted values, returning the new index
    --
    shift: (value) =>
        -- Raise errors on nil values
        error("bad argument #1 to 'shift' (expected value)") if value == nil

        -- Ignore the value if already added
        key = getCacheKey(value)
        return unless self[key] == nil

        -- Calculate the new length and store the value
        length      = @length + 1
        self[key]   = true
        insert(self, value, 1)

        return length

    -- Set::unshift() -> any
    -- Removes and returns the first value of the Set
    --
    unshift: () =>
        return @remove(1)
}