-- hack:
--  for some reason in Luvit, the local require is Luvit's environment
--  while the global require is Luajit's environment
_G.require = require

require("./init")(function (...)
    -- hack:
    --  this is needed to bootstrap the environment of the project build
    --  otherwise would use the project build as the entrypoint instead
    require("./gmodproj").Application(unpack(process.argv))
end)