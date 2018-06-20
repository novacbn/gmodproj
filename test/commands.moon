import chdir from require "uv"

import TMP_DIR from require "test/lib/constants"

chdir(TMP_DIR)

-- The order of the command testing should remain as-is
require "test/commands/new"
require "test/commands/build"