uv = require "uv"

import makeAdaptedSync from "novacbn/luvit-extras/utils"

-- ::chdir(string directory) -> void
-- Changes the current working directory of the process
-- export
export chdir = makeAdaptedSync(uv.chdir)

-- ::exepath() -> string
-- Returns the path to the environment's executable
-- export
export exepath = makeAdaptedSync(uv.exepath)

-- ::homedir() -> string
-- Returns the current user's home directory
-- export
export homedir = makeAdaptedSync(uv.os_homedir)

-- ::tmpdir() -> string
-- Returns the temporary directory of the operating system
-- export
export tmpdir = makeAdaptedSync(uv.os_tmpdir)