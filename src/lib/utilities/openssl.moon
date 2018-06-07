import base64, digest from require "openssl"
digest = digest.digest

-- ::decodeB64(string str) -> string
-- Returns the string decoded from Base64
export decodeB64 = (str) -> base64(str, false)

-- ::encodeB64(string str) -> string
-- Returns the string encoded as Base64
export encodeB64 = (str) -> base64(str, true)

-- ::hashMD5(string str) -> string
-- Returns a hex representation of a MD5 hash
export hashMD5 = (str) -> digest("MD5", str)

-- ::hashSHA1(string str) -> string
-- Returns a hex representation of a SHA-1 hash
export hashSHA1 = (str) -> digest("SHA1", str)

-- ::hashSHA256(string str) -> string
-- Returns a hex representation of a SHA-256 hash
export hashSHA256 = (str) -> digest("SHA256", str)