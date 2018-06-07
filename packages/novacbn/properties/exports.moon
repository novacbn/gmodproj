import type from _G

-- ::propertiesEncoders -> table
-- Represents the possible encoders to use with the library
--
propertiesEncoders = {
    lua:        dependency "novacbn/properties/encoders/lua"
    moonscript: dependency "novacbn/properties/encoders/moonscript"
}

-- EncoderOptions::EncoderOptions() -> EncoderOptions
-- Represents the options passed to the properties encoder
--
EncoderOptions = (options) ->
    return with options or {}
        -- EncoderOptions::allowUnsafe -> boolean
        -- Represents if the encoder can encode unsafe values, e.g. code blocks, function values
        --
        .allowUnsafe = .allowUnsafe or true

        -- EncoderOptions::indentationChar -> string
        -- Represents the character used for indentation
        --
        .indentationChar = .indentationChar or "\t"

        -- DecoderOptions::propertiesEncoder -> table
        -- Represents the selected encoder used for encoding a Lua table
        --
        .propertiesEncoder = propertiesEncoders[.propertiesEncoder or "lua"]

        -- DecoderOptions::sortKeys -> boolean
        -- Represents if keys of keypair tables are sorted
        --
        .sortKeys = .sortKeys == nil and true or .sortKeys

        -- DecoderOptions::sortIgnoreCase -> boolean
        -- Represents if string keys of keypair tables ignore case sensitivity while sorting
        --
        .sortIgnoreCase = .sortIgnoreCase == nil and true or .sortIgnoreCase

        error("bad option 'propertiesEncoder' to 'EncoderOptions' (invalid value '#{decoderOptions.propertiesEncoder}')") unless .propertiesEncoder

-- DecoderOptions::DecoderOptions() -> DecoderOptions
-- Represents the options passed to the properties decoder
--
DecoderOptions = (options) ->
    return with options or {}
        -- DecoderOptions::allowUnsafe -> boolean
        -- Represents if the encoder can parse unsafe values, e.g. code blocks, function values
        --
        .allowUnsafe        = .allowUnsafe or true

        -- DecoderOptions::propertiesEncoder -> table
        -- Represents the selected encoder used for decoding a properties format string
        --
        .propertiesEncoder  = propertiesEncoders[.propertiesEncoder or "lua"]

        error("bad option 'propertiesEncoder' to 'DecoderOptions' (invalid value '#{decoderOptions.propertiesEncoder}')") unless .propertiesEncoder

-- ::encode(table value, table options?) -> string
-- Encodes a Lua table into a valid propeties format
-- export
export encode = (value, options) ->
    error("bad argument #1 to 'encode' (expected table)") unless type(value) == "table"
    error("bad argument #2 to 'encode' (expected table)") unless options == nil or type(options) == "table"

    encoderOptions  = EncoderOptions(options)
    return encoderOptions.propertiesEncoder.encode(value, encoderOptions)

-- ::decode(string value, table options?) -> table
-- Decodes a properties format string into a Lua table
-- export
export decode = (value, options) ->
    error("bad argument #1 to 'decode' (expected string)") unless type(value) == "string"
    error("bad argument #2 to 'decode' (expected table)") unless options == nil or type(options) == "table"

    decoderOptions  = DecoderOptions(options)
    return decoderOptions.propertiesEncoder.decode(value, decoderOptions)