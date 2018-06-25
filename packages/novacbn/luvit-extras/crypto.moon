import type from _G
import lower from string

import Buffer from require "buffer"
import base64, digest, hex from require "openssl"

-- ::ENCODING_ALGORITHMS -> table
-- Represents the available list of supported character encodings
--
ENCODING_ALGORITHMS = {
    -- ENCODING_ALGORITHMS::buffer(string data, boolean isEncoding) -> string
    -- Encodes a string of data into a Buffer
    --
    buffer: (data, isEncoding) ->
        return Buffer\new(data) if isEncoding
        return data\toString()

    -- ENCODING_ALGORITHM::base64(string data, boolean isEncoding) -> string
    -- Encodes a string of data into Base64
    --
    base64: (data, isEncoding) -> base64(data, isEncoding)

    -- ENCODING_ALGORITHMS::hex(string data, boolean isEncoding) -> string
    -- Encodes a string of data into a Hexadecimal
    --
    hex: (data, isEncoding) -> hex(data, isEncoding)
}

-- ::HASHING_ALGORITHMS -> table
-- Represents the hashing algorithms supported by OpenSSL
--
HASHING_ALGORITHMS = {algorithm, true for algorithm in *digest.list()}

-- ::isBuffer(any value) -> boolean
-- Returns if the value is a Buffer
--
isBuffer = (value) ->
    -- HACK: instanceof does not work
    return type(value) == "table" and value.meta == Buffer.meta or false

-- ::createHash(string or Buffer data, string algorithm, string encoding?) -> string or Buffer
-- Returns a hash digest with the chosen algorithm
-- export
export createHash = (data, algorithm, encoding="hex") ->
    error("bad argument #1 to 'createHash' (expected string)") unless isBuffer(data) or type(data) == "string"
    error("bad argument #2 to 'createHash' (expected string)") unless type(data) == "string"
    error("bad argument #2 to 'createHash' (unexpected algorithm)") unless HASHING_ALGORITHMS[algorithm]

    data = data\toString() if isBuffer(data)
    return encodeData(digest.digest(algorithm, data, true), encoding)

-- ::decodeData(string or Buffer data, string encoding) -> string or Buffer
-- Decodes a string of data from a specific character encoding
-- export
export decodeData = (data, encoding) ->
    error("bad argument #1 to 'decodeData' (expected string)") unless isBuffer(data) or type(data) == "string"
    error("bad argument #2 to 'decodeData' (expected string)") unless type(encoding) == "string"

    encoding = lower(encoding)
    error("bad argument #2 to 'decodeData' (unexpected encoding)") unless ENCODING_ALGORITHMS[encoding]

    if encoding == "buffer"
        error("bad argument #1 to 'decodeData' (expected Buffer)") unless isBuffer(data)
    elseif isBuffer(data) then data = data\toString()

    return ENCODING_ALGORITHMS[encoding](data, false)

-- ::encodeData(string or Buffer data, string encoding) -> string or Buffer
-- Encodes a string of data into a specific character encoding
-- export
export encodeData = (data, encoding) ->
    error("bad argument #1 to 'encodeData' (expected string)") unless isBuffer(data) or type(data) == "string"
    error("bad argument #2 to 'encodeData' (expected string)") unless type(encoding) == "string"

    encoding = lower(encoding)
    error("bad argument #2 to 'encodeData' (unexpected encoding)") unless ENCODING_ALGORITHMS[encoding]

    if encoding == "buffer"
        error("bad argument #1 to 'encodeData' (expected string)") unless type(data) == "string"
    elseif isBuffer(data) then data = data\toString()

    return ENCODING_ALGORITHMS[encoding](data, true)