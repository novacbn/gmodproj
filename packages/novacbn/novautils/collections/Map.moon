import pairs, next from _G

import Iterator from "novacbn/novautils/collections/Iterator"

-- Map::Map()
-- Represents a generic Object that has an interface for assigning keypairs
-- export
export Map = Iterator\extend {
    -- Map::clear() -> void
    -- Clears all the keypairs in the Map
    --
    clear: () =>
        self[key] = nil for key, value in pairs(self)

    -- Map::get(any key) -> any
    -- Returns the value assigned to the key, if any
    --
    get: (key) =>
        return self[key]

    -- Map::has(any key) -> boolean
    -- Returns if the key has any value assigned to it
    --
    has: (key) =>
        return self[key] ~= nil

    -- Map::find(any searchValue) -> any
    -- Returns the first key assigned to the search value, if any
    --
    find: (searchValue) =>
        for key, value in pairs(self)
            return key if value == searchValue

        return nil

    -- Map::set(key, value) -> void
    -- Assigns the value to the key in the Map
    --
    set: (key, value) =>
        self[key] = value
}