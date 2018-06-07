maxF, minF = math.max, math.min

-- ::RANGE_INT8 -> table
-- Represents the possible range of 8-bit signed integers
-- export
export RANGE_INT8 = {
    -- RANGE_INT8::min -> number
    -- Represents the minimum possible value of a 8-bit signed integer
    --
    min: (0x0000007F + 1) * -1

    -- RANGE_INT8::max -> number
    -- Represents the maximum possible value of a 8-bit signed integer
    --
    max: 0x0000007F
}

-- ::RANGE_INT16 -> table
-- Represents the possible range of 16-bit signed integers
-- export
export RANGE_INT16 = {
    -- RANGE_INT16::min -> number
    -- Represents the minimum possible value of a 16-bit signed integer
    --
    min: (0x00007FFF + 1) * -1

    -- RANGE_INT16::max -> number
    -- Represents the maximum possible value of a 16-bit signed integer
    --
    max: 0x00007FFF
}

-- ::RANGE_INT32 -> table
-- Represents the possible range of 32-bit signed integers
-- export
export RANGE_INT32 = {
    -- RANGE_INT32::min -> number
    -- Represents the minimum possible value of a 32-bit signed integer
    --
    min: (0x7FFFFFFF + 1) * -1

    -- RANGE_INT32::max -> number
    -- Represents the maximum possible value of a 32-bit signed integer
    --
    max: 0x7FFFFFFF
}

-- ::RANGE_UINT8 -> table
-- Represents the possible range of 8-bit unsigned integers
-- export
export RANGE_UINT8 = {
    -- RANGE_UINT8::min -> number
    -- Represents the minimum possible value of a 8-bit unsigned integer
    --
    min: 0x00000000

    -- RANGE_UINT8::max -> number
    -- Represents the maximum possible value of a 8-bit unsigned integer
    --
    max: 0x000000FF
}

-- ::RANGE_UINT16 -> table
-- Represents the possible range of 16-bit unsigned integers
-- export
export RANGE_UINT16 = {
    -- RANGE_UINT16::min -> number
    -- Represents the minimum possible value of a 16-bit unsigned integer
    --
    min: 0x00000000

    -- RANGE_UINT16::max -> number
    -- Represents the maximum possible value of a 16-bit unsigned integer
    --
    max: 0x00FFFFFF
}

-- ::RANGE_UINT32 -> table
-- Represents the possible range of 32-bit unsigned integers
-- export
export RANGE_UINT32 = {
    -- RANGE_UINT32::min -> number
    -- Represents the minimum possible value of a 32-bit unsigned integer
    --
    min: 0x00000000

    -- RANGE_UINT32::max -> number
    -- Represents the maximum possible value of a 32-bit unsigned integer
    --
    max: 0xFFFFFFFF
}

-- ::clamp(number value, number min, number max) -> number
-- Returns the number clamped to the range (min...max)
-- export
export clamp = (value, min, max) ->
    return minF(maxF(value, min), max)

-- ::inRange(number value, number min, number max) -> boolean
-- Returns if the value is within the range (min...max)
-- export
export inRange = (value, min, max) ->
    return value <= max and value >= min

-- ::isFloat(number value) -> boolean
-- Returns if the number is a float, i.e. a floating-point number, 3.14
-- export
export isFloat = (value) ->
    return value % 1 ~= 0

-- ::isInteger(number value) -> boolean
-- Returns if the number is an integer, i.e. a natural number, 5
-- export
export isInteger = (value) ->
    return value % 1 == 0