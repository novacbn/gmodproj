import digest from require "openssl"
digest = digest.digest

-- ::hashMD5(string str) -> string
-- Returns a hex representation of a MD5 hash
export hashMD5 = (str) -> digest("MD5", str)

-- ::hashSHA1(string str) -> string
-- Returns a hex representation of a SHA-1 hash
export hashSHA1 = (str) -> digest("SHA1", str)

-- ::hashSHA256(string str) -> string
-- Returns a hex representation of a SHA-256 hash
export hashSHA256 = (str) -> digest("SHA256", str)