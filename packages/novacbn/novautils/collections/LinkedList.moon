import Iterator from "novacbn/novautils/collections/Iterator"

-- ::Node(any value, Node prev, Node next) -> table
-- Represents a primitive Node of a LinkedList
--
Node = (value, prev, next) -> {
    :value, :prev, :next,
    removed: false
}

-- LinkedList::LinkedList()
-- Represents a generic doubly linked-list
-- export
export LinkedList = Iterator\extend {
    -- LinkedList::head -> Node
    -- Represents the head Node of the LinkedList
    --
    head: nil

    -- LinkedList::length -> number
    -- Represents the current length of the LinkedList
    --
    length: 0

    -- LinkedList::tail -> Node
    -- Represents the tail Node of the LinkedList
    --
    tail: nil

    -- LinkedList::__iter(boolean reverse) -> function
    -- Metaevent for returning a stateful iterator for the LinkedList, performs reverse iteration if specified
    -- metaevent 
    __iter: (reverse=false) =>
        -- Return a stateful iterator configured to start at the head Node
        currentNode = {next: reverse and @tail or @head}
        return () ->
            if currentNode
                -- Increment the iterator then return current
                currentNode = currentNode.next
                return currentNode if currentNode

    -- LinkedList::clear() -> void
    -- Clears the head and tail nodes of the LinkedList
    --
    clear: () =>
        -- Dropping the head and tail nodes effectively clears it, GC will collect later
        @head = nil
        @tail = nil

    -- LinkedList::find(any value) -> Node or nil
    -- Returns the first Node that matches the value
    --
    find: (value) =>
        -- Search for the Node in the LinkedList
        for node in @iter()
            return node if node.value == value

        -- Return nothing due to not finding Node
        return nil

    -- LinkedList::has(any value) -> boolean
    -- Returns if the value is in the LinkedList
    --
    has: (value) =>
        -- Search the for the Node in the LinkedList
        for node in @iter()
            return true if node.value == value

        -- Return false due to not finding Node
        return false

    -- LinkedList::pop() -> Node
    -- Removes the tail Node of the LinkedList, returning the popped Node
    --
    pop: () =>
        -- Retrieve the last node in the LinkedList, removing it before returning
        error("bad call to 'pop' (no Nodes available to pop)") unless @tail
        return @remove(@tail)

    -- LinkedList::push(any value) -> Node
    -- Appends the value to the LinkedList, returning the newly made Node
    --
    push: (value) =>
        -- Make a new node for the value and assign as tail
        node        = Node(value, @tail, nil)
        @tail.next  = node if @tail
        @tail       = node

        -- Assign the new Node as the head if non existant
        @head = node unless @head

        -- Increment the LinkedList's length and return the new Node
        @length += 1
        return node

    -- LinkedList::remove(table node) -> Node
    -- Removes the Node from the LinkedList, correcting any references and returning the removed Node
    --
    remove: (node) =>
        -- Raise error if the node was already removed
        error("bad argument #1 to 'remove' (node was already removed)") if node.removed

        -- Correct the next and previous nodes' references
        node.prev.next = node.next if node.prev
        node.next.prev = node.prev if node.next

        -- Correct the LinkedList's references
        @head = node.next if @head == node
        @tail = node.prev if @tail == node

        -- Flag the node that it's been removed
        node.removed    = true
        node.prev       = nil
        node.next       = nil

        -- Decrement the LinkedList's length and return the Node
        @length -= 1
        return node

    -- LinkedList::pop() -> Node
    -- Removes the head Node of the LinkedList, returning the Node's value
    --
    shift: () =>
        -- Retrieve the first node in the LinkedList, removing it before returning
        error("bad call to 'shift' (no nodes available to shift)") unless @head
        return @remove(@head)

    -- LinkedList::unshift(any value) -> Node
    -- Prepends the value to the LinkedList, returning the newly made Node
    --
    unshift: (value) =>
        -- Make a new node for the value and assign as tail
        node        = Node(value, nil, @head)
        @head.prev  = node if @head
        @head       = node

        -- Assign the new Node as the tail if non existant
        @tail = node unless @tail

        -- Increment the LinkedList's length and return the new Node
        @length += 1
        return node

    -- LinkedList::values() -> table
    -- Returns a table of values in the LinkedList
    --
    values: () =>
        return [node.value for node in @iter()]
}