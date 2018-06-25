import chdir from require "novacbn/luvit-extras/process"

import TMP_DIR from require "test/lib/constants"

chdir(TMP_DIR)

-- The order of the command testing should remain as-is
require "test/commands/new"
require "test/commands/build"