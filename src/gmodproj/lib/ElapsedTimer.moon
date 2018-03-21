import format from string

import gettime from require "gettime"

-- ::getSeconds() -> number
-- Returns the current time as seconds
getSeconds = () ->
    return gettime() / 1000

-- ElapsedTimer::ElapsedTimer()
-- Represents a basic timer for timing tasks
export class ElapsedTimer
    -- ElapsedTimer::startTime -> number
    -- Represents the time in seconds since the an ElapsedTimer object was initiated
    startTime: 0

    -- ElapsedTimer::new()
    -- Constructor for ElapsedTimer
    new: () =>
        -- Store the creation timestamp
        @startTime = getSeconds()

    -- ElapsedTimer::getElapsed() -> number
    -- Returns the elapsed time as a number delta
    getElapsed: () =>
        return getSeconds() - @startTime

    -- ElapsedTimer::getFormattedElapsed() -> string
    -- Returns the elapsed time formatted as a string, e.g. "0.0341"
    getFormattedElapsed: () =>
        return format("%.4fs", getSeconds() - @startTime)