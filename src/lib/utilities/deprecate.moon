import print from _G

-- ::DEPRECATION_FEATURE_KEYS -> table
-- Represents the features that were already deprecated
--
DEPRECATION_FEATURE_KEYS = {}

-- ::deprecate(string featureKey, string text) -> void
-- Prints the deprecation text once per feature key
-- export
export deprecate = (featureKey, text) ->
    unless DEPRECATION_FEATURE_KEYS[featureKey]
        print(text)
        DEPRECATION_FEATURE_KEYS[featureKey] = true