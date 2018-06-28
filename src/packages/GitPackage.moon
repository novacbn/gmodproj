import gmatch from string

import Package from "novacbn/gmodproj/api/Package"
import exec, execFormat from "novacbn/gmodproj/lib/utilities/fs"

-- ::PATTERN_GIT_TAG -> string
-- Represents a Lua pattern to extract tags from `git ls-remote --tags`
--
PATTERN_GIT_TAG = "refs/tags/([%w%-%.]+)"

-- GitPackage::GitPackage()
-- Represents a package source for pulling packages from Git repositories
-- export
export GitPackage = Package\extend {
    -- GitPackage::isAvailable() -> boolean
    -- Returns if the Git CLI is installed on this system
    -- static
    isAvailable: () =>
        success, status, stdout = exec("git --version")
        return success

    -- GitPackage::fetch(string url, string directory, string tag?) -> void
    -- Git clones the package into the directory
    -- static
    fetch: (url, directory, tag) =>
        success, status, stdout = execFormat("git", "clone", url, directory)
        error("bad dispatch to 'fetch' (git clone failed)") unless success

        if tag
            success, status, stdout = execFormat("git", "-C", directory, "checkout", "tags/#{tag}")
            error("bad dispatch to 'fetch' (git checkout failed)") unless success

    -- GitPackage::tags(string url) -> table
    -- Git fetches the tags associated with the package
    -- static
    tags: (url) =>
        success, status, stdout = execFormat("git", "ls-remote", "--tags", url)
        error("bad dispatch to 'tags' (git ls-remote failed')") unless success

        return [tag for tag in gmatch(stdout, PATTERN_GIT_TAG)]

    -- GitPackage::formatCanonicalURL(string path) -> string
    -- Validates the URI and returns the canonical representation of the package source
    -- static
    formatCanonicalURL: (scheme, path) =>
        return "#{scheme}://#{path}"
}