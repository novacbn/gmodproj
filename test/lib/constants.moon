import join from require "path"

import tmpdir from require "test/lib/utilities"

-- ::BINARY_DIST -> string
-- Represents the path to the built development binary
-- export
BINARY_DIST = join(PROJECT_PATH.home, "dist", "gmodproj-dev.#{SYSTEM_OS_ARCH}.#{SYSTEM_OS_TYPE}")
BINARY_DIST ..= ".exe" if SYSTEM_OS_TYPE == "Windows"

-- ::TMP_DIR -> string
-- Represents the temporary directory used for this instance
-- export
TMP_DIR = tmpdir()

return :BINARY_DIST, :TMP_DIR