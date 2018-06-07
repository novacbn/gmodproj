import Object from "novacbn/novautils/utilities/Object"

-- Iterator::Iterator()
-- Represents a generic iterable collection
-- export
export Iterator = Object\extend {
    -- Iterator::iter(any ...) -> function
    -- Returns a stateful function for iterating on the collection
    iter: (...) =>
        return @__iter(...)

    -- Iterator::keys() -> table
    -- Returns a table of keys in the Iterator
    --
    keys: () =>
        return [key for value, key in @iter()]

    -- Iterator::values() -> table
    -- Returns a table of values in the Iterator
    --
    values: () =>
        return [value for value, key in @iter()]
}