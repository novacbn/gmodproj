with exports
    .collections = {
        BitEnum:    dependency("novacbn/novautils/collections/BitEnum").BitEnum
        ByteArray:  dependency("novacbn/novautils/collections/ByteArray").ByteArray
        Enum:       dependency("novacbn/novautils/collections/Enum").Enum
        Iterator:   dependency("novacbn/novautils/collections/Iterator").Iterator
        LinkedList: dependency("novacbn/novautils/collections/LinkedList").LinkedList
        Map:        dependency("novacbn/novautils/collections/Map").Map
        Set:        dependency("novacbn/novautils/collections/Set").Set
    }

    .io = {
        ReadBuffer:     dependency("novacbn/novautils/io/ReadBuffer").ReadBuffer
        WriteBuffer:    dependency("novacbn/novautils/io/WriteBuffer").WriteBuffer
    }

    .sources = {
        Event:      dependency("novacbn/novautils/sources/Event").Event
        Signal:     dependency("novacbn/novautils/sources/Signal").Signal
        Transform:  dependency("novacbn/novautils/sources/Transform").Transform
    }

    .bit        = getmetatable(dependency("novacbn/novautils/bit")).__index
    .math       = getmetatable(dependency("novacbn/novautils/math")).__index
    .table      = getmetatable(dependency("novacbn/novautils/table")).__index

-- Monkey-patch Object into namespace
exports.utilities = with getmetatable(dependency("novacbn/novautils/utilities")).__index
    .Object = dependency("novacbn/novautils/utilities/Object").Object