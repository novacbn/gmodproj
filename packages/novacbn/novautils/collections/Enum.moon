-- ::Enum(table fieldNames) -> table
-- Makes a table of enumerable incremental keys
-- export
export Enum = (fieldNames) ->
    return {fieldNames[index], index - 1 for index=1, #fieldNames}