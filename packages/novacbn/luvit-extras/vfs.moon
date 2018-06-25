import type from _G
import match from string

import Emitter, Object from require "core"

-- ::PATTERN_URI_SCHEME -> string
-- Represents a Lua pattern to validate and extract the URI scheme
--
PATTERN_URI_SCHEME = "^(%l[%l%d%-]*)$"

-- ::PATTERN_URI_PARTS -> string
-- Represents a Lua pattern to validate and extract URI parts
--
PATTERN_URI_PARTS = "^(%l[%l%d%-]*)://([%w%-%./]*)$"

-- ::PATTERN_URI_PATH -> string
-- Represents a Lua pattern to validate and extract the URI path
--
PATTERN_URI_PATH = "^([%w%-%./]+)$"

-- ::makeAdapterBind(string method, boolean isAction) -> any
-- Makes an adapter bind to automatically handle adapter selection
--
makeAdapterBind = (method, isAction) ->
    return (self, uri, ...) ->
        error("bad argument #1 to '#{method}' (expected string)") unless type(uri) == "string"

        scheme, path = match(uri, PATTERN_URI_PARTS)
        error("bad argument #1 to '#{method}' (malformed URI)") unless scheme

        adapter = self.adapters[scheme]
        error("bad argument #1 to '#{method}' (unknown URI scheme)") unless adapter

        adapter[method](adapter, path, ...)

-- VirtualAdapter::VirtualAdapter()
-- Represents a virtual file system adapter
-- export
export VirtualAdapter = with Emitter\extend()
    -- VirtualAdapter::readOnly -> boolean
    -- Represents if the VirtualAdapter is readable
    -- export
    .readOnly = false

    -- VirtualAdapter::initialize(boolean readOnly) -> void
    -- Constructor for VirtualAdapter
    --
    .initialize = (@readOnly) =>

    -- VirtualAdapter::mounted(VirtualFileSystem vfs) -> void
    -- Called when the VirtualAdapter is mounted
    -- event
    .mounted = () =>

    -- VirtualAdapter::dismounted(VirtualFileSystem vfs) -> void
    -- Called when the VirtualAdapter is dismounted
    -- event
    .dismounted = () =>

    -- VirtualAdapter::emit(string event, any ...) -> VirtualAdapter
    -- Emits an event to the VirtualAdapter
    --
    .emit = (event, ...) =>
        -- Dispatch to object event if it exists before emitting
        if self[event] then self[event](self, ...)
        return Emitter.emit(self, event, ...)

-- VirtualFileSystem::VirtualFileSystem()
-- Represents a multi-layered virtual file system
-- export
export VirtualFileSystem = with Object\extend()
    -- VirtualFileSystem::adapters -> table
    -- Represents the registered virtual adapters
    --
    .adapters = nil

    -- VirtualFileSystem::initialize() -> void
    -- Constructor for VirtualFileSystem
    --
    .initialize = () =>
        @adapters = {}

    -- VirtualFileSystem::mount(string scheme, VirtualAdapter adapter) -> VirtualFileSystem
    -- Mounts a virtual adapter as the URI scheme
    --
    .mount = (scheme, adapter) =>
        error("bad argument #1 to 'mount' (expected string)") unless type(scheme) == "string"
        error("bad argument #1 to 'mount' (unexpected URI scheme)") unless match(scheme, PATTERN_URI_SCHEME)
        error("bad argument #1 to 'mount' (expected unmounted scheme)") if @adapters[scheme]
        error("bad argument #2 to 'mount' (expected VirtualAdapter)") unless type(adapter) == "table"

        @adapters[scheme] = adapter
        adapter\emit("mounted", self)
        return self

    -- VirtualFileSystem::dismount(string scheme) -> VirtualFileSystem
    -- Dismounts the virtual adapter mounted from the URI scheme
    --
    .dismount = (scheme) =>
        error("bad argument #1 to 'dismount' (expected string)") unless type(scheme) == "string"
        error("bad argument #1 to 'mount' (malformed URI scheme)") unless match(scheme, PATTERN_URI_SCHEME)
        error("bad argument #1 to 'dismount' (expected mounted scheme)") unless @adapters[scheme]

        @adapters[scheme] = nil
        adapter\emit("dismounted", self)
        return self

    -- VirtualFileSystem::access(string uri, number flags?, function callback) -> void
    -- Tests if the URI is accessible
    --
    .access = makeAdapterBind("access")

    -- VirtualFileSystem::accessSync(string uri, number flags?) -> boolean
    -- Synchronous variant of `access`
    --
    .accessSync = makeAdapterBind("accessSync")

    -- VirtualFileSystem::readdir(string uri, function callback) -> void
    -- Returns the filesystem entries in the URI
    --
    .readdir = makeAdapterBind("readdir")

    -- VirtualFileSystem::readdirSync(string uri) -> table
    -- Synchronous variant of `readdir`
    --
    .readdirSync = makeAdapterBind("readdirSync")

    -- VirtualFileSystem::readFile(string uri, function callback) -> void
    -- Reads all of and returns the contents of the URI
    --
    .readFile = makeAdapterBind("readFile")

    -- VirtualFileSystem::readFileSync(string uri) -> string
    -- Synchronous variant of `readFile`
    --
    .readFileSync = makeAdapterBind("readFileSync")

    -- VirtualFileSystem::rmdir(string uri, function callback) -> void
    -- Removes the URI if it is a directory
    --
    .rmdir = makeAdapterBind("rmdir", true)

    -- VirtualFileSystem::rmdirSync(string uri) -> void
    -- Synchronous variant of `rmdir`
    --
    .rmdirSync = makeAdapterBind("rmdirSync", true)

    -- VirtualFileSystem::stat(string uri, function callback) -> void
    -- Returns the filesystem stats of the URI
    --
    .stat = makeAdapterBind("stat")

    -- VirtualFileSystem::statSync(string uri) -> table
    -- Synchronous variant of `stat`
    --
    .statSync = makeAdapterBind("statSync")

    -- VirtualFileSystem::unlink(string uri, function callback) -> void
    -- Removes the URI if it is a file
    --
    .unlink = makeAdapterBind("unlink", true)

    -- VirtualFileSystem::unlinkSync(string uri) -> void
    -- Synchronous variant of `unlink`
    --
    .unlinkSync = makeAdapterBind("unlinkSync", true)

    -- VirtualFileSystem::writeFile(string uri, string contents, function callback) -> void
    -- Writes the contents to the URI
    --
    .writeFile = makeAdapterBind("writeFile", true)

    -- VirtualFileSystem::writeFileSync(string uri, string contents) -> void
    -- Synchronous variant of `writeFile`
    --
    .writeFileSync = makeAdapterBind("writeFileSync", true)

    -- VirtualFileSystem::walk(string uri, function callback) -> void
    -- Returns the filesystem entries in the URI recursively
    --
    .walk = makeAdapterBind("walk")

    -- VirtualFileSystem::walkSync(string uri) -> table
    -- Synchronous variant of `walk`
    --
    .walkSync = makeAdapterBind("walkSync")


