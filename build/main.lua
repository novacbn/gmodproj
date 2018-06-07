-- HACKY:
--  for some reason in Luvit, the local require is Luvit's environment
--  while the global require is LuaJIT's environment
_G.require = require

require("./init")(function (...)
    -- NOTE:
    --  this is needed to bootstrap the environment of the project build
    --  otherwise would use the project build as the entrypoint instead

    local function onError(err)
        -- Capture any unexpected exceptions and crash the application
        print("PLEASE REPORT THIS UNHANDLED EXCEPTION:")
        print(err)
        print(debug.traceback())
        process:exit(1)
    end

    xpcall(function ()
        require("./gmodproj")
    end, onError)
end)