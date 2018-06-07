import
    getmetatable, pairs, rawget,
    setmetatable, type from _G

import bind from "novacbn/novautils/utilities"
import clone, keysMeta from "novacbn/novautils/table"

-- Object::Object()
-- Represents a simple generic inheritable OOP object
-- export
export Object = {
    -- Object::new(table objectClass, any ...) -> table
    -- Makes a new instance of an Object class
    -- static
    new: (objectClass, ...) ->
        -- Make a new table that inherits the parent object
        newInstance = setmetatable({}, objectClass)

        -- If any assigned Decorator instances, call the '__initialized' metaevent
        metaKeys = keysMeta(objectClass)
        for key, value in pairs(metaKeys)
            if type(value) == "table" and isInstance(Decorator, value)
                value\__initialized(newInstance, key)

        -- Call the constructor, if available, then return the new Object instance
        newInstance\constructor(...) if newInstance.constructor
        return newInstance

    -- Object::extend(table parentClass, table objectMembers) -> table
    -- Makes the provided table extend the parent Object class
    -- static
    extend: (parentClass, objectMembers) ->
        -- Extend the parent Object class
        objectMembers.__index = objectMembers
        setmetatable(objectMembers, parentClass)

        -- Loop Decorators to call assignment metaevents
        for key, value in pairs(objectMembers)
            if type(value) == "table" and isInstance(Decorator, value)
                value\__assigned(objectMembers, key)

        -- Call the extension metaevent if the parent Object class contains it
        parentClass\__extended(objectMembers) if parentClass.__extended
        return objectMembers
}

Object.__index = Object

-- ::isInstance(table parentObject, table targetObject) -> boolean
-- Returns if the target object is an instance of the parent object
-- export
export isInstance = (parentObject, targetObject) ->
    if rawget(targetObject, "__index") ~= targetObject
        return hasInherited(parentObject, targetObject)

    return false

-- ::hasInherited(table parentObject, table targetObject) -> boolean
-- Returns if the target object inherited from the parent object
-- export
export hasInherited = (parentObject, targetObject) ->
    metaTable = targetObject
    while metaTable
        return true if metaTable == parentObject
        metaTable = getmetatable(metaTable)

    return false

-- Decorator::Decorator()
-- Inheritable generic object that allows for enhancing of Object members
-- export
export Decorator = Object\extend {
    -- Decorator::__call(any ...) -> table
    -- Metaevent called to shortcut inherited Decorator initialization
    -- metaevent
    __call: (...) => self.new(self, ...)

    -- Decorator::__assigned(table objectClass, string memberName) -> void
    -- Metaevent called whenever assigned to a Object class
    -- metaevent
    __assigned: (objectClass, memberName) =>

    -- Decorator::__initialized(table objectInstance, string memberName) -> void
    -- Metaevent called whenever a Object class is initialized with this Decorator as a member
    -- metaevent
    __initialized: (objectInstance, memberName) =>
}

-- Default::Default()
-- Quality of life object for assigning default values on Object initialization
-- export
export Default = Decorator\extend {
    -- Default::constructor(any defaultValue, any ...) -> void
    -- Constructor for default
    --
    constructor: (defaultValue, ...) =>
        switch type(defaultValue)
            when "table"
                -- Construct the default value if Object, clone the default value if plain table
                if hasInherited(Object, defaultValue) then @generator = bind(defaultValue.new, defaultValue, ...)
                else @generator = bind(clone, defaultValue)

            when "function"
                -- Bind into a generator if function type
                @generator = bind(defaultValue, ...)

         -- Store value for later lookups
        @defaultValue = defaultValue

    -- Default::__initialized(table newObject, string memberName) -> void
    -- Metaevent for hooking into an object right before constructor call
    -- metaevent
    __initialized: (newObject, memberName) =>
        -- If generator provided, generate new value, or use the static value
        newObject[memberName] = @generator and @generator() or @defaultValue
}