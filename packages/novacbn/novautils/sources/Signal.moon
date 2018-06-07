import LinkedList from "novacbn/novautils/collections/LinkedList"

-- ::makeDetachFunc(table signal, function listenerNode) -> function
-- Returns a shortcut function to detach the listener Node
--
makeDetachFunc = (signal, node) ->
    return () ->
        -- If not previously detached, detach the listener Node now
        unless node.removed
            signal\remove(node)
            return false

        -- Return true since previously detached from the Signal
        return true

-- Signal::Signal()
-- Represents a generic Signal dispatcher
-- export
export Signal = LinkedList\extend {
    -- Signal::attach(function listenerFunc) -> function
    -- Attaches the listener function to the Signal, returning a shortcut function for detachment
    --
    attach: (listenerFunc) =>
        -- Make and return a shortcut detach function
        node = @push(listenerFunc)
        return makeDetachFunc(self, node)

    -- Signal::dispatch(any ...) -> void
    -- Dispatches the vararg to all the currently attached listeners
    --
    dispatch: (...) =>
        -- Dispatches the vararg to the attached listeners
        node.value(...) for node in self\iter()

    -- Signal::detach(function listenerFunc) -> void
    -- Detaches the listener function from the Signal
    --
    detach: (listenerFunc) =>
        -- Retrieve the node for the listener function, then detach it
        node = @find(listenerFunc)
        error("bad argument #1 to 'detach' (function not attached)") unless node
        @remove(node)
}