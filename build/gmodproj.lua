return (function (modules, ...)
    local _G            = _G
    local error         = _G.error
    local setfenv       = _G.setfenv
    local setmetatable  = _G.setmetatable

    local moduleCache       = {}
    local packageGlobals    = {}

    local function makeEnvironment(moduleChunk)
        local exports = {}

        local moduleEnvironment = setmetatable({}, {
            __index = function (self, key)
                if exports[key] ~= nil then
                    return exports[key]
                end

                return _G[key]
            end,

            __newindex = exports
        })

        return setfenv(moduleChunk, moduleEnvironment), exports
    end

    local function makeModuleHeader(moduleName)
        return {
            name    = moduleName,
            globals = packageGlobals
        }
    end

    local function makeReadOnly(tbl)
        return setmetatable({}, {
            __index = tbl,
            __newindex = function (self, key, value) error("module 'exports' table is read only") end
        })
    end

    local import = nil
    function import(moduleName, ...)
        local moduleChunk = modules[moduleName]
        if not moduleChunk then error("bad argument #1 to 'import' (invalid module, got '"..moduleName.."')") end

        if not moduleCache[moduleName] then
            local moduleHeader                  = makeModuleHeader(moduleName)
            local moduleEnvironment, exports    = makeEnvironment(moduleChunk)

            moduleEnvironment(moduleHeader, exports, import, import, ...)

            moduleCache[moduleName] = makeReadOnly(exports)
        end

        return moduleCache[moduleName]
    end

    local loadstring = _G.loadstring

    for moduleName, assetChunk in pairs(modules) do
        modules[moduleName] = loadstring('return function (module, exports, import, dependency, ...) '..assetChunk..' end', moduleName)()
    end

    return import('novacbn/gmodproj/main', ...)
end)({['davidm/globtopattern/main'] = "_TYPE       = 'module'\
_NAME       = 'globtopattern'\
_VERSION    = '0.2.1.20120406'\
\
function globtopattern(g)\
  -- Some useful references:\
  -- - apr_fnmatch in Apache APR.  For example,\
  --   http://apr.apache.org/docs/apr/1.3/group__apr__fnmatch.html\
  --   which cites POSIX 1003.2-1992, section B.6.\
\
  local p = \"^\"  -- pattern being built\
  local i = 0    -- index in g\
  local c        -- char at index i in g.\
\
  -- unescape glob char\
  local function unescape()\
    if c == '\\\\' then\
      i = i + 1; c = g:sub(i,i)\
      if c == '' then\
        p = '[^]'\
        return false\
      end\
    end\
    return true\
  end\
\
  -- escape pattern char\
  local function escape(c)\
    return c:match(\"^%w$\") and c or '%' .. c\
  end\
\
  -- Convert tokens at end of charset.\
  local function charset_end()\
    while 1 do\
      if c == '' then\
        p = '[^]'\
        return false\
      elseif c == ']' then\
        p = p .. ']'\
        break\
      else\
        if not unescape() then break end\
        local c1 = c\
        i = i + 1; c = g:sub(i,i)\
        if c == '' then\
          p = '[^]'\
          return false\
        elseif c == '-' then\
          i = i + 1; c = g:sub(i,i)\
          if c == '' then\
            p = '[^]'\
            return false\
          elseif c == ']' then\
            p = p .. escape(c1) .. '%-]'\
            break\
          else\
            if not unescape() then break end\
            p = p .. escape(c1) .. '-' .. escape(c)\
          end\
        elseif c == ']' then\
          p = p .. escape(c1) .. ']'\
          break\
        else\
          p = p .. escape(c1)\
          i = i - 1 -- put back\
        end\
      end\
      i = i + 1; c = g:sub(i,i)\
    end\
    return true\
  end\
\
  -- Convert tokens in charset.\
  local function charset()\
    i = i + 1; c = g:sub(i,i)\
    if c == '' or c == ']' then\
      p = '[^]'\
      return false\
    elseif c == '^' or c == '!' then\
      i = i + 1; c = g:sub(i,i)\
      if c == ']' then\
        -- ignored\
      else\
        p = p .. '[^'\
        if not charset_end() then return false end\
      end\
    else\
      p = p .. '['\
      if not charset_end() then return false end\
    end\
    return true\
  end\
\
  -- Convert tokens.\
  while 1 do\
    i = i + 1; c = g:sub(i,i)\
    if c == '' then\
      p = p .. '$'\
      break\
    elseif c == '?' then\
      p = p .. '.'\
    elseif c == '*' then\
      p = p .. '.*'\
    elseif c == '[' then\
      if not charset() then break end\
    elseif c == '\\\\' then\
      i = i + 1; c = g:sub(i,i)\
      if c == '' then\
        p = p .. '\\\\$'\
        break\
      end\
      p = p .. escape(c)\
    else\
      p = p .. escape(c)\
    end\
  end\
  return p\
end",
['novacbn/gmodproj/Packager'] = "local unpack\
unpack = _G.unpack\
local match\
match = string.match\
local insert, sort\
do\
  local _obj_0 = table\
  insert, sort = _obj_0.insert, _obj_0.sort\
end\
local writeFileSync\
writeFileSync = require(\"fs\").writeFileSync\
local globtopattern\
globtopattern = dependency(\"davidm/globtopattern/main\").globtopattern\
local mapi\
mapi = dependency(\"novacbn/novautils/table\").mapi\
local Set\
Set = dependency(\"novacbn/novautils/collections/Set\").Set\
local WriteBuffer\
WriteBuffer = dependency(\"novacbn/novautils/io/WriteBuffer\").WriteBuffer\
local Default, Object\
do\
  local _obj_0 = dependency(\"novacbn/novautils/utilities/Object\")\
  Default, Object = _obj_0.Default, _obj_0.Object\
end\
local logInfo, logFatal\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/logging\")\
  logInfo, logFatal = _obj_0.logInfo, _obj_0.logFatal\
end\
local PackagerOptions\
PackagerOptions = dependency(\"novacbn/gmodproj/schemas/PackagerOptions\").PackagerOptions\
Packager = Object:extend({\
  canCache = false,\
  excludedAssets = nil,\
  flags = nil,\
  isProduction = nil,\
  loadedAssets = Default({ }),\
  registeredPlatforms = Default({ }),\
  resolver = nil,\
  targetPlatform = nil,\
  constructor = function(self, isProduction, flags, resolver, pluginManager, options)\
    self.isProduction, self.resolver = isProduction, resolver\
    options = PackagerOptions:new(options)\
    self.includedAssets = mapi(options:get(\"includedAssets\"), function(i, v)\
      return globtopattern(v)\
    end)\
    self.excludedAssets = mapi(options:get(\"excludedAssets\"), function(i, v)\
      return globtopattern(v)\
    end)\
    self.canCache = not (flags[\"-nc\"] or flags[\"--no-cache\"])\
    pluginManager:dispatchEvent(\"registerPlatforms\", self)\
    local targetPlatform = self.registeredPlatforms[options:get(\"targetPlatform\")]\
    if not (targetPlatform) then\
      logFatal(\"cannot target platform '\" .. tostring(targetPlatform) .. \"'\")\
    end\
    self.targetPlatform = targetPlatform:new(isProduction)\
  end,\
  collectDependencies = function(self, defaultAssets)\
    local collectedDependencies = Set:fromTable(defaultAssets)\
    local excludedAssets = self.excludedAssets\
    local assetType, assetPath, loadedAsset, excludedAsset\
    for assetName in collectedDependencies:iter() do\
      if not (self.loadedAssets[assetName]) then\
        assetType, assetPath = self.resolver:resolveAsset(assetName)\
        if not (assetType) then\
          logFatal(\"asset '\" .. tostring(assetName) .. \"' could not be resolved\")\
        end\
        self.loadedAssets[assetName] = assetType:new(assetName, assetPath, self.canCache, self.isProduction)\
      end\
      loadedAsset = self.loadedAssets[assetName]\
      loadedAsset:generateAsset()\
      local _list_0 = loadedAsset.assetData:get(\"dependencies\")\
      for _index_0 = 1, #_list_0 do\
        local assetName = _list_0[_index_0]\
        excludedAsset = false\
        for _index_1 = 1, #excludedAssets do\
          local assetPattern = excludedAssets[_index_1]\
          if match(assetName, assetPattern) then\
            excludedAsset = true\
            break\
          end\
        end\
        if not (excludedAsset) then\
          collectedDependencies:push(assetName)\
        end\
      end\
    end\
    collectedDependencies = collectedDependencies:values()\
    sort(collectedDependencies)\
    return collectedDependencies\
  end,\
  registerPlatform = function(self, platformName, platform)\
    self.registeredPlatforms[platformName] = platform\
  end,\
  writePackage = function(self, entryPoint, endPoint)\
    local defaultAssets = {\
      entryPoint\
    }\
    if #self.includedAssets > 0 then\
      local _list_0 = self.resolver:resolveAssets()\
      for _index_0 = 1, #_list_0 do\
        local assetName = _list_0[_index_0]\
        local _list_1 = self.includedAssets\
        for _index_1 = 1, #_list_1 do\
          local assetPattern = _list_1[_index_1]\
          if match(assetName, assetPattern) then\
            insert(defaultAssets, assetName)\
          end\
        end\
      end\
    end\
    local buffer = WriteBuffer:new()\
    buffer:writeString(self.targetPlatform:generatePackageHeader(entryPoint))\
    local loadedAsset\
    local _list_0 = self:collectDependencies(defaultAssets)\
    for _index_0 = 1, #_list_0 do\
      local assetName = _list_0[_index_0]\
      loadedAsset = self.loadedAssets[assetName]\
      buffer:writeString(self.targetPlatform:generatePackageModule(assetName, loadedAsset.assetData:get(\"output\")))\
    end\
    buffer:writeString(self.targetPlatform:generatePackageFooter())\
    local contents = self.targetPlatform:transformPackage(buffer:toString())\
    return writeFileSync(endPoint, contents)\
  end\
})",
['novacbn/gmodproj/PluginManager'] = "local loadstring, pairs, pcall\
do\
  local _obj_0 = _G\
  loadstring, pairs, pcall = _obj_0.loadstring, _obj_0.pairs, _obj_0.pcall\
end\
local readFileSync\
readFileSync = require(\"fs\").readFileSync\
local join\
join = require(\"path\").join\
local Default, Object\
do\
  local _obj_0 = dependency(\"novacbn/novautils/utilities/Object\")\
  Default, Object = _obj_0.Default, _obj_0.Object\
end\
local APPLICATION_CORE_VERSION, PROJECT_PATH, USER_PATH\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/constants\")\
  APPLICATION_CORE_VERSION, PROJECT_PATH, USER_PATH = _obj_0.APPLICATION_CORE_VERSION, _obj_0.PROJECT_PATH, _obj_0.USER_PATH\
end\
local logFatal\
logFatal = dependency(\"novacbn/gmodproj/lib/logging\").logFatal\
local isFile\
isFile = dependency(\"novacbn/gmodproj/lib/utilities/fs\").isFile\
local loadPlugin\
loadPlugin = function(pluginName)\
  local pluginPath = join(PROJECT_PATH.plugins, pluginName) .. \".lua\"\
  if isFile(pluginPath) then\
    local contents = readFileSync(pluginPath)\
    local pluginChunk, err = loadstring(contents, \"project-plugin:\" .. pluginName)\
    if pluginChunk then\
      return pluginChunk(), nil\
    end\
    return nil, err\
  end\
  pluginPath = join(USER_PATH.plugins, pluginName) .. \".lua\"\
  if isFile(pluginPath) then\
    local contents = readFileSync(pluginPath)\
    local pluginChunk, err = loadstring(contents, \"user-plugin:\" .. pluginName)\
    if pluginChunk then\
      return pluginChunk(), nil\
    end\
    return nil, err\
  end\
  local success, exports = pcall(require, \"plugins/\" .. pluginName)\
  if success then\
    return exports, nil\
  end\
  return nil, exports\
end\
PluginManager = Object:extend({\
  loadedPlugins = Default({ }),\
  constructor = function(self, pluginMap)\
    local pluginExports, pluginError\
    for pluginName, pluginOptions in pairs(pluginMap) do\
      pluginExports, pluginError = loadPlugin(pluginName)\
      if not (pluginExports) then\
        logFatal(\"plugin '\" .. tostring(pluginName) .. \"' could not be loaded:\\n\" .. tostring(pluginError))\
      end\
      self.loadedPlugins[pluginName] = pluginExports.Plugin:new(pluginOptions)\
    end\
  end,\
  dispatchEvent = function(self, eventName, ...)\
    for pluginName, pluginObject in pairs(self.loadedPlugins) do\
      pluginObject[eventName](pluginObject, ...)\
    end\
  end\
})\
_G.gmodproj = {\
  api = {\
    Asset = dependency(\"novacbn/gmodproj/api/Asset\").Asset,\
    DataAsset = dependency(\"novacbn/gmodproj/api/DataAsset\").DataAsset,\
    Platform = dependency(\"novacbn/gmodproj/api/Platform\").Platform,\
    Plugin = dependency(\"novacbn/gmodproj/api/Plugin\").Plugin,\
    ResourceAsset = dependency(\"novacbn/gmodproj/api/ResourceAsset\").ResourceAsset,\
    Schema = dependency(\"novacbn/gmodproj/api/Schema\").Schema,\
    Template = dependency(\"novacbn/gmodproj/api/Template\").Template\
  },\
  require = dependency,\
  version = APPLICATION_CORE_VERSION\
}",
['novacbn/gmodproj/Resolver'] = "local unpack\
unpack = _G.unpack\
local match\
match = string.match\
local insert\
insert = table.insert\
local readdirSync\
readdirSync = require(\"fs\").readdirSync\
local basename, dirname, extname, join\
do\
  local _obj_0 = require(\"path\")\
  basename, dirname, extname, join = _obj_0.basename, _obj_0.dirname, _obj_0.extname, _obj_0.join\
end\
local Set\
Set = dependency(\"novacbn/novautils/collections/Set\").Set\
local Default, Object\
do\
  local _obj_0 = dependency(\"novacbn/novautils/utilities/Object\")\
  Default, Object = _obj_0.Default, _obj_0.Object\
end\
local ResolverOptions\
ResolverOptions = dependency(\"novacbn/gmodproj/schemas/ResolverOptions\").ResolverOptions\
local PROJECT_PATH\
PROJECT_PATH = dependency(\"novacbn/gmodproj/lib/constants\").PROJECT_PATH\
local isFile\
isFile = dependency(\"novacbn/gmodproj/lib/utilities/fs\").isFile\
local makeStringEscape\
makeStringEscape = dependency(\"novacbn/gmodproj/lib/utilities/string\").makeStringEscape\
local escapePattern = makeStringEscape({\
  {\
    \"%-\",\
    \"%%-\"\
  }\
})\
local collectFiles\
collectFiles = function(baseDirectory, files, subDirectory)\
  if files == nil then\
    files = { }\
  end\
  local currentDirectory = subDirectory and join(baseDirectory, subDirectory) or baseDirectory\
  local _list_0 = readdirSync(currentDirectory)\
  for _index_0 = 1, #_list_0 do\
    local fileName = _list_0[_index_0]\
    if isFile(join(currentDirectory, fileName)) then\
      insert(files, subDirectory and subDirectory .. \"/\" .. fileName or fileName)\
    else\
      collectFiles(baseDirectory, files, subDirectory and subDirectory .. \"/\" .. fileName or fileName)\
    end\
  end\
  return files\
end\
Resolver = Object:extend({\
  registeredAssets = Default({ }),\
  projectPattern = nil,\
  sourceDirectory = nil,\
  constructor = function(self, projectAuthor, projectName, sourceDirectory, pluginManager, options)\
    self.options = ResolverOptions:new(options)\
    pluginManager:dispatchEvent(\"registerAssets\", self)\
    self.projectPrefix = tostring(projectAuthor) .. \"/\" .. tostring(projectName)\
    self.sourceDirectory = join(PROJECT_PATH.home, sourceDirectory)\
  end,\
  resolveAsset = function(self, assetName)\
    local projectAsset = match(assetName, \"^\" .. tostring(escapePattern(self.projectPrefix)) .. \"/([%w/%-]+)\")\
    if projectAsset then\
      local assetPath\
      for assetExtension, assetType in pairs(self.registeredAssets) do\
        assetPath = join(self.sourceDirectory, tostring(projectAsset) .. \".\" .. tostring(assetExtension))\
        if isFile(assetPath) then\
          return assetType, assetPath\
        end\
      end\
    end\
    local assetFile, assetPath\
    local searchPaths = self.options:get(\"searchPaths\")\
    for assetExtension, assetType in pairs(self.registeredAssets) do\
      assetFile = tostring(assetName) .. \".\" .. tostring(assetExtension)\
      for _index_0 = 1, #searchPaths do\
        local searchPath = searchPaths[_index_0]\
        assetPath = join(searchPath, assetFile)\
        if isFile(assetPath) then\
          return assetType, assetPath\
        end\
      end\
    end\
    return nil, nil\
  end,\
  resolveAssets = function(self)\
    local resolvedAssets = Set:new()\
    local directoryName\
    local _list_0 = collectFiles(self.sourceDirectory)\
    for _index_0 = 1, #_list_0 do\
      local fileName = _list_0[_index_0]\
      for assetExtension, assetType in pairs(self.registeredAssets) do\
        if extname(fileName) == \".\" .. assetExtension then\
          directoryName = dirname(fileName)\
          resolvedAssets:push(self.projectPrefix .. \"/\" .. (directoryName and directoryName .. \"/\" .. basename(fileName, \".\" .. assetExtension) or basename(fileName, \".\" .. assetExtension)))\
        end\
      end\
    end\
    local searchPaths = self.options:get(\"searchPaths\")\
    for _index_0 = 1, #searchPaths do\
      local searchPath = searchPaths[_index_0]\
      local _list_1 = collectFiles(searchPath)\
      for _index_1 = 1, #_list_1 do\
        local fileName = _list_1[_index_1]\
        for assetExtension, assetType in pairs(self.registeredAssets) do\
          if extname(fileName) == \".\" .. assetExtension then\
            directoryName = dirname(fileName)\
            resolvedAssets:push(directoryName and directoryName .. \"/\" .. basename(fileName, \".\" .. assetExtension) or basename(fileName, \".\" .. assetExtension))\
          end\
        end\
      end\
    end\
    return resolvedAssets:values()\
  end,\
  registerAsset = function(self, assetExtension, assetType)\
    self.registeredAssets[assetExtension] = assetType\
  end\
})",
['novacbn/gmodproj/api/Asset'] = "local pcall\
pcall = _G.pcall\
local readFileSync, statSync, writeFileSync\
do\
  local _obj_0 = require(\"fs\")\
  readFileSync, statSync, writeFileSync = _obj_0.readFileSync, _obj_0.statSync, _obj_0.writeFileSync\
end\
local join\
join = require(\"path\").join\
local decode, encode\
do\
  local _obj_0 = dependency(\"rxi/json/main\")\
  decode, encode = _obj_0.decode, _obj_0.encode\
end\
local Object\
Object = dependency(\"novacbn/novautils/utilities/Object\").Object\
local PROJECT_PATH\
PROJECT_PATH = dependency(\"novacbn/gmodproj/lib/constants\").PROJECT_PATH\
local hashSHA1\
hashSHA1 = dependency(\"novacbn/gmodproj/lib/utilities/openssl\").hashSHA1\
local logInfo, logWarn\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/logging\")\
  logInfo, logWarn = _obj_0.logInfo, _obj_0.logWarn\
end\
local isFile\
isFile = dependency(\"novacbn/gmodproj/lib/utilities/fs\").isFile\
local AssetData\
AssetData = dependency(\"novacbn/gmodproj/schemas/AssetData\").AssetData\
Asset = Object:extend({\
  assetData = nil,\
  assetName = nil,\
  assetPath = nil,\
  cachePath = nil,\
  canCache = nil,\
  isCacheable = true,\
  isProduction = nil,\
  constructor = function(self, assetName, assetPath, canCache, isProduction)\
    self.assetName, self.assetPath, self.canCache, self.isProduction = assetName, assetPath, canCache, isProduction\
    self.cachePath = join(PROJECT_PATH.cache, hashSHA1(self.assetName))\
  end,\
  generateAsset = function(self)\
    if not (self.assetData) then\
      if self.isCacheable and self.canCache and isFile(self.cachePath) then\
        local assetData = decode(readFileSync(self.cachePath))\
        local success\
        success, assetData = pcall(AssetData.new, AssetData, assetData)\
        if success then\
          self.assetData = assetData\
        else\
          logWarn(\"Cache of asset '\" .. tostring(self.assetName) .. \"' could not be processed, regenerating asset...\")\
        end\
      end\
      if not (self.assetData) then\
        self.assetData = AssetData:new()\
      end\
    end\
    local modificationTime = statSync(self.assetPath).mtime.sec\
    if self.assetPath == self.assetData:get(\"metadata.path\") and self.assetData:get(\"metadata.mtime\") == modificationTime then\
      return \
    end\
    local contents = readFileSync(self.assetPath)\
    contents = self:preTransform(contents)\
    local collectedDependencies = self:collectDependencies(contents)\
    local collectDocumentation = self:collectDocumentation(contents)\
    contents = self:postTransform(contents)\
    self.assetData = AssetData:new({\
      metadata = {\
        name = self.assetName,\
        mtime = modificationTime,\
        path = self.assetPath\
      },\
      dependencies = collectedDependencies,\
      exports = collectedDocumentation,\
      output = contents\
    })\
    if self.isCacheable and self.canCache then\
      writeFileSync(self.cachePath, encode(self.assetData.options))\
    end\
    return logInfo(\"\\t...regenerated asset '\" .. tostring(self.assetName) .. \"'\")\
  end,\
  collectDependencies = function(self, contents)\
    return { }\
  end,\
  collectDocumentation = function(self, contents)\
    return { }\
  end,\
  preTransform = function(self, contents)\
    return contents\
  end,\
  postTransform = function(self, contents)\
    return contents\
  end\
})",
['novacbn/gmodproj/api/DataAsset'] = "local basename\
basename = require(\"path\").basename\
local block\
block = dependency(\"pkulchenko/serpent/main\").block\
local Asset\
Asset = dependency(\"novacbn/gmodproj/api/Asset\").Asset\
local TEMPLATE_MODULE_LUA\
TEMPLATE_MODULE_LUA = function(assetName, luaTable)\
  return \"exports['\" .. tostring(basename(assetName)) .. \"'] = \" .. tostring(luaTable)\
end\
DataAsset = Asset:extend({\
  postTransform = function(self, contents)\
    local luaTable = block(contents, {\
      comment = false\
    })\
    return TEMPLATE_MODULE_LUA(self.assetName, luaTable)\
  end\
})",
['novacbn/gmodproj/api/Platform'] = "local Object\
Object = dependency(\"novacbn/novautils/utilities/Object\").Object\
Platform = Object:extend({\
  isProduction = nil,\
  constructor = function(self, isProduction)\
    self.isProduction = isProduction\
  end,\
  generatePackageHeader = function(self, entryPoint)\
    return \"\"\
  end,\
  generatePackageModule = function(self, assetName, assetChunk)\
    return error(\"bad dispatch to 'generatePackageModule' (method not implemented)\")\
  end,\
  generatePackageFooter = function(self)\
    return \"\"\
  end,\
  transformPackage = function(self, packageContents)\
    return packageContents\
  end\
})",
['novacbn/gmodproj/api/Plugin'] = "local Object\
Object = dependency(\"novacbn/novautils/utilities/Object\").Object\
Plugin = Object:extend({\
  schema = nil,\
  constructor = function(self, options)\
    if self.schema then\
      self.schema.namespace = \"Plugins['\" .. self.schema.namespace .. \"']\"\
      self.options = self.schema:new(options)\
    end\
  end,\
  registerAssets = function(self, resolver) end,\
  registerTemplates = function(self, application) end,\
  registerPlatforms = function(self, packager) end\
})",
['novacbn/gmodproj/api/ResourceAsset'] = "local basename\
basename = require(\"path\").basename\
local Asset\
Asset = dependency(\"novacbn/gmodproj/api/Asset\").Asset\
local toByteString\
toByteString = dependency(\"novacbn/gmodproj/lib/utilities/string\").toByteString\
local TEMPLATE_MODULE_LUA\
TEMPLATE_MODULE_LUA = function(assetName, byteString)\
  return \"local byteTable     = \" .. tostring(byteString) .. \"\\nlocal string_char   = string.char\\nlocal table_concat  = table.concat\\n\\nfor index, byte in ipairs(byteTable) do\\n    byteTable[index] = string_char(byte)\\nend\\n\\nexports['\" .. tostring(basename(assetName)) .. \"'] = table_concat(byteTable, '')\"\
end\
ResourceAsset = Asset:extend({\
  postTransform = function(self, contents)\
    return TEMPLATE_MODULE_LUA(self.assetName, toByteString(contents))\
  end\
})",
['novacbn/gmodproj/api/Schema'] = "local pairs\
pairs = _G.pairs\
local gsub, upper\
do\
  local _obj_0 = string\
  gsub, upper = _obj_0.gsub, _obj_0.upper\
end\
local concat, insert\
do\
  local _obj_0 = table\
  concat, insert = _obj_0.concat, _obj_0.insert\
end\
local livr = require(\"LIVR/Validator\")\
local deepMerge\
deepMerge = dependency(\"novacbn/novautils/table\").deepMerge\
local Object\
Object = dependency(\"novacbn/novautils/utilities/Object\").Object\
local LIVR_ERROR_LOOKUP = {\
  NOT_ARRAY = \"expected array of values\",\
  NOT_STRING = \"expected string value\",\
  NOT_BOOLEAN = \"expected boolean value\",\
  MINIMUM_ITEMS = \"expected a number of minimum array items\",\
  WRONG_FORMAT = \"option did not match pattern\"\
}\
local LIVR_UTILITY_RULES = {\
  is_key_pairs = function(self, keyCheck, valueCheck)\
    local keyValidator = self:is(keyCheck)\
    local valueValidator = self:is(valueCheck)\
    return function(tbl)\
      local err\
      for key, value in pairs(tbl) do\
        local _\
        _, err = keyValidator(key)\
        if err then\
          return nil, err\
        end\
        _, err = valueValidator(value)\
        if err then\
          return nil, err\
        end\
      end\
      return tbl\
    end\
  end,\
  is = function(self, check)\
    if type(check) == \"table\" then\
      local err = \"NOT_\" .. tostring(upper(check[1]))\
      return function(value)\
        local valueType = type(value)\
        for _index_0 = 1, #check do\
          local ruleType = check[_index_0]\
          if valueType == ruleType then\
            return value\
          end\
        end\
        return nil, err\
      end\
    else\
      local err = \"NOT_\" .. tostring(upper(check))\
      return function(value)\
        if type(value) == check then\
          return value\
        end\
        return nil, err\
      end\
    end\
  end,\
  min_items = function(self, amount)\
    return function(value)\
      if not (type(value) == \"table\") then\
        return nil, \"NOT_ARRAY\"\
      end\
      if not (#value >= amount) then\
        return nil, \"MINIMUM_ITEMS\"\
      end\
      return value\
    end\
  end\
}\
livr.register_default_rules(LIVR_UTILITY_RULES)\
local PATTERN_PATH_EXTRACT = \"[^%.]+\"\
local formatOptionsError\
formatOptionsError = function(namespace, errors, stringBuffer)\
  local originatingCall = not stringBuffer and true or false\
  if originatingCall then\
    stringBuffer = { }\
  end\
  for optionName, errorID in pairs(errors) do\
    local _exp_0 = type(errorID)\
    if \"string\" == _exp_0 then\
      insert(stringBuffer, \"bad option '\" .. tostring(optionName) .. \"' to '\" .. tostring(namespace) .. \"' (\" .. tostring(LIVR_ERROR_LOOKUP[errorID] or errorID) .. \")\")\
    else\
      if namespace and #namespace > 0 then\
        formatOptionsError(tostring(namespace) .. \".\" .. tostring(optionName), errorID, stringBuffer)\
      else\
        formatOptionsError(optionName, errorID, stringBuffer)\
      end\
    end\
  end\
  if originatingCall then\
    return concat(stringBuffer, \"\\n\")\
  end\
end\
Schema = Object:extend({\
  default = nil,\
  namespace = nil,\
  options = nil,\
  schema = nil,\
  constructor = function(self, options)\
    if options == nil then\
      options = { }\
    end\
    if self.default then\
      deepMerge(options, self.default)\
    end\
    local validator = livr.new(self.schema)\
    local errors\
    options, errors = validator:validate(options)\
    if errors then\
      error(formatOptionsError(self.namespace, errors))\
    end\
    self.options = options\
  end,\
  get = function(self, dotPath)\
    local value = self.options\
    gsub(dotPath, PATTERN_PATH_EXTRACT, function(pathElement)\
      if not (type(value) == \"table\") then\
        error(\"bad argument #1 to 'get' (key '\" .. tostring(pathElement) .. \"' of '\" .. tostring(dotPath) .. \"' is not a table)\")\
      end\
      value = value[pathElement]\
    end)\
    return value\
  end\
})",
['novacbn/gmodproj/api/Template'] = "local dirname, join\
do\
  local _obj_0 = require(\"path\")\
  dirname, join = _obj_0.dirname, _obj_0.join\
end\
local existsSync, mkdirSync, writeFileSync\
do\
  local _obj_0 = require(\"fs\")\
  existsSync, mkdirSync, writeFileSync = _obj_0.existsSync, _obj_0.mkdirSync, _obj_0.writeFileSync\
end\
local Object\
Object = dependency(\"novacbn/novautils/utilities/Object\").Object\
local json = dependency(\"rxi/json/main\")\
local properties = dependency(\"novacbn/properties/exports\")\
local isDir\
isDir = dependency(\"novacbn/gmodproj/lib/utilities/fs\").isDir\
Template = Object:extend({\
  projectAuthor = nil,\
  projectName = nil,\
  projectPath = nil,\
  constructor = function(self, projectPath, projectAuthor, projectName)\
    self.projectPath, self.projectAuthor, self.projectName = projectPath, projectAuthor, projectName\
  end,\
  createDirectory = function(self, directoryPath)\
    directoryPath = join(self.projectPath, directoryPath)\
    if existsSync(directoryPath) then\
      error(\"bad argument #1 to 'createDirectory' (path already exists)\")\
    end\
    if not (isDir(dirname(directoryPath))) then\
      error(\"bad argument #1 to 'createDirectory' (parent directory does not exist)\")\
    end\
    return mkdirSync(directoryPath)\
  end,\
  write = function(self, filePath, fileContents)\
    filePath = join(self.projectPath, filePath)\
    if not (isDir(dirname(filePath))) then\
      error(\"bad argument #1 to 'write' (parent directory does not exist)\")\
    end\
    return writeFileSync(filePath, fileContents)\
  end,\
  writeProperties = function(self, filePath, sourceTable)\
    return self:write(filePath, properties.encode(sourceTable, {\
      propertiesEncoder = \"moonscript\"\
    }))\
  end,\
  writeJSON = function(self, filePath, sourceTable)\
    return self:write(filePath, json.encode(sourceTable))\
  end,\
  createProject = function(self, ...) end\
})",
['novacbn/gmodproj/commands/bin'] = "local loadfile, print, type\
do\
  local _obj_0 = _G\
  loadfile, print, type = _obj_0.loadfile, _obj_0.print, _obj_0.type\
end\
local process\
process = _G.process\
local readFileSync\
readFileSync = require(\"fs\").readFileSync\
local join\
join = require(\"path\").join\
local moonscript = require(\"moonscript/base\")\
local ENV_ALLOW_UNSAFE_SCRIPTING, PROJECT_PATH, SYSTEM_OS_TYPE, SYSTEM_UNIX_LIKE\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/constants\")\
  ENV_ALLOW_UNSAFE_SCRIPTING, PROJECT_PATH, SYSTEM_OS_TYPE, SYSTEM_UNIX_LIKE = _obj_0.ENV_ALLOW_UNSAFE_SCRIPTING, _obj_0.PROJECT_PATH, _obj_0.SYSTEM_OS_TYPE, _obj_0.SYSTEM_UNIX_LIKE\
end\
local logError, logFatal, logInfo\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/logging\")\
  logError, logFatal, logInfo = _obj_0.logError, _obj_0.logFatal, _obj_0.logInfo\
end\
local ScriptingEnvironment\
ScriptingEnvironment = dependency(\"novacbn/gmodproj/lib/ScriptingEnvironment\").ScriptingEnvironment\
local configureEnvironment, readManifest\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/utilities\")\
  configureEnvironment, readManifest = _obj_0.configureEnvironment, _obj_0.readManifest\
end\
local execFormat, isFile\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/utilities/fs\")\
  execFormat, isFile = _obj_0.execFormat, _obj_0.isFile\
end\
local TEMPLATE_EXECUTION_SUCCESS\
TEMPLATE_EXECUTION_SUCCESS = function(script)\
  return \"Successfully executed '\" .. tostring(script) .. \"'\"\
end\
local TEMPLATE_EXECUTION_ERROR\
TEMPLATE_EXECUTION_ERROR = function(script)\
  return \"Unexpected error occured while executing '\" .. tostring(script) .. \"'\"\
end\
local TEMPLATE_EXECUTION_FAILED\
TEMPLATE_EXECUTION_FAILED = function(script, status)\
  return \"Failed to execute '\" .. tostring(script) .. \"' (\" .. tostring(status) .. \")\"\
end\
local TEMPLATE_EXECUTION_SYNTAX\
TEMPLATE_EXECUTION_SYNTAX = function(script)\
  return \"Script '\" .. tostring(script) .. \"' had a syntax error\"\
end\
local resolveScript\
resolveScript = function(script)\
  local scriptPath = join(PROJECT_PATH.bin, script)\
  if isFile(scriptPath .. \".moon\") then\
    return function()\
      return moonscript.loadfile(scriptPath .. \".moon\")\
    end\
  elseif isFile(scriptPath .. \".lua\") then\
    return function()\
      return loadfile(scriptPath .. \".lua\")\
    end\
  elseif SYSTEM_UNIX_LIKE and isFile(scriptPath .. \".sh\") then\
    return nil, function(...)\
      return execFormat(\"/usr/bin/env\", \"sh\", scriptPath .. \".sh\", ...)\
    end\
  elseif SYSTEM_OS_TYPE == \"Windows\" and isFile(scriptPath .. \".bat\") then\
    return nil, function(...)\
      return execFormat(\"cmd.exe\", scriptPath .. \".bat\", ...)\
    end\
  end\
end\
formatDescription = function(flags)\
  return \"bin <script>\\t\\t\\t\\tExecutes a utility script located in your project's 'bin' directory\"\
end\
executeCommand = function(flags, script, ...)\
  configureEnvironment()\
  local scriptLoader, shellLoader = resolveScript(script)\
  if scriptLoader then\
    local scriptChunk, err = scriptLoader()\
    if err then\
      logError(err)\
      logFatal(TEMPLATE_EXECUTION_SYNTAX(script))\
    end\
    local scriptingEnvironment = ScriptingEnvironment(PROJECT_PATH.home, ENV_ALLOW_UNSAFE_SCRIPTING)\
    local success, status, stdout = scriptingEnvironment:executeChunk(scriptChunk, ...)\
    if success then\
      if status == 0 then\
        return logInfo(stdout)\
      else\
        logError(stdout)\
        return logFatal(TEMPLATE_EXECUTION_FAILED(script, status), {\
          exit = status\
        })\
      end\
    else\
      logError(status)\
      return logFatal(TEMPLATE_EXECUTION_ERROR(script), {\
        exit = -1\
      })\
    end\
  elseif shellLoader then\
    if ENV_ALLOW_UNSAFE_SCRIPTING then\
      local success, status, stdout = shellLoader(...)\
      if success then\
        print(stdout)\
        return logInfo(TEMPLATE_EXECUTION_SUCCESS(script))\
      else\
        logError(stdout)\
        return logFatal(TEMPLATE_EXECUTION_FAILED(script, status), {\
          exit = status\
        })\
      end\
    else\
      return logFatal(\"Unsafe scripting disabled by user!\")\
    end\
  else\
    return logFatal(\"Script '\" .. tostring(script) .. \"' not found!\")\
  end\
end",
['novacbn/gmodproj/commands/build'] = "local lower\
lower = string.lower\
local join\
join = require(\"path\").join\
local Packager\
Packager = dependency(\"novacbn/gmodproj/Packager\").Packager\
local PluginManager\
PluginManager = dependency(\"novacbn/gmodproj/PluginManager\").PluginManager\
local Resolver\
Resolver = dependency(\"novacbn/gmodproj/Resolver\").Resolver\
local PROJECT_PATH\
PROJECT_PATH = dependency(\"novacbn/gmodproj/lib/constants\").PROJECT_PATH\
local ElapsedTimer\
ElapsedTimer = dependency(\"novacbn/gmodproj/lib/ElapsedTimer\").ElapsedTimer\
local logFatal, logInfo\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/logging\")\
  logFatal, logInfo = _obj_0.logFatal, _obj_0.logInfo\
end\
local configureEnvironment, readManifest\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/utilities\")\
  configureEnvironment, readManifest = _obj_0.configureEnvironment, _obj_0.readManifest\
end\
local isDir\
isDir = dependency(\"novacbn/gmodproj/lib/utilities/fs\").isDir\
formatDescription = function(flags)\
  return \"build [mode]\\t\\t\\t\\tBuilds your project into distributable Lua files\\n\\t\\t\\t\\t\\t\\t\\t(DEFAULT) 'development', 'production'\"\
end\
executeCommand = function(flags, mode)\
  if mode == nil then\
    mode = \"development\"\
  end\
  configureEnvironment()\
  local elapsedTimer = ElapsedTimer:new()\
  local options = readManifest()\
  local pluginManager = PluginManager:new(options:get(\"Plugins\"))\
  local resolver = Resolver:new(options:get(\"author\"), options:get(\"name\"), options:get(\"sourceDirectory\"), pluginManager, options:get(\"Resolver\"))\
  local packager = Packager:new(lower(mode) == \"production\", flags, resolver, pluginManager, options:get(\"Packager\"))\
  local buildDirectory = join(PROJECT_PATH.home, options:get(\"buildDirectory\"))\
  if not (isDir(buildDirectory)) then\
    logFatal(\"Build directory does not exist!\")\
  end\
  for entryPoint, targetPackage in pairs(options:get(\"projectBuilds\")) do\
    logInfo(\"Building entry point '\" .. tostring(entryPoint) .. \"'\")\
    packager:writePackage(entryPoint, join(buildDirectory, targetPackage .. \".lua\"))\
  end\
  local elapsedTime = elapsedTimer:getFormattedElapsed()\
  return logInfo(\"Build completed in \" .. tostring(elapsedTime) .. \"!\")\
end",
['novacbn/gmodproj/commands/clean'] = "local unlinkSync\
unlinkSync = require(\"fs\").unlinkSync\
local join\
join = require(\"path\").join\
local PROJECT_PATH\
PROJECT_PATH = dependency(\"novacbn/gmodproj/lib/constants\").PROJECT_PATH\
local logInfo\
logInfo = dependency(\"novacbn/gmodproj/lib/logging\").logInfo\
local collectFiles, isDir\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/utilities/fs\")\
  collectFiles, isDir = _obj_0.collectFiles, _obj_0.isDir\
end\
local cleanDirectory\
cleanDirectory = function(directory)\
  local _list_0 = collectFiles(directory)\
  for _index_0 = 1, #_list_0 do\
    local file = _list_0[_index_0]\
    unlinkSync(join(directory, file))\
  end\
end\
formatDescription = function(flags)\
  return \"clean\\t\\t\\t\\t\\tCleans the build cache of the project\"\
end\
executeCommand = function(flags)\
  if isDir(PROJECT_PATH.cache) and not (flags[\"-nc\"] or flags[\"--no-cache\"]) then\
    cleanDirectory(PROJECT_PATH.cache)\
  end\
  if isDir(PROJECT_PATH.logs) then\
    if not (flags[\"-nl\"] or flags[\"--no-logs\"]) and (flags[\"-ca\"] or flags[\"-cl\"] or flags[\"--clean-all\"] or flags[\"--clean-logs\"]) then\
      cleanDirectory(PROJECT_PATH.logs)\
    end\
  end\
  return logInfo(\"Finished cleaning project files\")\
end",
['novacbn/gmodproj/commands/init'] = "local print, tonumber\
do\
  local _obj_0 = _G\
  print, tonumber = _obj_0.print, _obj_0.tonumber\
end\
local wrap\
wrap = coroutine.wrap\
local match\
match = string.match\
local writeFileSync\
writeFileSync = require(\"fs\").writeFileSync\
local basename, join\
do\
  local _obj_0 = require(\"path\")\
  basename, join = _obj_0.basename, _obj_0.join\
end\
local readLine\
readLine = require(\"readline\").readLine\
local encode\
encode = dependency(\"novacbn/properties/exports\").encode\
local PROJECT_PATH\
PROJECT_PATH = dependency(\"novacbn/gmodproj/lib/constants\").PROJECT_PATH\
local makeSync\
makeSync = dependency(\"novacbn/gmodproj/lib/utilities\").makeSync\
local PATTERN_METADATA_NAME, PATTERN_METADATA_REPOSITORY, PATTERN_METADATA_VERSION\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/schemas/ProjectOptions\")\
  PATTERN_METADATA_NAME, PATTERN_METADATA_REPOSITORY, PATTERN_METADATA_VERSION = _obj_0.PATTERN_METADATA_NAME, _obj_0.PATTERN_METADATA_REPOSITORY, _obj_0.PATTERN_METADATA_VERSION\
end\
local PATTERN_MODULE_NAMESPACE = \"^[%w/%-_]+$\"\
local readLineSync = makeSync(readLine)\
local prompt\
prompt = function(question, default)\
  local err, answer = readLineSync(default and tostring(question) .. \" (\" .. tostring(default) .. \"): \" or tostring(question) .. \": \")\
  if default then\
    return answer == \"\" and default or answer\
  elseif answer == \"\" then\
    return prompt(question)\
  else\
    return answer\
  end\
end\
local validatedPrompt\
validatedPrompt = function(question, check, err, default)\
  local answer\
  while answer == nil do\
    answer = prompt(question, default)\
    if not (check(answer)) then\
      print(\"\\27[31merr:\\27[0m \" .. err)\
      answer = nil\
    end\
  end\
  return answer\
end\
formatDescription = function()\
  return \"init\\t\\t\\t\\t\\tInitializes an already existing project to work with gmodproj\"\
end\
executeCommand = wrap(function(flags)\
  local directoryName = basename(PROJECT_PATH.home)\
  local projectName = validatedPrompt(\"Project name\", function(self)\
    return match(self, PATTERN_METADATA_NAME)\
  end, \"must start with a letter and contain only lowercase alphanumerical characters and dashes\", match(directoryName, PATTERN_METADATA_NAME) and directoryName)\
  local projectAuthor = validatedPrompt(\"Project author\", function(self)\
    return match(self, PATTERN_METADATA_NAME)\
  end, \"must start with a letter and contain only lowercase alphanumerical characters and dashes\")\
  local projectVersion = validatedPrompt(\"Project version\", function(self)\
    return match(self, PATTERN_METADATA_VERSION)\
  end, \"must be formatted as 'NUMBER.NUMBER.NUMBER'\", \"1.0.0\")\
  local projectRepository = validatedPrompt(\"Project repository\", function(self)\
    return match(self, PATTERN_METADATA_REPOSITORY)\
  end, \"must be formatted as 'PROTOCOL://PATH'\", \"unknown://unknown\")\
  local entryPoints = tonumber(validatedPrompt(\"Amount of project entry points\", function(self)\
    return tonumber(self) > 0\
  end, \"must have at least one entry point\", \"1\"))\
  local entryPoint, endPoint\
  local projectBuilds = { }\
  for index = 1, entryPoints do\
    entryPoint = validatedPrompt(\"Entry point #\" .. tostring(index), function(self)\
      return match(self, PATTERN_MODULE_NAMESPACE)\
    end, \"namespace must contain only alphanumeric characters, dashes, slashes, and underscores\", tostring(projectAuthor) .. \"/\" .. tostring(projectName) .. \"/main\")\
    endPoint = prompt(\"End point #\" .. tostring(index), tostring(projectAuthor) .. \".\" .. tostring(projectName) .. \".\" .. tostring(basename(entryPoint)))\
    projectBuilds[entryPoint] = endPoint\
  end\
  local encoded = encode({\
    name = projectName,\
    author = projectAuthor,\
    version = projectVersion,\
    repository = projectRepository,\
    projectBuilds = projectBuilds\
  }, {\
    propertiesEncoder = \"moonscript\"\
  })\
  return writeFileSync(join(PROJECT_PATH.home, \".gmodmanifest\"), encoded)\
end)",
['novacbn/gmodproj/commands/new'] = "local pairs, type\
do\
  local _obj_0 = _G\
  pairs, type = _obj_0.pairs, _obj_0.type\
end\
local match\
match = string.match\
local concat, sort\
do\
  local _obj_0 = table\
  concat, sort = _obj_0.concat, _obj_0.sort\
end\
local existsSync, mkdirSync\
do\
  local _obj_0 = require(\"fs\")\
  existsSync, mkdirSync = _obj_0.existsSync, _obj_0.mkdirSync\
end\
local join\
join = require(\"path\").join\
local hasInherited\
hasInherited = dependency(\"novacbn/novautils/utilities/Object\").hasInherited\
local PluginManager\
PluginManager = dependency(\"novacbn/gmodproj/PluginManager\").PluginManager\
local Template\
Template = dependency(\"novacbn/gmodproj/api/Template\").Template\
local MAP_DEFAULT_PLUGINS, PROJECT_PATH\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/constants\")\
  MAP_DEFAULT_PLUGINS, PROJECT_PATH = _obj_0.MAP_DEFAULT_PLUGINS, _obj_0.PROJECT_PATH\
end\
local logFatal, logInfo\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/logging\")\
  logFatal, logInfo = _obj_0.logFatal, _obj_0.logInfo\
end\
local PATTERN_METADATA_NAME\
PATTERN_METADATA_NAME = dependency(\"novacbn/gmodproj/schemas/ProjectOptions\").PATTERN_METADATA_NAME\
local TemplateRegister\
TemplateRegister = function()\
  return {\
    registeredTemplates = { },\
    registerTemplate = function(self, name, template)\
      if not (type(name) == \"string\") then\
        error(\"bad argument #1 to 'registerTemplate' (expected string value)\")\
      end\
      if self.registeredTemplates[name] then\
        error(\"bad argument #1 to 'registerTemplate' (template name already registered)\")\
      end\
      if not (type(template) == \"table\" and hasInherited(Template, template)) then\
        error(\"bad argument #2 to 'registerTemplate' (expected Template value)\")\
      end\
      self.registeredTemplates[name] = template\
    end\
  }\
end\
formatDescription = function(flags)\
  local templateRegister = TemplateRegister()\
  local pluginManager = PluginManager:new(MAP_DEFAULT_PLUGINS)\
  pluginManager:dispatchEvent(\"registerTemplates\", templateRegister)\
  local templateNames\
  do\
    local _accum_0 = { }\
    local _len_0 = 1\
    for templateName, template in pairs(templateRegister.registeredTemplates) do\
      _accum_0[_len_0] = \"'\" .. templateName .. \"'\"\
      _len_0 = _len_0 + 1\
    end\
    templateNames = _accum_0\
  end\
  sort(templateNames)\
  templateNames = concat(templateNames, \", \")\
  return \"new <template> <author> <name>\\t\\tCreates a new directory for your project via a template\\n\\t\\t\\t\\t\\t\\t\\t\" .. tostring(templateNames)\
end\
executeCommand = function(flags, templateName, author, name, ...)\
  local templateRegister = TemplateRegister()\
  local pluginManager = PluginManager:new(MAP_DEFAULT_PLUGINS)\
  pluginManager:dispatchEvent(\"registerTemplates\", templateRegister)\
  local template = templateRegister.registeredTemplates[templateName]\
  if not (template) then\
    logFatal(\"Invalid template '\" .. tostring(templateName) .. \"'!\")\
  end\
  if not (author and #author > 0 and match(author, PATTERN_METADATA_NAME)) then\
    logFatal(\"Project author \" .. tostring(author) .. \" is invalid, must be lowercase alphanumeric and dashes only!\")\
  end\
  if not (name and #name > 0 and match(name, PATTERN_METADATA_NAME)) then\
    logFatal(\"Project name \" .. tostring(name) .. \" is invalid, must be lowercase alphanumeric and dashes only!\")\
  end\
  local projectPath = join(PROJECT_PATH.home, name)\
  if existsSync(projectPath) then\
    logFatal(\"Path '\" .. tostring(name) .. \"' is already exists!\")\
  end\
  mkdirSync(projectPath)\
  local loadedTemplate = template:new(projectPath, author, name)\
  loadedTemplate:createProject(...)\
  return logInfo(\"Successfully generated project at: \" .. tostring(projectPath))\
end",
['novacbn/gmodproj/commands/version'] = "local print\
print = _G.print\
local APPLICATION_CORE_VERSION\
APPLICATION_CORE_VERSION = dependency(\"novacbn/gmodproj/lib/constants\").APPLICATION_CORE_VERSION\
TEXT_COMMAND_VERSION = tostring(APPLICATION_CORE_VERSION[1]) .. \".\" .. tostring(APPLICATION_CORE_VERSION[2]) .. \".\" .. tostring(APPLICATION_CORE_VERSION[3]) .. \" Pre-alpha\"\
formatDescription = function(flags)\
  return \"version\\t\\t\\t\\t\\tDisplays the version text of application\"\
end\
executeCommand = function(flags)\
  return print(TEXT_COMMAND_VERSION)\
end",
['novacbn/gmodproj/commands/watch'] = "local unpack\
unpack = _G.unpack\
local pack\
pack = dependency(\"novacbn/novautils/utilities\").pack\
local logInfo\
logInfo = dependency(\"novacbn/gmodproj/lib/logging\").logInfo\
local ResolverOptions\
ResolverOptions = dependency(\"novacbn/gmodproj/schemas/ResolverOptions\").ResolverOptions\
local readManifest\
readManifest = dependency(\"novacbn/gmodproj/lib/utilities\").readManifest\
local watchPath\
watchPath = dependency(\"novacbn/gmodproj/lib/utilities/fs\").watchPath\
local bin = dependency(\"novacbn/gmodproj/commands/bin\")\
local build = dependency(\"novacbn/gmodproj/commands/build\")\
local makeBinding\
makeBinding = function(flags, script, ...)\
  if script then\
    local args = pack(...)\
    return function()\
      return bin.executeCommand(flags, script, unpack(args))\
    end\
  end\
  return function()\
    return build.executeCommand(flags, \"development\")\
  end\
end\
formatDescription = function(flags)\
  return \"watch [script]\\t\\t\\t\\tWatches the source directory for changes and rebuilds in development\\n\\t\\t\\t\\t\\t\\t\\tExecutes a script instead, if specified\"\
end\
executeCommand = function(flags, script, ...)\
  local options = readManifest()\
  local modificationBind = makeBinding(flags, script, ...)\
  watchPath(options:get(\"sourceDirectory\"), modificationBind)\
  if flags[\"-ws\"] or flags[\"--watch-search\"] then\
    local resolverOptions = ResolverOptions:new(options:get(\"Resolver\"))\
    local _list_0 = resolverOptions:get(\"searchPaths\")\
    for _index_0 = 1, #_list_0 do\
      local path = _list_0[_index_0]\
      watchPath(path, modificationBind)\
    end\
  end\
  return logInfo(\"Watching project directories for modification...\")\
end",
['novacbn/gmodproj/lib/ElapsedTimer'] = "local format\
format = string.format\
local gettime\
gettime = require(\"gettime\").gettime\
local Object\
Object = dependency(\"novacbn/novautils/utilities/Object\").Object\
local getSeconds\
getSeconds = function()\
  return gettime() / 1000\
end\
ElapsedTimer = Object:extend({\
  startTime = 0,\
  constructor = function(self)\
    self.startTime = getSeconds()\
  end,\
  getElapsed = function(self)\
    return getSeconds() - self.startTime\
  end,\
  getFormattedElapsed = function(self)\
    return format(\"%.4fs\", getSeconds() - self.startTime)\
  end\
})",
['novacbn/gmodproj/lib/ScriptingEnvironment'] = "local assert, error, ipairs, loadfile, pcall, pairs, setfenv\
do\
  local _obj_0 = _G\
  assert, error, ipairs, loadfile, pcall, pairs, setfenv = _obj_0.assert, _obj_0.error, _obj_0.ipairs, _obj_0.loadfile, _obj_0.pcall, _obj_0.pairs, _obj_0.setfenv\
end\
local match\
match = string.match\
local insert\
insert = table.insert\
local existsSync, mkdirSync, readFileSync, writeFileSync, unlinkSync\
do\
  local _obj_0 = require(\"fs\")\
  existsSync, mkdirSync, readFileSync, writeFileSync, unlinkSync = _obj_0.existsSync, _obj_0.mkdirSync, _obj_0.readFileSync, _obj_0.writeFileSync, _obj_0.unlinkSync\
end\
local decode, encode\
do\
  local _obj_0 = require(\"json\")\
  decode, encode = _obj_0.decode, _obj_0.encode\
end\
local isAbsolute, join\
do\
  local _obj_0 = require(\"path\")\
  isAbsolute, join = _obj_0.isAbsolute, _obj_0.join\
end\
local moonscript = require(\"moonscript\")\
local merge\
merge = dependency(\"novacbn/novautils/table\").merge\
local PROJECT_PATH, SYSTEM_OS_ARCH, SYSTEM_OS_TYPE, SYSTEM_UNIX_LIKE\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/constants\")\
  PROJECT_PATH, SYSTEM_OS_ARCH, SYSTEM_OS_TYPE, SYSTEM_UNIX_LIKE = _obj_0.PROJECT_PATH, _obj_0.SYSTEM_OS_ARCH, _obj_0.SYSTEM_OS_TYPE, _obj_0.SYSTEM_UNIX_LIKE\
end\
local fromString, toString\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/datafile\")\
  fromString, toString = _obj_0.fromString, _obj_0.toString\
end\
local logError\
logError = dependency(\"novacbn/gmodproj/lib/logging\").logError\
local exec, execFormat, isDir, isFile\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/utilities/fs\")\
  exec, execFormat, isDir, isFile = _obj_0.exec, _obj_0.execFormat, _obj_0.isDir, _obj_0.isFile\
end\
local assertx = dependency(\"novacbn/gmodproj/lib/utilities/assert\")\
local ChunkEnvironment\
ChunkEnvironment = function(environmentRoot, allowUnsafe)\
  local getEnvironmentPath\
  getEnvironmentPath = function(path)\
    if not (isAbsolute(path) or match(path, \"%.%.\")) then\
      return join(environmentRoot, path)\
    end\
    if allowUnsafe then\
      return path\
    end\
  end\
  local moduleCache = { }\
  local orderedTests = { }\
  local unitTests = { }\
  local environmentTable\
  environmentTable = {\
    ENV_ALLOW_UNSAFE_SCRIPTING = allowUnsafe,\
    PROJECT_PATH = PROJECT_PATH,\
    SYSTEM_OS_ARCH = SYSTEM_OS_ARCH,\
    SYSTEM_OS_TYPE = SYSTEM_OS_TYPE,\
    SYSTEM_UNIX_LIKE = SYSTEM_UNIX_LIKE,\
    assert = assert,\
    define = function(name, callback)\
      if not (type(name) == \"string\") then\
        error(\"bad argument #1 to 'define' (expected string)\")\
      end\
      if unitTests[name] then\
        error(\"bad argument #1 to 'define' (test already defined)\")\
      end\
      if not (type(callback) == \"function\") then\
        error(\"bad argument #2 to 'define' (expected function)\")\
      end\
      unitTests[name] = true\
      return insert(orderedTests, {\
        name = name,\
        callback = callback\
      })\
    end,\
    error = error,\
    exists = function(path)\
      path = assertx.argument(getEnvironmentPath(path), 1, \"exists\", \"expected relative path, got '\" .. tostring(path) .. \"'\")\
      local hasPath = existsSync(path)\
      return hasPath\
    end,\
    isDir = function(path)\
      path = assertx.argument(getEnvironmentPath(path), 1, \"isDir\", \"expected relative path, got '\" .. tostring(path) .. \"'\")\
      return isDir(path)\
    end,\
    isFile = function(path)\
      path = assertx.argument(getEnvironmentPath(path), 1, \"isFile\", \"expected relative path, got '\" .. tostring(path) .. \"'\")\
      return isFile(path)\
    end,\
    ipairs = ipairs,\
    mkdir = function(path)\
      path = assertx.argument(getEnvironmentPath(path), 1, \"mkdir\", \"expected relative path, got '\" .. tostring(path) .. \"'\")\
      local hasPath = existsSync(path)\
      assertx.argument(not hasPath, 1, \"mkdir\", \"path '\" .. tostring(path) .. \"' already exists\")\
      mkdirSync(path)\
      return nil\
    end,\
    pcall = pcall,\
    pairs = pairs,\
    print = print,\
    read = function(path)\
      path = assertx.argument(getEnvironmentPath(path), 1, \"read\", \"expected relative path, got '\" .. tostring(path) .. \"'\")\
      assertx.argument(isFile(path), 1, \"read\", \"file '\" .. tostring(path) .. \"' does not exist\")\
      return readFileSync(path)\
    end,\
    readDataFile = function(path)\
      return fromString(environmentTable.read(path))\
    end,\
    readJSON = function(path)\
      return decode(environmentTable.read(path))\
    end,\
    remove = function(path)\
      path = assertx.argument(getEnvironmentPath(path), 1, \"remove\", \"expected relative path, got '\" .. tostring(path) .. \"'\")\
      if isDir(path) then\
        rmdir(path)\
      else\
        unlinkSync(path)\
      end\
      return nil\
    end,\
    test = function()\
      local success, err\
      for _index_0 = 1, #orderedTests do\
        local unitTest = orderedTests[_index_0]\
        success, err = pcall(unitTest.callback)\
        unitTest.success = success\
        if not (success) then\
          logError(\"Failed unit test '\" .. tostring(unitTest.name) .. \"'\\n\" .. tostring(err))\
          print(\"\")\
        end\
      end\
      local failed = 0\
      local successful = 0\
      local total = #orderedTests\
      for _index_0 = 1, #orderedTests do\
        local unitTest = orderedTests[_index_0]\
        if unitTest.success then\
          successful = successful + 1\
        else\
          failed = failed + 1\
        end\
      end\
      if failed > 0 then\
        return 1, tostring(successful) .. \" successes, \" .. tostring(failed) .. \" failed, out of \" .. tostring(total) .. \" test(s)\"\
      end\
      return 0, \"All \" .. tostring(total) .. \" test(s) passed\"\
    end,\
    tostring = tostring,\
    write = function(path, contents)\
      path = assertx.argument(getEnvironmentPath(path), 1, \"write\", \"expected relative path, got '\" .. tostring(path) .. \"'\")\
      writeFileSync(path, contents)\
      return nil\
    end,\
    writeDataFile = function(path, tableData)\
      return environmentTable.write(path, toString(tableData))\
    end,\
    writeJSON = function(path, tableData)\
      return environmentTable.write(path, encode(tableData, {\
        indent = true\
      }))\
    end\
  }\
  if allowUnsafe then\
    merge(environmentTable, {\
      dependency = dependency,\
      require = function(name)\
        local path = join(PROJECT_PATH.home, name)\
        local loader = nil\
        if isFile(path .. \".lua\") then\
          path = path .. \".lua\"\
          loader = loadfile\
        elseif isFile(path .. \".moon\") then\
          path = path .. \".moon\"\
          loader = moonscript.loadfile\
        end\
        if loader then\
          if not (moduleCache[name]) then\
            local chunk = loader(path)\
            setfenv(chunk, environmentTable)\
            moduleCache[name] = chunk()\
          end\
          return moduleCache[name]\
        end\
        local success, exports = pcall(dependency, name)\
        if success then\
          return exports\
        end\
        return require(name)\
      end,\
      exec = exec,\
      execFormat = execFormat\
    })\
  end\
  environmentTable._G = environmentTable\
  return setmetatable({ }, {\
    __index = environmentTable\
  })\
end\
do\
  local _class_0\
  local _base_0 = {\
    allowUnsafe = nil,\
    environmentRoot = nil,\
    executeChunk = function(self, scriptChunk, ...)\
      local environmentSandbox = ChunkEnvironment(self.environmentRoot, self.allowUnsafe)\
      return pcall(setfenv(scriptChunk, environmentSandbox), ...)\
    end\
  }\
  _base_0.__index = _base_0\
  _class_0 = setmetatable({\
    __init = function(self, environmentRoot, allowUnsafe)\
      self.allowUnsafe = allowUnsafe\
      self.environmentRoot = environmentRoot\
    end,\
    __base = _base_0,\
    __name = \"ScriptingEnvironment\"\
  }, {\
    __index = _base_0,\
    __call = function(cls, ...)\
      local _self_0 = setmetatable({}, _base_0)\
      cls.__init(_self_0, ...)\
      return _self_0\
    end\
  })\
  _base_0.__class = _class_0\
  ScriptingEnvironment = _class_0\
end",
['novacbn/gmodproj/lib/constants'] = "local getenv\
getenv = os.getenv\
local arch, os\
do\
  local _obj_0 = jit\
  arch, os = _obj_0.arch, _obj_0.os\
end\
local join\
join = require(\"path\").join\
local isAffirmative\
isAffirmative = dependency(\"novacbn/gmodproj/lib/utilities/string\").isAffirmative\
local userHome\
local _exp_0 = os\
if \"Windows\" == _exp_0 then\
  userHome = getenv(\"APPDATA\")\
elseif \"Linux\" == _exp_0 then\
  userHome = getenv(\"HOME\")\
end\
APPLICATION_CORE_VERSION = {\
  0,\
  4,\
  3\
}\
ENV_ALLOW_UNSAFE_SCRIPTING = isAffirmative(getenv(\"GMODPROJ_ALLOW_UNSAFE_SCRIPTING\") or \"y\")\
MAP_DEFAULT_PLUGINS = {\
  [\"gmodproj-plugin-builtin\"] = { }\
}\
SYSTEM_OS_ARCH = arch\
SYSTEM_OS_TYPE = os\
SYSTEM_UNIX_LIKE = os == \"Linux\" or os == \"OSX\"\
do\
  local _with_0 = { }\
  _with_0.home = process.cwd()\
  _with_0.data = join(_with_0.home, \".gmodproj\")\
  _with_0.bin = join(_with_0.home, \"bin\")\
  _with_0.manifest = join(_with_0.home, \".gmodmanifest\")\
  _with_0.packages = join(_with_0.home, \".gmodpackages\")\
  _with_0.cache = join(_with_0.data, \"cache\")\
  _with_0.logs = join(_with_0.data, \"logs\")\
  _with_0.plugins = join(_with_0.data, \"plugins\")\
  PROJECT_PATH = _with_0\
end\
do\
  local _with_0 = { }\
  _with_0.data = join(userHome, \".gmodproj\")\
  _with_0.applications = join(_with_0.home, \"applications\")\
  _with_0.cache = join(_with_0.home, \"cache\")\
  _with_0.plugins = join(_with_0.home, \"plugins\")\
  USER_PATH = _with_0\
end",
['novacbn/gmodproj/lib/datafile'] = "local getmetatable, ipairs, pairs, setfenv, setmetatable, tostring\
do\
  local _obj_0 = _G\
  getmetatable, ipairs, pairs, setfenv, setmetatable, tostring = _obj_0.getmetatable, _obj_0.ipairs, _obj_0.pairs, _obj_0.setfenv, _obj_0.setmetatable, _obj_0.tostring\
end\
local gsub, match, rep\
do\
  local _obj_0 = string\
  gsub, match, rep = _obj_0.gsub, _obj_0.match, _obj_0.rep\
end\
local concat, insert\
do\
  local _obj_0 = table\
  concat, insert = _obj_0.concat, _obj_0.insert\
end\
local loadstring\
loadstring = require(\"moonscript/base\").loadstring\
local isNumericTable, isSequentialTable\
do\
  local _obj_0 = dependency(\"novacbn/novautils/table\")\
  isNumericTable, isSequentialTable = _obj_0.isNumericTable, _obj_0.isSequentialTable\
end\
local deprecate\
deprecate = dependency(\"novacbn/gmodproj/lib/utilities/deprecate\").deprecate\
local makeStringEscape\
makeStringEscape = dependency(\"novacbn/gmodproj/lib/utilities/string\").makeStringEscape\
local escapeString = makeStringEscape({\
  {\
    \"\\\\\",\
    \"\\\\\\\\\"\
  },\
  {\
    \"'\",\
    \"\\\\'\"\
  },\
  {\
    \"\\t\",\
    \"\\\\t\"\
  },\
  {\
    \"\\n\",\
    \"\\\\n\"\
  },\
  {\
    \"\\r\",\
    \"\\\\r\"\
  }\
})\
local encodeKeyString\
encodeKeyString = function(stringKey)\
  stringKey = escapeString(stringKey)\
  if match(stringKey, \"^%a\") then\
    return stringKey, false\
  end\
  return \"'\" .. tostring(stringKey) .. \"'\", true\
end\
local encodeValueString\
encodeValueString = function(stringValue)\
  stringValue = escapeString(stringValue)\
  return \"'\" .. tostring(stringValue) .. \"'\"\
end\
local encodeKey, encodeValue\
local encodeValueTable\
encodeValueTable = function(tableValue, stackLevel)\
  if stackLevel == nil then\
    stackLevel = 0\
  end\
  local stringStack = { }\
  local stackTabs = rep(\"\\t\", stackLevel)\
  if stackLevel > 0 then\
    insert(stringStack, \"{\")\
  end\
  if isNumericTable(tableValue) and isSequentialTable(tableValue) then\
    local encodedValue\
    local tableLength = #tableValue\
    for index, value in ipairs(tableValue) do\
      encodedValue = encodeValue(value, stackLevel + 1)\
      if index < tableLength then\
        insert(stringStack, stackTabs .. encodedValue .. \",\")\
      else\
        insert(stringStack, stackTabs .. encodedValue)\
      end\
    end\
  else\
    local keyType, encodedKey, keyEncapsulate, valueType, encodedValue\
    for key, value in pairs(tableValue) do\
      encodedKey, keyEncapsulate = encodeKey(key)\
      encodedValue = encodeValue(value, stackLevel + 1)\
      if keyEncapsulate then\
        insert(stringStack, stackTabs .. \"[\" .. tostring(encodedKey) .. \"]: \" .. tostring(encodedValue))\
      else\
        insert(stringStack, stackTabs .. tostring(encodedKey) .. \" \" .. tostring(encodedValue))\
      end\
    end\
  end\
  if stackLevel > 0 then\
    insert(stringStack, rep(\"\\t\", stackLevel - 1) .. \"}\")\
  end\
  return concat(stringStack, \"\\n\")\
end\
local typeEncodeMap = {\
  key = {\
    boolean = function(self)\
      return self, true\
    end,\
    number = function(self)\
      return self, true\
    end,\
    string = encodeKeyString\
  },\
  value = {\
    boolean = tostring,\
    number = function(self)\
      return self\
    end,\
    string = encodeValueString,\
    table = encodeValueTable\
  }\
}\
encodeKey = function(key, ...)\
  local keyEncoder = typeEncodeMap.key[type(key)]\
  if not (keyEncoder) then\
    error(\"cannot encode key '\" .. tostring(key) .. \"', unsupported type\")\
  end\
  return keyEncoder(key, ...)\
end\
encodeValue = function(value, ...)\
  local valueEncoder = typeEncodeMap.value[type(value)]\
  if not (valueEncoder) then\
    error(\"cannot encode value '\" .. tostring(value) .. \"', unsupported type\")\
  end\
  return valueEncoder(value, ...)\
end\
local KeyPair\
KeyPair = function(name, levelToggle)\
  return setmetatable({\
    name = name\
  }, {\
    __call = function(self, value)\
      if type(value) == \"table\" then\
        local removedKeys = { }\
        for key, subValue in pairs(value) do\
          if type(subValue) == \"table\" and getmetatable(subValue) then\
            if subValue.value ~= nil then\
              value[subValue.name] = subValue.value\
            end\
            insert(removedKeys, key)\
          end\
        end\
        for _index_0 = 1, #removedKeys do\
          local key = removedKeys[_index_0]\
          value[key] = nil\
        end\
      end\
      self.value = value\
      if levelToggle then\
        levelToggle(name, value)\
      end\
      return self\
    end\
  })\
end\
local ChunkEnvironment\
ChunkEnvironment = function(dataExports)\
  if dataExports == nil then\
    dataExports = { }\
  end\
  local topLevel = true\
  local levelToggle\
  levelToggle = function(key, value)\
    dataExports[key] = value\
    topLevel = true\
  end\
  return setmetatable({ }, {\
    __index = function(self, key)\
      local keyPair = KeyPair(key, topLevel and levelToggle)\
      topLevel = false\
      return keyPair\
    end\
  }), dataExports\
end\
loadChunk = function(sourceChunk)\
  deprecate(\"novacbn/gmodproj/lib/datafile::loadChunk\", \"novacbn/gmodproj/lib/datafile::loadChunk is deprecated, see 0.4.0 changelog\")\
  local chunkEnvironment, dataExports = ChunkEnvironment()\
  setfenv(sourceChunk, chunkEnvironment)()\
  return dataExports\
end\
fromString = function(sourceString, chunkName)\
  if chunkName == nil then\
    chunkName = \"DataFile Chunk\"\
  end\
  deprecate(\"novacbn/gmodproj/lib/datafile::fromString\", \"novacbn/gmodproj/lib/datafile::fromString is deprecated, see 0.4.0 changelog\")\
  local sourceChunk = loadstring(sourceString, chunkName)\
  return loadChunk(sourceChunk)\
end\
toString = function(sourceTable)\
  deprecate(\"novacbn/gmodproj/lib/datafile::toString\", \"novacbn/gmodproj/lib/datafile::toString is deprecated, see 0.4.0 changelog\")\
  if not (type(sourceTable) == \"table\") then\
    error(\"only table values can be serialized\")\
  end\
  return typeEncodeMap.value.table(sourceTable, 0)\
end",
['novacbn/gmodproj/lib/logging'] = "local open\
open = io.open\
local date\
date = os.date\
local format\
format = string.format\
local join\
join = require(\"path\").join\
local merge\
merge = dependency(\"novacbn/novautils/table\").merge\
local WriteBuffer\
WriteBuffer = dependency(\"novacbn/novautils/io/WriteBuffer\").WriteBuffer\
local PROJECT_PATH\
PROJECT_PATH = dependency(\"novacbn/gmodproj/lib/constants\").PROJECT_PATH\
local BUFFER_MEMORY_LOG = WriteBuffer:new()\
local HANDLE_FILE_LOG = nil\
local PATH_FILE_LOG = join(PROJECT_PATH.logs, date(\"%Y%m%d-%H%M%S.log\"))\
local TOGGLE_CONSOLE_LOGGING = true\
local TOGGLE_FILE_LOGGING = true\
local makeLogger\
makeLogger = function(tag, color, defaultOptions)\
  if defaultOptions == nil then\
    defaultOptions = { }\
  end\
  return function(message, options)\
    if options == nil then\
      options = { }\
    end\
    options = merge(options, defaultOptions)\
    if TOGGLE_CONSOLE_LOGGING and options.console then\
      print(format(\"%s[%-6s%s]%s %s\", color, tag, date(\"%H:%M:%S\"), \"\\27[0m\", message))\
    end\
    if TOGGLE_FILE_LOGGING and options.file then\
      local logMessage = format(\"[%-6s%s] %s\\n\", tag, date(), message)\
      if BUFFER_MEMORY_LOG then\
        BUFFER_MEMORY_LOG:writeString(logMessage)\
      else\
        HANDLE_FILE_LOG:write(logMessage)\
      end\
    end\
    if options.exit then\
      return process:exit(options.exit)\
    end\
  end\
end\
enableFileLogging = function()\
  if BUFFER_MEMORY_LOG and TOGGLE_FILE_LOGGING then\
    HANDLE_FILE_LOG = open(PATH_FILE_LOG, \"wb\")\
    HANDLE_FILE_LOG:write(BUFFER_MEMORY_LOG:toString())\
    BUFFER_MEMORY_LOG = nil\
  end\
end\
toggleConsoleLogging = function(toggle)\
  TOGGLE_CONSOLE_LOGGING = toggle and true or false\
end\
toggleFileLogging = function(toggle)\
  TOGGLE_FILE_LOGGING = toggle and true or false\
end\
logInfo = makeLogger(\"INFO\", \"\\27[32m\", {\
  console = true,\
  file = true\
})\
logWarn = makeLogger(\"WARN\", \"\\27[33m\", {\
  console = true,\
  file = true\
})\
logError = makeLogger(\"ERROR\", \"\\27[31m\", {\
  console = true,\
  file = true\
})\
logFatal = makeLogger(\"FATAL\", \"\\27[35m\", {\
  console = true,\
  exit = 1,\
  file = true\
})",
['novacbn/gmodproj/lib/utilities'] = "local pcall\
pcall = _G.pcall\
local resume, running, yield\
do\
  local _obj_0 = coroutine\
  resume, running, yield = _obj_0.resume, _obj_0.running, _obj_0.yield\
end\
local readFileSync, mkdirSync\
do\
  local _obj_0 = require(\"fs\")\
  readFileSync, mkdirSync = _obj_0.readFileSync, _obj_0.mkdirSync\
end\
local decode\
decode = dependency(\"novacbn/properties/exports\").decode\
local PROJECT_PATH\
PROJECT_PATH = dependency(\"novacbn/gmodproj/lib/constants\").PROJECT_PATH\
local enableFileLogging, logError, logFatal\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/logging\")\
  enableFileLogging, logError, logFatal = _obj_0.enableFileLogging, _obj_0.logError, _obj_0.logFatal\
end\
local isDir, isFile\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/utilities/fs\")\
  isDir, isFile = _obj_0.isDir, _obj_0.isFile\
end\
local ProjectOptions\
ProjectOptions = dependency(\"novacbn/gmodproj/schemas/ProjectOptions\").ProjectOptions\
configureEnvironment = function()\
  if not (isDir(PROJECT_PATH.data)) then\
    mkdirSync(PROJECT_PATH.data)\
  end\
  if not (isDir(PROJECT_PATH.cache)) then\
    mkdirSync(PROJECT_PATH.cache)\
  end\
  if not (isDir(PROJECT_PATH.plugins)) then\
    mkdirSync(PROJECT_PATH.plugins)\
  end\
  if not (isDir(PROJECT_PATH.logs)) then\
    mkdirSync(PROJECT_PATH.logs)\
  end\
  return enableFileLogging()\
end\
makeSync = function(func)\
  return function(...)\
    local thread = running()\
    func(..., function(...)\
      return resume(thread, ...)\
    end)\
    return yield()\
  end\
end\
readManifest = function()\
  if isDir(PROJECT_PATH.manifest) then\
    logFatal(\".gmodmanifest is a directory!\")\
  end\
  local options = { }\
  if isFile(PROJECT_PATH.manifest) then\
    options = decode(readFileSync(PROJECT_PATH.manifest), {\
      propertiesEncoder = \"moonscript\"\
    })\
  end\
  local success, err = pcall(ProjectOptions.new, ProjectOptions, options)\
  if not (success) then\
    logError(err)\
    logFatal(\"Failed to validate .gmodmanifest!\")\
  end\
  return err\
end",
['novacbn/gmodproj/lib/utilities/assert'] = "local error\
error = _G.error\
argument = function(conditional, argument, name, tag, stackLevel)\
  if stackLevel == nil then\
    stackLevel = 2\
  end\
  if conditional then\
    return conditional\
  end\
  return error(\"bad argument #\" .. tostring(argument) .. \" to '\" .. tostring(name) .. \"' (\" .. tostring(tag) .. \")\", stackLevel)\
end",
['novacbn/gmodproj/lib/utilities/deprecate'] = "local print\
print = _G.print\
local DEPRECATION_FEATURE_KEYS = { }\
deprecate = function(featureKey, text)\
  if not (DEPRECATION_FEATURE_KEYS[featureKey]) then\
    print(text)\
    DEPRECATION_FEATURE_KEYS[featureKey] = true\
  end\
end",
['novacbn/gmodproj/lib/utilities/fs'] = "local ipairs, type\
do\
  local _obj_0 = _G\
  ipairs, type = _obj_0.ipairs, _obj_0.type\
end\
local popen\
popen = io.popen\
local match\
match = string.match\
local concat, insert\
do\
  local _obj_0 = table\
  concat, insert = _obj_0.concat, _obj_0.insert\
end\
local readdirSync, statSync\
do\
  local _obj_0 = require(\"fs\")\
  readdirSync, statSync = _obj_0.readdirSync, _obj_0.statSync\
end\
local join\
join = require(\"path\").join\
local nextTick\
nextTick = process.nextTick\
local PATHS_TO_WATCH = { }\
local scanTimestamps\
scanTimestamps = function(directory)\
  local lastModified = -1\
  local files = collectFiles(directory)\
  local modificationTime\
  for _index_0 = 1, #files do\
    local file = files[_index_0]\
    modificationTime = statSync(join(directory, file)).mtime.sec\
    if lastModified < modificationTime then\
      lastModified = modificationTime\
    end\
  end\
  return lastModified\
end\
local watchLoop\
watchLoop = function()\
  do\
    local _accum_0 = { }\
    local _len_0 = 1\
    for _index_0 = 1, #PATHS_TO_WATCH do\
      local entry = PATHS_TO_WATCH[_index_0]\
      if isDir(entry.path) or isFile(entry.path) then\
        _accum_0[_len_0] = entry\
        _len_0 = _len_0 + 1\
      end\
    end\
    PATHS_TO_WATCH = _accum_0\
  end\
  local lastModified\
  for _index_0 = 1, #PATHS_TO_WATCH do\
    local entry = PATHS_TO_WATCH[_index_0]\
    if isDir(entry.path) then\
      lastModified = scanTimestamps(entry.path)\
    else\
      lastModified = statSync(entry.path).mtime.sec\
    end\
    if entry.lastModified == -1 then\
      entry.lastModified = lastModified\
    elseif entry.lastModified ~= lastModified then\
      entry.callback(entry.path)\
      entry.lastModified = lastModified\
    end\
  end\
  if #PATHS_TO_WATCH > 0 then\
    return nextTick(watchLoop)\
  end\
end\
collectFiles = function(path, paths, base)\
  if paths == nil then\
    paths = { }\
  end\
  if base == nil then\
    base = \"\"\
  end\
  if not (type(path) == \"string\") then\
    error(\"bad argument #1 to 'collectFiles' (expected string)\")\
  end\
  if not (isDir(path) or isFile(path)) then\
    error(\"bad argument #1 to 'collectFiles' (invalid path)\")\
  end\
  if not (type(paths) == \"table\") then\
    error(\"bad argument #2 to 'collectFiles' (expected table)\")\
  end\
  if not (type(base) == \"string\") then\
    error(\"bad argument #3 to 'collectFiles' (expected string)\")\
  end\
  local joined\
  local _list_0 = readdirSync(path)\
  for _index_0 = 1, #_list_0 do\
    local name = _list_0[_index_0]\
    joined = join(path, name)\
    if isFile(joined) then\
      insert(paths, join(base, name))\
    else\
      collectFiles(joined, paths, join(base, name))\
    end\
  end\
  return paths\
end\
formatCommand = function(...)\
  local commandArguments = {\
    ...\
  }\
  for index, commandArgument in ipairs(commandArguments) do\
    if match(commandArgument, \"%s\") then\
      commandArguments[index] = \"'\" .. tostring(commandArgument) .. \"'\"\
    end\
  end\
  return concat(commandArguments, \" \")\
end\
exec = function(command)\
  local handle = popen(command, \"r\")\
  local stdout = handle:read(\"*a\")\
  local success, _, status = handle:close()\
  return success, status, stdout\
end\
execFormat = function(...)\
  return exec(formatCommand(...))\
end\
isDir = function(path)\
  local fileStats = statSync(path)\
  return fileStats and fileStats.type == \"directory\" or false\
end\
isFile = function(path)\
  local fileStats = statSync(path)\
  return fileStats and fileStats.type == \"file\" or false\
end\
watchPath = function(path, callback)\
  if not (type(path) == \"string\") then\
    error(\"bad argument #1 to 'watchPath' (expected string)\")\
  end\
  if not (isDir(path) or isFile(path)) then\
    error(\"bad argument #1 to 'watchPath' (invalid path)\")\
  end\
  if not (type(callback) == \"function\") then\
    error(\"bad argument #2 to 'watchPath' (expected function)\")\
  end\
  insert(PATHS_TO_WATCH, {\
    callback = callback,\
    path = path,\
    lastModified = -1\
  })\
  if #PATHS_TO_WATCH == 1 then\
    return nextTick(watchLoop)\
  end\
end",
['novacbn/gmodproj/lib/utilities/openssl'] = "local base64, digest\
do\
  local _obj_0 = require(\"openssl\")\
  base64, digest = _obj_0.base64, _obj_0.digest\
end\
digest = digest.digest\
decodeB64 = function(str)\
  return base64(str, false)\
end\
encodeB64 = function(str)\
  return base64(str, true)\
end\
hashMD5 = function(str)\
  return digest(\"MD5\", str)\
end\
hashSHA1 = function(str)\
  return digest(\"SHA1\", str)\
end\
hashSHA256 = function(str)\
  return digest(\"SHA256\", str)\
end",
['novacbn/gmodproj/lib/utilities/string'] = "local tostring\
tostring = _G.tostring\
local byte, gmatch, gsub, lower\
do\
  local _obj_0 = string\
  byte, gmatch, gsub, lower = _obj_0.byte, _obj_0.gmatch, _obj_0.gsub, _obj_0.lower\
end\
local concat\
concat = table.concat\
local makeLookupMap\
makeLookupMap = dependency(\"novacbn/novautils/table\").makeLookupMap\
local PATTERN_TEMPLATE_TOKEN = \"(%${)(%w+)(})\"\
local MAP_AFFIRMATIVE_VALUES = makeLookupMap({\
  \"y\",\
  \"yes\",\
  \"t\",\
  \"true\",\
  \"1\"\
})\
isAffirmative = function(userValue)\
  return MAP_AFFIRMATIVE_VALUES[lower(userValue)] or false\
end\
makeTemplate = function(stringTemplate)\
  return function(templateTokens)\
    return gsub(stringTemplate, PATTERN_TEMPLATE_TOKEN, function(startBoundry, tokenName, endBoundry)\
      local tokenValue = templateTokens[tokenName]\
      if not (tokenValue) then\
        return startBoundry .. tokenName .. endBoundry\
      end\
      return tostring(tokenValue)\
    end)\
  end\
end\
makeStringEscape = function(lookup)\
  return function(value)\
    for _index_0 = 1, #lookup do\
      local tokens = lookup[_index_0]\
      value = gsub(value, tokens[1], tokens[2])\
    end\
    return value\
  end\
end\
toBytes = function(sourceString)\
  local _accum_0 = { }\
  local _len_0 = 1\
  for subString in gmatch(sourceString, \".\") do\
    _accum_0[_len_0] = byte(subString)\
    _len_0 = _len_0 + 1\
  end\
  return _accum_0\
end\
toByteString = function(sourceString)\
  local byteTable = toBytes(sourceString)\
  return \"{\" .. concat(byteTable, \",\") .. \"}\"\
end",
['novacbn/gmodproj/main'] = "local pairs, print, unpack\
do\
  local _obj_0 = _G\
  pairs, print, unpack = _obj_0.pairs, _obj_0.print, _obj_0.unpack\
end\
local lower, match\
do\
  local _obj_0 = string\
  lower, match = _obj_0.lower, _obj_0.match\
end\
local concat, insert, remove, sort\
do\
  local _obj_0 = table\
  concat, insert, remove, sort = _obj_0.concat, _obj_0.insert, _obj_0.remove, _obj_0.sort\
end\
local TEXT_COMMAND_VERSION\
TEXT_COMMAND_VERSION = dependency(\"novacbn/gmodproj/commands/version\").TEXT_COMMAND_VERSION\
local formatCommand\
formatCommand = dependency(\"novacbn/gmodproj/lib/utilities/fs\").formatCommand\
local logFatal, logInfo, toggleConsoleLogging, toggleFileLogging\
do\
  local _obj_0 = dependency(\"novacbn/gmodproj/lib/logging\")\
  logFatal, logInfo, toggleConsoleLogging, toggleFileLogging = _obj_0.logFatal, _obj_0.logInfo, _obj_0.toggleConsoleLogging, _obj_0.toggleFileLogging\
end\
local APPLICATION_SUB_COMMANDS = {\
  bin = dependency(\"novacbn/gmodproj/commands/bin\"),\
  build = dependency(\"novacbn/gmodproj/commands/build\"),\
  clean = dependency(\"novacbn/gmodproj/commands/clean\"),\
  init = dependency(\"novacbn/gmodproj/commands/init\"),\
  new = dependency(\"novacbn/gmodproj/commands/new\"),\
  version = dependency(\"novacbn/gmodproj/commands/version\"),\
  watch = dependency(\"novacbn/gmodproj/commands/watch\")\
}\
local APPLICATION_COMMAND_FLAGS = {\
  {\
    \"-ca\",\
    \"--clean-all\",\
    \"\\t\\t\\tEnables cleaning of all generated project files\"\
  },\
  {\
    \"-cl\",\
    \"--clean-logs\",\
    \"\\t\\t\\tEnables cleaning of project log files\"\
  },\
  {\
    \"-nc\",\
    \"--no-cache\",\
    \"\\t\\t\\t\\tDisables caching and cleaning of built project files\"\
  },\
  {\
    \"-nf\",\
    \"--no-file\",\
    \"\\t\\t\\t\\tDisables logging to files\"\
  },\
  {\
    \"-nl\",\
    \"--no-logs\",\
    \"\\t\\t\\t\\tDisables cleaning of project log files\"\
  },\
  {\
    \"-q\",\
    \"--quiet\",\
    \"\\t\\t\\t\\tDisables output to console\"\
  },\
  {\
    \"-ws\",\
    \"--watch-search\",\
    \"\\t\\t\\tEnables watching package search paths specified in project manifest\"\
  }\
}\
local PATTERN_FLAG_MINI = \"%-[%w%-]+\"\
local PATTERN_FLAG_FULL = \"%-%-[%w%-]+\"\
local TEMPLATE_TEXT_HELP\
TEMPLATE_TEXT_HELP = function(version, commands, flags)\
  return \"Garry's Mod Project Manager :: \" .. tostring(version) .. \"\\nSyntax:\9\9gmodproj [flags] [command]\\n\\nExamples:\9gmodproj bin prebuild\\n\9\9gmodproj build production\\n\9\9gmodproj new addon novacbn my-addon\\n\\nFlags:\\n\" .. tostring(flags) .. \"\\n\\nCommands:\\n\" .. tostring(commands)\
end\
local displayHelpText\
displayHelpText = function(flags)\
  local commandsText\
  do\
    local _accum_0 = { }\
    local _len_0 = 1\
    for command, applicationCommand in pairs(APPLICATION_SUB_COMMANDS) do\
      _accum_0[_len_0] = command\
      _len_0 = _len_0 + 1\
    end\
    commandsText = _accum_0\
  end\
  sort(commandsText)\
  do\
    local _accum_0 = { }\
    local _len_0 = 1\
    for _index_0 = 1, #commandsText do\
      local command = commandsText[_index_0]\
      _accum_0[_len_0] = \"\\t\" .. APPLICATION_SUB_COMMANDS[command].formatDescription(flags)\
      _len_0 = _len_0 + 1\
    end\
    commandsText = _accum_0\
  end\
  commandsText = concat(commandsText, \"\\n\")\
  local flagsText\
  do\
    local _accum_0 = { }\
    local _len_0 = 1\
    for _index_0 = 1, #APPLICATION_COMMAND_FLAGS do\
      local flag = APPLICATION_COMMAND_FLAGS[_index_0]\
      _accum_0[_len_0] = \"\\t\" .. tostring(flag[1]) .. \", \" .. tostring(flag[2]) .. tostring(flag[3])\
      _len_0 = _len_0 + 1\
    end\
    flagsText = _accum_0\
  end\
  flagsText = concat(flagsText, \"\\n\")\
  return print(TEMPLATE_TEXT_HELP(TEXT_COMMAND_VERSION, commandsText, flagsText))\
end\
local parseArguments\
parseArguments = function(argv)\
  local arguments, flags = { }, { }\
  for _index_0 = 1, #argv do\
    local argument = argv[_index_0]\
    if match(argument, PATTERN_FLAG_MINI) or match(argument, PATTERN_FLAG_FULL) then\
      flags[lower(argument)] = true\
    else\
      insert(arguments, argument)\
    end\
  end\
  return arguments, flags\
end\
local arguments, flags = parseArguments(process.argv)\
local subCommand = remove(arguments, 1)\
toggleConsoleLogging(not (flags[\"-q\"] or flags[\"--quiet\"]))\
toggleFileLogging(not (flags[\"-nf\"] or flags[\"--no-file\"]))\
logInfo(\"Application starting with: \" .. tostring(formatCommand('gmodproj', ...)), {\
  console = false,\
  file = true\
})\
if subCommand == \"help\" then\
  return displayHelpText(flags)\
else\
  local applicationCommand = APPLICATION_SUB_COMMANDS[subCommand]\
  if applicationCommand then\
    return applicationCommand.executeCommand(flags, unpack(arguments))\
  else\
    return logFatal(\"Sub command '\" .. tostring(subCommand) .. \"' is invalid!\")\
  end\
end",
['novacbn/gmodproj/schemas/AssetData'] = "local Schema\
Schema = dependency(\"novacbn/gmodproj/api/Schema\").Schema\
AssetData = Schema:extend({\
  schema = {\
    metadata = {\
      nested_object = {\
        name = {\
          is = \"string\"\
        },\
        mtime = {\
          is = \"number\"\
        },\
        path = {\
          is = \"string\"\
        }\
      }\
    },\
    dependencies = {\
      list_of = {\
        is = \"string\"\
      }\
    },\
    exports = {\
      \"any_object\"\
    },\
    output = {\
      is = \"string\"\
    }\
  },\
  default = {\
    metadata = {\
      name = \"\",\
      mtime = 0,\
      path = \"\"\
    },\
    dependencies = { },\
    exports = { },\
    output = \"\"\
  }\
})",
['novacbn/gmodproj/schemas/PackagerOptions'] = "local Schema\
Schema = dependency(\"novacbn/gmodproj/api/Schema\").Schema\
PackagerOptions = Schema:extend({\
  namespace = \"Packager\",\
  schema = {\
    excludedAssets = {\
      list_of = {\
        is = \"string\"\
      }\
    },\
    includedAssets = {\
      list_of = {\
        is = \"string\"\
      }\
    },\
    targetPlatform = {\
      is = \"string\"\
    }\
  },\
  default = {\
    excludedAssets = { },\
    includedAssets = { },\
    targetPlatform = \"garrysmod\"\
  }\
})",
['novacbn/gmodproj/schemas/ProjectOptions'] = "local Schema\
Schema = dependency(\"novacbn/gmodproj/api/Schema\").Schema\
local MAP_DEFAULT_PLUGINS\
MAP_DEFAULT_PLUGINS = dependency(\"novacbn/gmodproj/lib/constants\").MAP_DEFAULT_PLUGINS\
PATTERN_METADATA_NAME = \"^%l[%l%d%-]*$\"\
PATTERN_METADATA_REPOSITORY = \"^[%w]+://[%w%./%-]+$\"\
PATTERN_METADATA_VERSION = \"^[%d]+.[%d]+.[%d]+$\"\
ProjectOptions = Schema:extend({\
  schema = {\
    name = {\
      is = \"string\",\
      like = PATTERN_METADATA_NAME\
    },\
    author = {\
      is = \"string\",\
      like = PATTERN_METADATA_NAME\
    },\
    version = {\
      is = \"string\",\
      like = PATTERN_METADATA_VERSION\
    },\
    repository = {\
      is = \"string\",\
      like = PATTERN_METADATA_REPOSITORY\
    },\
    buildDirectory = {\
      is = \"string\"\
    },\
    sourceDirectory = {\
      is = \"string\"\
    },\
    projectBuilds = {\
      is_key_pairs = {\
        \"string\",\
        {\
          \"string\",\
          \"table\"\
        }\
      }\
    },\
    Plugins = {\
      is_key_pairs = {\
        \"string\",\
        \"table\"\
      }\
    },\
    Packager = {\
      \"any_object\"\
    },\
    Resolver = {\
      \"any_object\"\
    }\
  },\
  default = {\
    buildDirectory = \"dist\",\
    sourceDirectory = \"src\",\
    Plugins = MAP_DEFAULT_PLUGINS\
  }\
})",
['novacbn/gmodproj/schemas/ResolverOptions'] = "local join\
join = require(\"path\").join\
local Schema\
Schema = dependency(\"novacbn/gmodproj/api/Schema\").Schema\
local PROJECT_PATH\
PROJECT_PATH = dependency(\"novacbn/gmodproj/lib/constants\").PROJECT_PATH\
ResolverOptions = Schema:extend({\
  namespace = \"Resolver\",\
  schema = {\
    searchPaths = {\
      list_of = {\
        is = \"string\"\
      }\
    }\
  },\
  default = {\
    searchPaths = {\
      join(PROJECT_PATH.home, \"packages\")\
    }\
  }\
})",
['novacbn/novautils/bit'] = "if bit then\
  exports.arshift = bit.arshift\
  exports.band = bit.band\
  exports.bnot = bit.bnot\
  exports.bor = bit.bor\
  exports.bxor = bit.bxor\
  exports.lshift = bit.lshift\
  exports.rol = bit.rol\
  exports.ror = bit.ror\
  exports.rshift = bit.rshift\
elseif bit32 then\
  exports.arshift = bit32.arshift\
  exports.band = bit32.band\
  exports.bnot = bit32.bnot\
  exports.bor = bit32.bor\
  exports.bxor = bit32.bxor\
  exports.lshift = bit32.lshift\
  exports.rol = bit32.lrotate\
  exports.ror = bit32.rrotate\
  exports.rshift = bit32.rshift\
else\
  error(\"could not find 'bit' LuaJIT or 'bit32' Lua 5.2 libraries\")\
end\
local arshift, band, bor, lshift, rshift\
do\
  local _obj_0 = exports\
  arshift, band, bor, lshift, rshift = _obj_0.arshift, _obj_0.band, _obj_0.bor, _obj_0.lshift, _obj_0.rshift\
end\
byteFromInt8 = function(value)\
  return band(value, 255)\
end\
bytesFromInt16 = function(value)\
  return band(rshift(value, 8), 255), band(value, 255)\
end\
bytesFromInt32 = function(value)\
  return band(rshift(value, 24), 255), band(rshift(value, 16), 255), band(rshift(value, 8), 255), band(value, 255)\
end\
int8FromByte = function(byte)\
  return byte\
end\
int16FromBytes = function(byteOne, byteTwo)\
  return bor(lshift(byteOne, 8), byteTwo)\
end\
int32FromBytes = function(byteOne, byteTwo, byteThree, byteFour)\
  return bor(lshift(byteOne, 24), lshift(byteTwo, 16), lshift(byteThree, 8), byteFour)\
end",
['novacbn/novautils/collections/BitEnum'] = "local band, bnot, bor\
do\
  local _obj_0 = dependency(\"novacbn/novautils/bit\")\
  band, bnot, bor = _obj_0.band, _obj_0.bnot, _obj_0.bor\
end\
addFlag = function(bitMask, bitFlag)\
  return bor(bitMask, bitFlag)\
end\
hasFlag = function(bitMask, bitFlag)\
  return band(bitMask, bitFlag) == bitFlag\
end\
removeFlag = function(bitMask, bitFlag)\
  return bnot(bitMask, bitFlag)\
end\
BitEnum = function(fieldNames)\
  local nextFlag = 0\
  local enumLookup = { }\
  for _index_0 = 1, #fieldNames do\
    local value = fieldNames[_index_0]\
    enumLookup[value] = nextFlag\
    nextFlag = nextFlag == 0 and 1 or nextFlag * 2\
  end\
  return enumLookup\
end",
['novacbn/novautils/collections/ByteArray'] = "local unpack\
unpack = _G.unpack\
local byte, char\
do\
  local _obj_0 = string\
  byte, char = _obj_0.byte, _obj_0.char\
end\
local concat\
concat = table.concat\
local mapi\
mapi = dependency(\"novacbn/novautils/table\").mapi\
local Object\
Object = dependency(\"novacbn/novautils/utilities/Object\").Object\
ByteArray = Object:extend({\
  length = 0,\
  fromString = function(self, value)\
    local byteArray = self:new()\
    for index = 1, #value do\
      byteArray[index] = byte(value, index)\
    end\
    byteArray.length = #value\
    return byteArray\
  end,\
  fromTable = function(self, byteTable)\
    local byteArray = self:new()\
    for index = 1, #byteTable do\
      byteArray[index] = byteTable[index]\
    end\
    byteArray.length = #byteTable\
    return byteArray\
  end,\
  toString = function(self)\
    local byteTable = mapi(self, function(i, v)\
      return char(v)\
    end)\
    return concat(byteTable, \"\")\
  end\
})",
['novacbn/novautils/collections/Enum'] = "Enum = function(fieldNames)\
  local _tbl_0 = { }\
  for index = 1, #fieldNames do\
    _tbl_0[fieldNames[index]] = index - 1\
  end\
  return _tbl_0\
end",
['novacbn/novautils/collections/Iterator'] = "local Object\
Object = dependency(\"novacbn/novautils/utilities/Object\").Object\
Iterator = Object:extend({\
  iter = function(self, ...)\
    return self:__iter(...)\
  end,\
  keys = function(self)\
    local _accum_0 = { }\
    local _len_0 = 1\
    for value, key in self:iter() do\
      _accum_0[_len_0] = key\
      _len_0 = _len_0 + 1\
    end\
    return _accum_0\
  end,\
  values = function(self)\
    local _accum_0 = { }\
    local _len_0 = 1\
    for value, key in self:iter() do\
      _accum_0[_len_0] = value\
      _len_0 = _len_0 + 1\
    end\
    return _accum_0\
  end\
})",
['novacbn/novautils/collections/LinkedList'] = "local Iterator\
Iterator = dependency(\"novacbn/novautils/collections/Iterator\").Iterator\
local Node\
Node = function(value, prev, next)\
  return {\
    value = value,\
    prev = prev,\
    next = next,\
    removed = false\
  }\
end\
LinkedList = Iterator:extend({\
  head = nil,\
  length = 0,\
  tail = nil,\
  __iter = function(self, reverse)\
    if reverse == nil then\
      reverse = false\
    end\
    local currentNode = {\
      next = reverse and self.tail or self.head\
    }\
    return function()\
      if currentNode then\
        currentNode = currentNode.next\
        if currentNode then\
          return currentNode\
        end\
      end\
    end\
  end,\
  clear = function(self)\
    self.head = nil\
    self.tail = nil\
  end,\
  find = function(self, value)\
    for node in self:iter() do\
      if node.value == value then\
        return node\
      end\
    end\
    return nil\
  end,\
  has = function(self, value)\
    for node in self:iter() do\
      if node.value == value then\
        return true\
      end\
    end\
    return false\
  end,\
  pop = function(self)\
    if not (self.tail) then\
      error(\"bad call to 'pop' (no Nodes available to pop)\")\
    end\
    return self:remove(self.tail)\
  end,\
  push = function(self, value)\
    local node = Node(value, self.tail, nil)\
    if self.tail then\
      self.tail.next = node\
    end\
    self.tail = node\
    if not (self.head) then\
      self.head = node\
    end\
    self.length = self.length + 1\
    return node\
  end,\
  remove = function(self, node)\
    if node.removed then\
      error(\"bad argument #1 to 'remove' (node was already removed)\")\
    end\
    if node.prev then\
      node.prev.next = node.next\
    end\
    if node.next then\
      node.next.prev = node.prev\
    end\
    if self.head == node then\
      self.head = node.next\
    end\
    if self.tail == node then\
      self.tail = node.prev\
    end\
    node.removed = true\
    node.prev = nil\
    node.next = nil\
    self.length = self.length - 1\
    return node\
  end,\
  shift = function(self)\
    if not (self.head) then\
      error(\"bad call to 'shift' (no nodes available to shift)\")\
    end\
    return self:remove(self.head)\
  end,\
  unshift = function(self, value)\
    local node = Node(value, nil, self.head)\
    if self.head then\
      self.head.prev = node\
    end\
    self.head = node\
    if not (self.tail) then\
      self.tail = node\
    end\
    self.length = self.length + 1\
    return node\
  end,\
  values = function(self)\
    local _accum_0 = { }\
    local _len_0 = 1\
    for node in self:iter() do\
      _accum_0[_len_0] = node.value\
      _len_0 = _len_0 + 1\
    end\
    return _accum_0\
  end\
})",
['novacbn/novautils/collections/Map'] = "local pairs, next\
do\
  local _obj_0 = _G\
  pairs, next = _obj_0.pairs, _obj_0.next\
end\
local Iterator\
Iterator = dependency(\"novacbn/novautils/collections/Iterator\").Iterator\
Map = Iterator:extend({\
  clear = function(self)\
    for key, value in pairs(self) do\
      self[key] = nil\
    end\
  end,\
  get = function(self, key)\
    return self[key]\
  end,\
  has = function(self, key)\
    return self[key] ~= nil\
  end,\
  find = function(self, searchValue)\
    for key, value in pairs(self) do\
      if value == searchValue then\
        return key\
      end\
    end\
    return nil\
  end,\
  set = function(self, key, value)\
    self[key] = value\
  end\
})",
['novacbn/novautils/collections/Set'] = "local type\
type = _G.type\
local insert, remove\
do\
  local _obj_0 = table\
  insert, remove = _obj_0.insert, _obj_0.remove\
end\
local Iterator\
Iterator = dependency(\"novacbn/novautils/collections/Iterator\").Iterator\
local inRange\
inRange = dependency(\"novacbn/novautils/math\").inRange\
local getCacheKey\
getCacheKey = function(value)\
  if type(value) == \"string\" then\
    return \"__set_s_\" .. value\
  elseif type(value) == \"number\" then\
    return \"__set_i_\" .. value\
  end\
  return value\
end\
Set = Iterator:extend({\
  length = 0,\
  fromTable = function(self, sourceTable)\
    local set = self:new()\
    for _index_0 = 1, #sourceTable do\
      local value = sourceTable[_index_0]\
      set:push(value)\
    end\
    return set\
  end,\
  __iter = function(self, reverse)\
    local index = reverse and self.length + 1 or 0\
    return function()\
      index = index + 1\
      return self[index], index\
    end\
  end,\
  clear = function(self)\
    local key\
    for value, index in self:iter() do\
      key = getCacheKey(value)\
      self[index] = nil\
      self[key] = nil\
    end\
  end,\
  find = function(self, searchValue)\
    for value, index in self:iter() do\
      if value == searchValue then\
        return index\
      end\
    end\
    return nil\
  end,\
  has = function(self, value)\
    local key = getCacheKey(value)\
    return self[key] ~= nil\
  end,\
  push = function(self, value)\
    if value == nil then\
      error(\"bad argument #1 to 'push' (expected value)\")\
    end\
    local key = getCacheKey(value)\
    if not (self[key] == nil) then\
      return \
    end\
    local length = self.length + 1\
    self[key] = true\
    self[length] = value\
    self.length = length\
    return length\
  end,\
  pop = function(self, value)\
    return self:remove(self.length)\
  end,\
  remove = function(self, index)\
    if not (inRange(1, self.length)) then\
      error(\"bad argument #1 to 'remove' (invalid index)\")\
    end\
    local key = getCacheKey(self[index])\
    self[key] = nil\
    self.length = self.length - 1\
    return self:remove(self, index)\
  end,\
  shift = function(self, value)\
    if value == nil then\
      error(\"bad argument #1 to 'shift' (expected value)\")\
    end\
    local key = getCacheKey(value)\
    if not (self[key] == nil) then\
      return \
    end\
    local length = self.length + 1\
    self[key] = true\
    insert(self, value, 1)\
    return length\
  end,\
  unshift = function(self)\
    return self:remove(1)\
  end\
})",
['novacbn/novautils/exports'] = "do\
  local _with_0 = exports\
  _with_0.collections = {\
    BitEnum = dependency(\"novacbn/novautils/collections/BitEnum\").BitEnum,\
    ByteArray = dependency(\"novacbn/novautils/collections/ByteArray\").ByteArray,\
    Enum = dependency(\"novacbn/novautils/collections/Enum\").Enum,\
    Iterator = dependency(\"novacbn/novautils/collections/Iterator\").Iterator,\
    LinkedList = dependency(\"novacbn/novautils/collections/LinkedList\").LinkedList,\
    Map = dependency(\"novacbn/novautils/collections/Map\").Map,\
    Set = dependency(\"novacbn/novautils/collections/Set\").Set\
  }\
  _with_0.io = {\
    ReadBuffer = dependency(\"novacbn/novautils/io/ReadBuffer\").ReadBuffer,\
    WriteBuffer = dependency(\"novacbn/novautils/io/WriteBuffer\").WriteBuffer\
  }\
  _with_0.sources = {\
    Event = dependency(\"novacbn/novautils/sources/Event\").Event,\
    Signal = dependency(\"novacbn/novautils/sources/Signal\").Signal,\
    Transform = dependency(\"novacbn/novautils/sources/Transform\").Transform\
  }\
  _with_0.bit = getmetatable(dependency(\"novacbn/novautils/bit\")).__index\
  _with_0.math = getmetatable(dependency(\"novacbn/novautils/math\")).__index\
  _with_0.table = getmetatable(dependency(\"novacbn/novautils/table\")).__index\
end\
do\
  local _with_0 = getmetatable(dependency(\"novacbn/novautils/utilities\")).__index\
  _with_0.Object = dependency(\"novacbn/novautils/utilities/Object\").Object\
  exports.utilities = _with_0\
end",
['novacbn/novautils/io/ReadBuffer'] = "local unpack\
unpack = _G.unpack\
local char\
char = string.char\
local arshift, lshift, int16FromBytes, int32FromBytes\
do\
  local _obj_0 = dependency(\"novacbn/novautils/bit\")\
  arshift, lshift, int16FromBytes, int32FromBytes = _obj_0.arshift, _obj_0.lshift, _obj_0.int16FromBytes, _obj_0.int32FromBytes\
end\
local ByteArray\
ByteArray = dependency(\"novacbn/novautils/collections/ByteArray\").ByteArray\
ReadBuffer = ByteArray:extend({\
  cursor = 0,\
  read = function(self, length)\
    if length == nil then\
      length = 1\
    end\
    local cursor = self.cursor\
    local newCursor = cursor + length\
    if newCursor > self.length then\
      error(\"bad argument #1 to 'read' (read length exceeds buffer length)\")\
    end\
    self.cursor = newCursor\
    return unpack(self, cursor + 1, newCursor)\
  end,\
  readFloat32 = function(self) end,\
  readFloat64 = function(self) end,\
  readInt8 = function(self)\
    return arshift(lshift(self:readUInt8(), 24), 24)\
  end,\
  readInt16 = function(self)\
    return arshift(lshift(self:readUInt16(), 16), 16)\
  end,\
  readInt32 = function(self)\
    return arshift(lshift(self:readUInt32(), 32), 32)\
  end,\
  readString = function(self, length)\
    return char(self:read(length))\
  end,\
  readUInt8 = function(self)\
    return self:read(1)\
  end,\
  readUInt16 = function(self)\
    return int16FromBytes(self:read(2))\
  end,\
  readUInt32 = function(self)\
    return int32FromBytes(self:read(4))\
  end,\
  remaining = function(self)\
    return self.length - self.cursor\
  end\
})",
['novacbn/novautils/io/WriteBuffer'] = "local type\
type = _G.type\
local byte\
byte = string.byte\
local arshift, lshift, byteFromInt8, bytesFromInt16, bytesFromInt32\
do\
  local _obj_0 = dependency(\"novacbn/novautils/bit\")\
  arshift, lshift, byteFromInt8, bytesFromInt16, bytesFromInt32 = _obj_0.arshift, _obj_0.lshift, _obj_0.byteFromInt8, _obj_0.bytesFromInt16, _obj_0.bytesFromInt32\
end\
local inRange\
inRange = dependency(\"novacbn/novautils/math\").inRange\
local ByteArray\
ByteArray = dependency(\"novacbn/novautils/collections/ByteArray\").ByteArray\
WriteBuffer = ByteArray:extend({\
  write = function(self, ...)\
    local varArgs = {\
      ...\
    }\
    local length = self.length\
    local value\
    for index = 1, #varArgs do\
      value = varArgs[index]\
      if not (type(value) == \"number\") then\
        error(\"bad argument #\" .. tostring(index) .. \" to 'write' (expected number)\")\
      end\
      if not (inRange(value, 0, 255)) then\
        error(\"bad argument #\" .. tostring(index) .. \" to 'write' (expected number in range 0...255)\")\
      end\
      self[index + length] = value\
    end\
    self.length = self.length + #varArgs\
  end,\
  writeFloat32 = function(self, value) end,\
  writeFloat64 = function(self, value) end,\
  writeInt8 = function(self, value)\
    return self:write(byteFromInt8(value))\
  end,\
  writeInt16 = function(self, value)\
    return self:write(bytesFromInt16(value))\
  end,\
  writeInt32 = function(self, value)\
    return self:write(bytesFromInt32(value))\
  end,\
  writeString = function(self, value)\
    local length = self.length\
    for index = 1, #value do\
      self[length + index] = byte(value, index)\
    end\
    self.length = self.length + #value\
  end,\
  writeUInt8 = function(self, value)\
    return self:write(byteFromInt8(value))\
  end,\
  writeUInt16 = function(self, value)\
    return self:write(bytesFromInt16(value))\
  end,\
  writeUInt32 = function(self, value)\
    return self:write(bytesFromInt32(value))\
  end\
})",
['novacbn/novautils/math'] = "local maxF, minF = math.max, math.min\
RANGE_INT8 = {\
  min = (0x0000007F + 1) * -1,\
  max = 0x0000007F\
}\
RANGE_INT16 = {\
  min = (0x00007FFF + 1) * -1,\
  max = 0x00007FFF\
}\
RANGE_INT32 = {\
  min = (0x7FFFFFFF + 1) * -1,\
  max = 0x7FFFFFFF\
}\
RANGE_UINT8 = {\
  min = 0x00000000,\
  max = 0x000000FF\
}\
RANGE_UINT16 = {\
  min = 0x00000000,\
  max = 0x00FFFFFF\
}\
RANGE_UINT32 = {\
  min = 0x00000000,\
  max = 0xFFFFFFFF\
}\
clamp = function(value, min, max)\
  return minF(maxF(value, min), max)\
end\
inRange = function(value, min, max)\
  return value <= max and value >= min\
end\
isFloat = function(value)\
  return value % 1 ~= 0\
end\
isInteger = function(value)\
  return value % 1 == 0\
end",
['novacbn/novautils/sources/Event'] = "local unpack\
unpack = _G.unpack\
local Signal\
Signal = dependency(\"novacbn/novautils/sources/Signal\").Signal\
local pack\
pack = dependency(\"novacbn/novautils/utilities\").pack\
Event = Signal:extend({\
  dispatch = function(self, ...)\
    local varRet\
    for node in self:iter() do\
      varRet = pack(node.value(...))\
      if #varRet > 0 then\
        return unpack(varRet)\
      end\
    end\
    return ...\
  end\
})",
['novacbn/novautils/sources/Signal'] = "local LinkedList\
LinkedList = dependency(\"novacbn/novautils/collections/LinkedList\").LinkedList\
local makeDetachFunc\
makeDetachFunc = function(signal, node)\
  return function()\
    if not (node.removed) then\
      signal:remove(node)\
      return false\
    end\
    return true\
  end\
end\
Signal = LinkedList:extend({\
  attach = function(self, listenerFunc)\
    local node = self:push(listenerFunc)\
    return makeDetachFunc(self, node)\
  end,\
  dispatch = function(self, ...)\
    for node in self:iter() do\
      node.value(...)\
    end\
  end,\
  detach = function(self, listenerFunc)\
    local node = self:find(listenerFunc)\
    if not (node) then\
      error(\"bad argument #1 to 'detach' (function not attached)\")\
    end\
    return self:remove(node)\
  end\
})",
['novacbn/novautils/sources/Transform'] = "local unpack\
unpack = _G.unpack\
local Signal\
Signal = dependency(\"novacbn/novautils/sources/Signal\").Signal\
local pack\
pack = dependency(\"novacbn/novautils/utilities\").pack\
Transform = Signal:extend({\
  dispatch = function(self, ...)\
    local varRet = pack(...)\
    local tempRet\
    for node in self:iter() do\
      tempRet = pack(node.value(unpack(varRet)))\
      if #tempRet > 0 then\
        varRet = tempRet\
      end\
    end\
    return unpack(varRet)\
  end\
})",
['novacbn/novautils/table'] = "local ipairs, pairs, type\
do\
  local _obj_0 = _G\
  ipairs, pairs, type = _obj_0.ipairs, _obj_0.pairs, _obj_0.type\
end\
clone = function(sourceTable)\
  local _tbl_0 = { }\
  for key, value in pairs(sourceTable) do\
    _tbl_0[key] = type(value) == \"table\" and clone(value) or value\
  end\
  return _tbl_0\
end\
copy = function(sourceTable)\
  local _tbl_0 = { }\
  for key, value in pairs(sourceTable) do\
    _tbl_0[key] = value\
  end\
  return _tbl_0\
end\
deepMerge = function(targetTable, sourceTable)\
  for key, value in pairs(sourceTable) do\
    if type(targetTable[key]) == \"table\" and type(value) == \"table\" then\
      deepMerge(targetTable[key], value)\
    end\
    if targetTable[key] == nil then\
      if type(value) == \"table\" then\
        value = clone(value)\
      end\
      targetTable[key] = value\
    end\
  end\
  return targetTable\
end\
deepUpdate = function(targetTable, sourceTable)\
  for key, value in pairs(sourceTable) do\
    if type(value) == \"table\" then\
      if type(targetTable[key]) == \"table\" then\
        deepUpdate(targetTable[key], value)\
      else\
        targetTable[key] = clone(value)\
      end\
    else\
      targetTable[key] = value\
    end\
  end\
  return targetTable\
end\
keysMeta = function(sourceTable, collectionTable)\
  if collectionTable == nil then\
    collectionTable = { }\
  end\
  local metaTable = getmetatable(sourceTable)\
  if metaTable and type(metaTable.__index) == \"table\" then\
    keysMeta(metaTable.__index, collectionTable)\
  end\
  for key, value in pairs(sourceTable) do\
    collectionTable[key] = value\
  end\
  return collectionTable\
end\
isNumericTable = function(sourceTable)\
  for key, value in pairs(sourceTable) do\
    if not (type(key) == \"number\") then\
      return false\
    end\
  end\
  return true\
end\
isSequentialTable = function(sourceTable)\
  local countedLength, previousIndex = 0, nil\
  for index, value in ipairs(sourceTable) do\
    if previousIndex then\
      if (previousIndex - index) > 1 then\
        return false\
      end\
    end\
    previousIndex = index\
    countedLength = countedLength + 1\
  end\
  return countedLength == #sourceTable\
end\
makeLookupMap = function(lookupValues)\
  local _tbl_0 = { }\
  for key, value in pairs(lookupValues) do\
    _tbl_0[value] = key\
  end\
  return _tbl_0\
end\
makeTruthMap = function(lookupValues)\
  local _tbl_0 = { }\
  for _index_0 = 1, #lookupValues do\
    local value = lookupValues[_index_0]\
    _tbl_0[value] = true\
  end\
  return _tbl_0\
end\
map = function(targetTable, func)\
  local _tbl_0 = { }\
  for key, value in pairs(targetTable) do\
    local _key_0, _val_0 = func(key, value)\
    _tbl_0[_key_0] = _val_0\
  end\
  return _tbl_0\
end\
mapi = function(targetTable, func)\
  local remappedTable = { }\
  local length = 0\
  local remappedValue\
  for index, value in ipairs(targetTable) do\
    remappedValue = func(index, value)\
    if not (remappedValue == nil) then\
      length = length + 1\
      remappedTable[length] = remappedValue\
    end\
  end\
  return remappedTable\
end\
merge = function(targetTable, sourceTable)\
  for key, value in pairs(sourceTable) do\
    if targetTable[key] == nil then\
      if type(value) == \"table\" then\
        value = clone(value)\
      end\
      targetTable[key] = value\
    end\
  end\
  return targetTable\
end\
update = function(targetTable, sourceTable)\
  for key, value in pairs(sourceTable) do\
    if type(value) == \"table\" then\
      value = clone(value)\
    end\
    targetTable[key] = value\
  end\
  return targetTable\
end\
slice = function(targetTable, startIndex, endIndex)\
  local _accum_0 = { }\
  local _len_0 = 1\
  for index = startIndex, endIndex do\
    _accum_0[_len_0] = targetTable[index]\
    _len_0 = _len_0 + 1\
  end\
  return _accum_0\
end",
['novacbn/novautils/utilities'] = "local select, unpack\
do\
  local _obj_0 = _G\
  select, unpack = _obj_0.select, _obj_0.unpack\
end\
bind = function(boundFunction, ...)\
  local varArgs = pack(...)\
  return function(...)\
    return boundFunction(unpack(varArgs), ...)\
  end\
end\
pack = function(...)\
  return {\
    n = select(\"#\", ...),\
    ...\
  }\
end",
['novacbn/novautils/utilities/Object'] = "local getmetatable, pairs, rawget, setmetatable, type\
do\
  local _obj_0 = _G\
  getmetatable, pairs, rawget, setmetatable, type = _obj_0.getmetatable, _obj_0.pairs, _obj_0.rawget, _obj_0.setmetatable, _obj_0.type\
end\
local bind\
bind = dependency(\"novacbn/novautils/utilities\").bind\
local clone, keysMeta\
do\
  local _obj_0 = dependency(\"novacbn/novautils/table\")\
  clone, keysMeta = _obj_0.clone, _obj_0.keysMeta\
end\
Object = {\
  new = function(objectClass, ...)\
    local newInstance = setmetatable({ }, objectClass)\
    local metaKeys = keysMeta(objectClass)\
    for key, value in pairs(metaKeys) do\
      if type(value) == \"table\" and isInstance(Decorator, value) then\
        value:__initialized(newInstance, key)\
      end\
    end\
    if newInstance.constructor then\
      newInstance:constructor(...)\
    end\
    return newInstance\
  end,\
  extend = function(parentClass, objectMembers)\
    objectMembers.__index = objectMembers\
    setmetatable(objectMembers, parentClass)\
    for key, value in pairs(objectMembers) do\
      if type(value) == \"table\" and isInstance(Decorator, value) then\
        value:__assigned(objectMembers, key)\
      end\
    end\
    if parentClass.__extended then\
      parentClass:__extended(objectMembers)\
    end\
    return objectMembers\
  end\
}\
Object.__index = Object\
isInstance = function(parentObject, targetObject)\
  if rawget(targetObject, \"__index\") ~= targetObject then\
    return hasInherited(parentObject, targetObject)\
  end\
  return false\
end\
hasInherited = function(parentObject, targetObject)\
  local metaTable = targetObject\
  while metaTable do\
    if metaTable == parentObject then\
      return true\
    end\
    metaTable = getmetatable(metaTable)\
  end\
  return false\
end\
Decorator = Object:extend({\
  __call = function(self, ...)\
    return self.new(self, ...)\
  end,\
  __assigned = function(self, objectClass, memberName) end,\
  __initialized = function(self, objectInstance, memberName) end\
})\
Default = Decorator:extend({\
  constructor = function(self, defaultValue, ...)\
    local _exp_0 = type(defaultValue)\
    if \"table\" == _exp_0 then\
      if hasInherited(Object, defaultValue) then\
        self.generator = bind(defaultValue.new, defaultValue, ...)\
      else\
        self.generator = bind(clone, defaultValue)\
      end\
    elseif \"function\" == _exp_0 then\
      self.generator = bind(defaultValue, ...)\
    end\
    self.defaultValue = defaultValue\
  end,\
  __initialized = function(self, newObject, memberName)\
    newObject[memberName] = self.generator and self:generator() or self.defaultValue\
  end\
})",
['novacbn/properties/encoders/lua'] = "local ipairs, loadstring, pairs, setmetatable, type\
do\
  local _obj_0 = _G\
  ipairs, loadstring, pairs, setmetatable, type = _obj_0.ipairs, _obj_0.loadstring, _obj_0.pairs, _obj_0.setmetatable, _obj_0.type\
end\
local stderr\
stderr = io.stderr\
local format, match, rep\
do\
  local _obj_0 = string\
  format, match, rep = _obj_0.format, _obj_0.match, _obj_0.rep\
end\
local concat, insert\
do\
  local _obj_0 = table\
  concat, insert = _obj_0.concat, _obj_0.insert\
end\
local getKeys, getSortedValues, isArray\
do\
  local _obj_0 = dependency(\"novacbn/properties/utilities\")\
  getKeys, getSortedValues, isArray = _obj_0.getKeys, _obj_0.getSortedValues, _obj_0.isArray\
end\
do\
  local _with_0 = { }\
  local options = nil\
  _with_0.stackLevel = -1\
  _with_0.new = function(self, encoderOptions)\
    return setmetatable({\
      options = encoderOptions\
    }, self)\
  end\
  _with_0.append = function(self, value, ignoreStack, appendTail)\
    if ignoreStack or self.stackLevel < 1 then\
      if not (appendTail) then\
        return insert(self, value)\
      else\
        local length = #self\
        self[length] = self[length] .. value\
      end\
    else\
      return insert(self, rep(self.options.indentationChar, self.stackLevel) .. value)\
    end\
  end\
  _with_0.boolean = function(self, value)\
    return value and \"true\" or \"false\"\
  end\
  _with_0.boolean_key = function(self, value)\
    return \"[\" .. (value and \"true\" or \"false\") .. \"]\"\
  end\
  _with_0.number = function(self, value)\
    return tostring(value)\
  end\
  _with_0.number_key = function(self, value)\
    return \"[\" .. value .. \"]\"\
  end\
  _with_0.string = function(self, value)\
    return format(\"%q\", value)\
  end\
  _with_0.string_key = function(self, value)\
    return match(value, \"^%a+$\") and value or format(\"[%q]\", value)\
  end\
  _with_0.array = function(self, arr)\
    local length = #arr\
    local encoder\
    for index, value in ipairs(arr) do\
      encoder = self[type(value)]\
      if not (encoder) then\
        error(\"bad argument #1 to 'Encoder.array' (unexpected type)\")\
      end\
      if encoder == self.table then\
        self:encoder(self, value, index < length)\
      else\
        if index < length then\
          self:append(encoder(self, value, true) .. \",\")\
        else\
          self:append(encoder(self, value, false))\
        end\
      end\
    end\
  end\
  _with_0.map = function(self, map)\
    local keys = getSortedValues(getKeys(map))\
    local length = #keys\
    local count = 0\
    local keyEncoder, value, valueEncoder\
    for _index_0 = 1, #keys do\
      local key = keys[_index_0]\
      keyEncoder = self[type(key) .. \"_key\"]\
      if not (keyEncoder) then\
        error(\"bad argument #1 to 'Encoder.map' (unexpected key type)\")\
      end\
      value = map[key]\
      valueEncoder = self[type(value)]\
      if not (valueEncoder) then\
        error(\"bad argument #1 to Encoder.map (unexpected value type)\")\
      end\
      count = count + 1\
      if valueEncoder == self.table then\
        self:append(keyEncoder(self, key) .. \" = \")\
        valueEncoder(self, value, count < length)\
      else\
        if count < length then\
          self:append(keyEncoder(self, key) .. \" = \" .. valueEncoder(self, value) .. \",\")\
        else\
          self:append(keyEncoder(self, key) .. \" = \" .. valueEncoder(self, value))\
        end\
      end\
    end\
  end\
  _with_0.table = function(self, tbl, innerMember, isRoot)\
    if not (isRoot) then\
      self:append(\"{\", true, true)\
    end\
    self.stackLevel = self.stackLevel + 1\
    if isArray(tbl) then\
      self:array(tbl)\
    else\
      self:map(tbl)\
    end\
    self.stackLevel = self.stackLevel - 1\
    if not (isRoot) then\
      return self:append(innerMember and \"},\" or \"}\")\
    end\
  end\
  _with_0.toString = function(self)\
    return concat(self, \"\\n\")\
  end\
  LuaEncoder = _with_0\
end\
LuaEncoder.__index = LuaEncoder\
encode = function(tbl, encoderOptions)\
  local encoder = LuaEncoder:new(encoderOptions)\
  encoder:table(tbl, false, true)\
  return encoder:toString()\
end\
decode = function(value, decoderOptions)\
  if not (decoderOptions.allowUnsafe) then\
    error(\"bad option 'allowUnsafe' to 'decode' (Lua AST parser not implemented)\")\
  end\
  local chunk, err = loadstring(\"return {\" .. tostring(value) .. \"}\")\
  if err then\
    stderr:write(\"bad argument #1 to 'decode' (Lua syntax error)\\n\")\
    error(err)\
  end\
  return chunk()\
end",
['novacbn/properties/encoders/moonscript'] = "local pairs, setmetatable, type\
do\
  local _obj_0 = _G\
  pairs, setmetatable, type = _obj_0.pairs, _obj_0.setmetatable, _obj_0.type\
end\
local stderr\
stderr = io.stderr\
local format, match, rep\
do\
  local _obj_0 = string\
  format, match, rep = _obj_0.format, _obj_0.match, _obj_0.rep\
end\
local insert\
insert = table.insert\
local hasMoonScript, moonscript = pcall(require, \"moonscript/base\")\
local getKeys, getSortedValues, isArray\
do\
  local _obj_0 = dependency(\"novacbn/properties/utilities\")\
  getKeys, getSortedValues, isArray = _obj_0.getKeys, _obj_0.getSortedValues, _obj_0.isArray\
end\
local LuaEncoder\
LuaEncoder = dependency(\"novacbn/properties/encoders/lua\").LuaEncoder\
do\
  local _with_0 = { }\
  _with_0.new = function(self, encoderOptions)\
    return setmetatable({\
      options = encoderOptions\
    }, self)\
  end\
  _with_0.boolean_key = function(self, value)\
    return value and \"true\" or \"false\"\
  end\
  _with_0.string_key = function(self, value)\
    return match(value, \"^%a+$\") and value or format(\"%q\", value)\
  end\
  _with_0.map = function(self, map)\
    local keys = getSortedValues(getKeys(map))\
    local length = #keys\
    local count = 0\
    local keyEncoder, value, valueEncoder\
    for _index_0 = 1, #keys do\
      local key = keys[_index_0]\
      keyEncoder = self[type(key) .. \"_key\"]\
      if not (keyEncoder) then\
        error(\"bad argument #1 to 'Encoder.map' (unexpected key type)\")\
      end\
      value = map[key]\
      valueEncoder = self[type(value)]\
      if not (valueEncoder) then\
        error(\"bad argument #1 to Encoder.map (unexpected value type)\")\
      end\
      count = count + 1\
      if valueEncoder == self.table then\
        self:append(keyEncoder(self, key) .. \": \")\
        valueEncoder(self, value, count < length)\
      else\
        self:append(keyEncoder(self, key) .. \": \" .. valueEncoder(self, value))\
      end\
    end\
  end\
  _with_0.table = function(self, tbl, innerMember, isRoot)\
    self.stackLevel = self.stackLevel + 1\
    if isArray(tbl) then\
      if not (isRoot) then\
        self:append(\"{\", true, true)\
      end\
      self:array(tbl)\
      self.stackLevel = self.stackLevel - 1\
      if not (isRoot) then\
        return self:append(\"}\")\
      end\
    else\
      self:map(tbl)\
      self.stackLevel = self.stackLevel - 1\
    end\
  end\
  MoonScriptEncoder = _with_0\
end\
setmetatable(MoonScriptEncoder, LuaEncoder)\
MoonScriptEncoder.__index = MoonScriptEncoder\
encode = function(tbl, encoderOptions)\
  local encoder = MoonScriptEncoder:new(encoderOptions)\
  encoder:table(tbl, false, true)\
  return encoder:toString()\
end\
decode = function(value, decoderOptions)\
  if not (hasMoonScript) then\
    error(\"bad dispatch to 'decode' (MoonScript library is not installed)\")\
  end\
  if not (decoderOptions.allowUnsafe) then\
    error(\"bad option 'allowUnsafe' to 'decode' (MoonScript AST parser not implemented)\")\
  end\
  local chunk, err = moonscript.loadstring(\"{\" .. tostring(value) .. \"}\")\
  if err then\
    stderr:write(\"bad argument #1 to 'decode' (MoonScript syntax error)\\n\")\
    error(err)\
  end\
  return chunk()\
end",
['novacbn/properties/exports'] = "local type\
type = _G.type\
local propertiesEncoders = {\
  lua = dependency(\"novacbn/properties/encoders/lua\"),\
  moonscript = dependency(\"novacbn/properties/encoders/moonscript\")\
}\
local EncoderOptions\
EncoderOptions = function(options)\
  do\
    local _with_0 = options or { }\
    _with_0.allowUnsafe = _with_0.allowUnsafe or true\
    _with_0.indentationChar = _with_0.indentationChar or \"\\t\"\
    _with_0.propertiesEncoder = propertiesEncoders[_with_0.propertiesEncoder or \"lua\"]\
    _with_0.sortKeys = _with_0.sortKeys == nil and true or _with_0.sortKeys\
    _with_0.sortIgnoreCase = _with_0.sortIgnoreCase == nil and true or _with_0.sortIgnoreCase\
    if not (_with_0.propertiesEncoder) then\
      error(\"bad option 'propertiesEncoder' to 'EncoderOptions' (invalid value '\" .. tostring(decoderOptions.propertiesEncoder) .. \"')\")\
    end\
    return _with_0\
  end\
end\
local DecoderOptions\
DecoderOptions = function(options)\
  do\
    local _with_0 = options or { }\
    _with_0.allowUnsafe = _with_0.allowUnsafe or true\
    _with_0.propertiesEncoder = propertiesEncoders[_with_0.propertiesEncoder or \"lua\"]\
    if not (_with_0.propertiesEncoder) then\
      error(\"bad option 'propertiesEncoder' to 'DecoderOptions' (invalid value '\" .. tostring(decoderOptions.propertiesEncoder) .. \"')\")\
    end\
    return _with_0\
  end\
end\
encode = function(value, options)\
  if not (type(value) == \"table\") then\
    error(\"bad argument #1 to 'encode' (expected table)\")\
  end\
  if not (options == nil or type(options) == \"table\") then\
    error(\"bad argument #2 to 'encode' (expected table)\")\
  end\
  local encoderOptions = EncoderOptions(options)\
  return encoderOptions.propertiesEncoder.encode(value, encoderOptions)\
end\
decode = function(value, options)\
  if not (type(value) == \"string\") then\
    error(\"bad argument #1 to 'decode' (expected string)\")\
  end\
  if not (options == nil or type(options) == \"table\") then\
    error(\"bad argument #2 to 'decode' (expected table)\")\
  end\
  local decoderOptions = DecoderOptions(options)\
  return decoderOptions.propertiesEncoder.decode(value, decoderOptions)\
end",
['novacbn/properties/utilities'] = "local pairs, type\
do\
  local _obj_0 = _G\
  pairs, type = _obj_0.pairs, _obj_0.type\
end\
local lower\
lower = string.lower\
local sort\
sort = table.sort\
local sortingWeights = {\
  boolean = 0,\
  number = 1,\
  string = 2,\
  table = 3\
}\
getKeys = function(tbl)\
  local _accum_0 = { }\
  local _len_0 = 1\
  for key, value in pairs(tbl) do\
    _accum_0[_len_0] = key\
    _len_0 = _len_0 + 1\
  end\
  return _accum_0\
end\
getSortedValues = function(tbl, isCaseSensitive)\
  local values\
  do\
    local _accum_0 = { }\
    local _len_0 = 1\
    for _index_0 = 1, #tbl do\
      local value = tbl[_index_0]\
      _accum_0[_len_0] = value\
      _len_0 = _len_0 + 1\
    end\
    values = _accum_0\
  end\
  local aWeight, bWeight, aType, bType\
  sort(values, function(a, b)\
    aType, bType = type(a), type(b)\
    if aType == \"string\" and bType == \"string\" then\
      if not (isCaseSensitive) then\
        return lower(a) < lower(b)\
      end\
      return a < b\
    elseif aType == \"boolean\" and bType == \"boolean\" then\
      if aType == true and bType == false then\
        return false\
      end\
      return true\
    elseif aType == \"number\" and bType == \"number\" then\
      return a < b\
    else\
      return sortingWeights[aType] < sortingWeights[bType]\
    end\
  end)\
  return values\
end\
isArray = function(tbl)\
  if tbl[1] == nil then\
    return false\
  end\
  local count = 0\
  for key, value in pairs(tbl) do\
    if not (type(key) == \"number\") then\
      return false\
    end\
    count = count + 1\
  end\
  if not (count == #tbl) then\
    return false\
  end\
  return true\
end",
['pkulchenko/serpent/main'] = "--[[\
    https://github.com/pkulchenko/serpent\
\
    Serpent source is released under the MIT License\
\
    Copyright (c) 2012-2017 Paul Kulchenko (paul@kulchenko.com)\
\
    Permission is hereby granted, free of charge, to any person obtaining a copy\
    of this software and associated documentation files (the \"Software\"), to deal\
    in the Software without restriction, including without limitation the rights\
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\
    copies of the Software, and to permit persons to whom the Software is\
    furnished to do so, subject to the following conditions:\
\
    The above copyright notice and this permission notice shall be included in\
    all copies or substantial portions of the Software.\
\
    THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\
    THE SOFTWARE.\
]]--\
\
local n, v = \"serpent\", \"0.30\" -- (C) 2012-17 Paul Kulchenko; MIT License\
local c, d = \"Paul Kulchenko\", \"Lua serializer and pretty printer\"\
local snum = {[tostring(1/0)]='1/0 --[[math.huge]]',[tostring(-1/0)]='-1/0 --[[-math.huge]]',[tostring(0/0)]='0/0'}\
local badtype = {thread = true, userdata = true, cdata = true}\
local getmetatable = debug and debug.getmetatable or getmetatable\
local pairs = function(t) return next, t end -- avoid using __pairs in Lua 5.2+\
local keyword, globals, G = {}, {}, (_G or _ENV)\
for _,k in ipairs({'and', 'break', 'do', 'else', 'elseif', 'end', 'false',\
  'for', 'function', 'goto', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat',\
  'return', 'then', 'true', 'until', 'while'}) do keyword[k] = true end\
for k,v in pairs(G) do globals[v] = k end -- build func to name mapping\
for _,g in ipairs({'coroutine', 'debug', 'io', 'math', 'string', 'table', 'os'}) do\
  for k,v in pairs(type(G[g]) == 'table' and G[g] or {}) do globals[v] = g..'.'..k end end\
\
local function s(t, opts)\
  local name, indent, fatal, maxnum = opts.name, opts.indent, opts.fatal, opts.maxnum\
  local sparse, custom, huge = opts.sparse, opts.custom, not opts.nohuge\
  local space, maxl = (opts.compact and '' or ' '), (opts.maxlevel or math.huge)\
  local maxlen, metatostring = tonumber(opts.maxlength), opts.metatostring\
  local iname, comm = '_'..(name or ''), opts.comment and (tonumber(opts.comment) or math.huge)\
  local numformat = opts.numformat or \"%.17g\"\
  local seen, sref, syms, symn = {}, {'local '..iname..'={}'}, {}, 0\
  local function gensym(val) return '_'..(tostring(tostring(val)):gsub(\"[^%w]\",\"\"):gsub(\"(%d%w+)\",\
    -- tostring(val) is needed because __tostring may return a non-string value\
    function(s) if not syms[s] then symn = symn+1; syms[s] = symn end return tostring(syms[s]) end)) end\
  local function safestr(s) return type(s) == \"number\" and tostring(huge and snum[tostring(s)] or numformat:format(s))\
    or type(s) ~= \"string\" and tostring(s) -- escape NEWLINE/010 and EOF/026\
    or (\"%q\"):format(s):gsub(\"\\010\",\"n\"):gsub(\"\\026\",\"\\\\026\") end\
  local function comment(s,l) return comm and (l or 0) < comm and ' --[['..select(2, pcall(tostring, s))..']]' or '' end\
  local function globerr(s,l) return globals[s] and globals[s]..comment(s,l) or not fatal\
    and safestr(select(2, pcall(tostring, s))) or error(\"Can't serialize \"..tostring(s)) end\
  local function safename(path, name) -- generates foo.bar, foo[3], or foo['b a r']\
    local n = name == nil and '' or name\
    local plain = type(n) == \"string\" and n:match(\"^[%l%u_][%w_]*$\") and not keyword[n]\
    local safe = plain and n or '['..safestr(n)..']'\
    return (path or '')..(plain and path and '.' or '')..safe, safe end\
  local alphanumsort = type(opts.sortkeys) == 'function' and opts.sortkeys or function(k, o, n) -- k=keys, o=originaltable, n=padding\
    local maxn, to = tonumber(n) or 12, {number = 'a', string = 'b'}\
    local function padnum(d) return (\"%0\"..tostring(maxn)..\"d\"):format(tonumber(d)) end\
    table.sort(k, function(a,b)\
      -- sort numeric keys first: k[key] is not nil for numerical keys\
      return (k[a] ~= nil and 0 or to[type(a)] or 'z')..(tostring(a):gsub(\"%d+\",padnum))\
           < (k[b] ~= nil and 0 or to[type(b)] or 'z')..(tostring(b):gsub(\"%d+\",padnum)) end) end\
  local function val2str(t, name, indent, insref, path, plainindex, level)\
    local ttype, level, mt = type(t), (level or 0), getmetatable(t)\
    local spath, sname = safename(path, name)\
    local tag = plainindex and\
      ((type(name) == \"number\") and '' or name..space..'='..space) or\
      (name ~= nil and sname..space..'='..space or '')\
    if seen[t] then -- already seen this element\
      sref[#sref+1] = spath..space..'='..space..seen[t]\
      return tag..'nil'..comment('ref', level) end\
    -- protect from those cases where __tostring may fail\
    if type(mt) == 'table' then\
      local to, tr = pcall(function() return mt.__tostring(t) end)\
      local so, sr = pcall(function() return mt.__serialize(t) end)\
      if (opts.metatostring ~= false and to or so) then -- knows how to serialize itself\
        seen[t] = insref or spath\
        t = so and sr or tr\
        ttype = type(t)\
      end -- new value falls through to be serialized\
    end\
    if ttype == \"table\" then\
      if level >= maxl then return tag..'{}'..comment('maxlvl', level) end\
      seen[t] = insref or spath\
      if next(t) == nil then return tag..'{}'..comment(t, level) end -- table empty\
      if maxlen and maxlen < 0 then return tag..'{}'..comment('maxlen', level) end\
      local maxn, o, out = math.min(#t, maxnum or #t), {}, {}\
      for key = 1, maxn do o[key] = key end\
      if not maxnum or #o < maxnum then\
        local n = #o -- n = n + 1; o[n] is much faster than o[#o+1] on large tables\
        for key in pairs(t) do if o[key] ~= key then n = n + 1; o[n] = key end end end\
      if maxnum and #o > maxnum then o[maxnum+1] = nil end\
      if opts.sortkeys and #o > maxn then alphanumsort(o, t, opts.sortkeys) end\
      local sparse = sparse and #o > maxn -- disable sparsness if only numeric keys (shorter output)\
      for n, key in ipairs(o) do\
        local value, ktype, plainindex = t[key], type(key), n <= maxn and not sparse\
        if opts.valignore and opts.valignore[value] -- skip ignored values; do nothing\
        or opts.keyallow and not opts.keyallow[key]\
        or opts.keyignore and opts.keyignore[key]\
        or opts.valtypeignore and opts.valtypeignore[type(value)] -- skipping ignored value types\
        or sparse and value == nil then -- skipping nils; do nothing\
        elseif ktype == 'table' or ktype == 'function' or badtype[ktype] then\
          if not seen[key] and not globals[key] then\
            sref[#sref+1] = 'placeholder'\
            local sname = safename(iname, gensym(key)) -- iname is table for local variables\
            sref[#sref] = val2str(key,sname,indent,sname,iname,true) end\
          sref[#sref+1] = 'placeholder'\
          local path = seen[t]..'['..tostring(seen[key] or globals[key] or gensym(key))..']'\
          sref[#sref] = path..space..'='..space..tostring(seen[value] or val2str(value,nil,indent,path))\
        else\
          out[#out+1] = val2str(value,key,indent,insref,seen[t],plainindex,level+1)\
          if maxlen then\
            maxlen = maxlen - #out[#out]\
            if maxlen < 0 then break end\
          end\
        end\
      end\
      local prefix = string.rep(indent or '', level)\
      local head = indent and '{\\n'..prefix..indent or '{'\
      local body = table.concat(out, ','..(indent and '\\n'..prefix..indent or space))\
      local tail = indent and \"\\n\"..prefix..'}' or '}'\
      return (custom and custom(tag,head,body,tail,level) or tag..head..body..tail)..comment(t, level)\
    elseif badtype[ttype] then\
      seen[t] = insref or spath\
      return tag..globerr(t, level)\
    elseif ttype == 'function' then\
      seen[t] = insref or spath\
      if opts.nocode then return tag..\"function() --[[..skipped..]] end\"..comment(t, level) end\
      local ok, res = pcall(string.dump, t)\
      local func = ok and \"((loadstring or load)(\"..safestr(res)..\",'@serialized'))\"..comment(t, level)\
      return tag..(func or globerr(t, level))\
    else return tag..safestr(t) end -- handle all other types\
  end\
  local sepr = indent and \"\\n\" or \";\"..space\
  local body = val2str(t, name, indent) -- this call also populates sref\
  local tail = #sref>1 and table.concat(sref, sepr)..sepr or ''\
  local warn = opts.comment and #sref>1 and space..\"--[[incomplete output with shared/self-references skipped]]\" or ''\
  return not name and body..warn or \"do local \"..body..sepr..tail..\"return \"..name..sepr..\"end\"\
end\
\
local function deserialize(data, opts)\
  local env = (opts and opts.safe == false) and G\
    or setmetatable({}, {\
        __index = function(t,k) return t end,\
        __call = function(t,...) error(\"cannot call functions\") end\
      })\
  local f, res = (loadstring or load)('return '..data, nil, nil, env)\
  if not f then f, res = (loadstring or load)(data, nil, nil, env) end\
  if not f then return f, res end\
  if setfenv then setfenv(f, env) end\
  return pcall(f)\
end\
\
local function merge(a, b) if b then for k,v in pairs(b) do a[k] = v end end; return a; end\
\
exports._NAME         = n\
exports._COPYRIGHT    = c\
exports._DESCRIPTION  = d\
exports._VERSION      = v\
exports.serialize     = s\
exports.load          = deserialize\
\
exports.dump  = function(a, opts) return s(a, merge({name = '_', compact = true, sparse = true}, opts)) end\
exports.line  = function(a, opts) return s(a, merge({sortkeys = true, comment = true}, opts)) end\
exports.block = function(a, opts) return s(a, merge({indent = '  ', sortkeys = true, comment = true}, opts)) end",
['rxi/json/main'] = "--\
-- json.lua\
--\
-- Copyright (c) 2018 rxi\
--\
-- Permission is hereby granted, free of charge, to any person obtaining a copy of\
-- this software and associated documentation files (the \"Software\"), to deal in\
-- the Software without restriction, including without limitation the rights to\
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies\
-- of the Software, and to permit persons to whom the Software is furnished to do\
-- so, subject to the following conditions:\
--\
-- The above copyright notice and this permission notice shall be included in all\
-- copies or substantial portions of the Software.\
--\
-- THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\
-- SOFTWARE.\
--\
\
exports._version = \"0.1.1\"\
\
-------------------------------------------------------------------------------\
-- Encode\
-------------------------------------------------------------------------------\
\
local encode\
\
local escape_char_map = {\
  [ \"\\\\\" ] = \"\\\\\\\\\",\
  [ \"\\\"\" ] = \"\\\\\\\"\",\
  [ \"\\b\" ] = \"\\\\b\",\
  [ \"\\f\" ] = \"\\\\f\",\
  [ \"\\n\" ] = \"\\\\n\",\
  [ \"\\r\" ] = \"\\\\r\",\
  [ \"\\t\" ] = \"\\\\t\",\
}\
\
local escape_char_map_inv = { [ \"\\\\/\" ] = \"/\" }\
for k, v in pairs(escape_char_map) do\
  escape_char_map_inv[v] = k\
end\
\
\
local function escape_char(c)\
  return escape_char_map[c] or string.format(\"\\\\u%04x\", c:byte())\
end\
\
\
local function encode_nil(val)\
  return \"null\"\
end\
\
\
local function encode_table(val, stack)\
  local res = {}\
  stack = stack or {}\
\
  -- Circular reference?\
  if stack[val] then error(\"circular reference\") end\
\
  stack[val] = true\
\
  if val[1] ~= nil or next(val) == nil then\
    -- Treat as array -- check keys are valid and it is not sparse\
    local n = 0\
    for k in pairs(val) do\
      if type(k) ~= \"number\" then\
        error(\"invalid table: mixed or invalid key types\")\
      end\
      n = n + 1\
    end\
    if n ~= #val then\
      error(\"invalid table: sparse array\")\
    end\
    -- Encode\
    for i, v in ipairs(val) do\
      table.insert(res, encode(v, stack))\
    end\
    stack[val] = nil\
    return \"[\" .. table.concat(res, \",\") .. \"]\"\
\
  else\
    -- Treat as an object\
    for k, v in pairs(val) do\
      if type(k) ~= \"string\" then\
        error(\"invalid table: mixed or invalid key types\")\
      end\
      table.insert(res, encode(k, stack) .. \":\" .. encode(v, stack))\
    end\
    stack[val] = nil\
    return \"{\" .. table.concat(res, \",\") .. \"}\"\
  end\
end\
\
\
local function encode_string(val)\
  return '\"' .. val:gsub('[%z\\1-\\31\\\\\"]', escape_char) .. '\"'\
end\
\
\
local function encode_number(val)\
  -- Check for NaN, -inf and inf\
  if val ~= val or val <= -math.huge or val >= math.huge then\
    error(\"unexpected number value '\" .. tostring(val) .. \"'\")\
  end\
  return string.format(\"%.14g\", val)\
end\
\
\
local type_func_map = {\
  [ \"nil\"     ] = encode_nil,\
  [ \"table\"   ] = encode_table,\
  [ \"string\"  ] = encode_string,\
  [ \"number\"  ] = encode_number,\
  [ \"boolean\" ] = tostring,\
}\
\
\
encode = function(val, stack)\
  local t = type(val)\
  local f = type_func_map[t]\
  if f then\
    return f(val, stack)\
  end\
  error(\"unexpected type '\" .. t .. \"'\")\
end\
\
\
function exports.encode(val)\
  return ( encode(val) )\
end\
\
\
-------------------------------------------------------------------------------\
-- Decode\
-------------------------------------------------------------------------------\
\
local parse\
\
local function create_set(...)\
  local res = {}\
  for i = 1, select(\"#\", ...) do\
    res[ select(i, ...) ] = true\
  end\
  return res\
end\
\
local space_chars   = create_set(\" \", \"\\t\", \"\\r\", \"\\n\")\
local delim_chars   = create_set(\" \", \"\\t\", \"\\r\", \"\\n\", \"]\", \"}\", \",\")\
local escape_chars  = create_set(\"\\\\\", \"/\", '\"', \"b\", \"f\", \"n\", \"r\", \"t\", \"u\")\
local literals      = create_set(\"true\", \"false\", \"null\")\
\
local literal_map = {\
  [ \"true\"  ] = true,\
  [ \"false\" ] = false,\
  [ \"null\"  ] = nil,\
}\
\
\
local function next_char(str, idx, set, negate)\
  for i = idx, #str do\
    if set[str:sub(i, i)] ~= negate then\
      return i\
    end\
  end\
  return #str + 1\
end\
\
\
local function decode_error(str, idx, msg)\
  local line_count = 1\
  local col_count = 1\
  for i = 1, idx - 1 do\
    col_count = col_count + 1\
    if str:sub(i, i) == \"\\n\" then\
      line_count = line_count + 1\
      col_count = 1\
    end\
  end\
  error( string.format(\"%s at line %d col %d\", msg, line_count, col_count) )\
end\
\
\
local function codepoint_to_utf8(n)\
  -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa\
  local f = math.floor\
  if n <= 0x7f then\
    return string.char(n)\
  elseif n <= 0x7ff then\
    return string.char(f(n / 64) + 192, n % 64 + 128)\
  elseif n <= 0xffff then\
    return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)\
  elseif n <= 0x10ffff then\
    return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,\
                       f(n % 4096 / 64) + 128, n % 64 + 128)\
  end\
  error( string.format(\"invalid unicode codepoint '%x'\", n) )\
end\
\
\
local function parse_unicode_escape(s)\
  local n1 = tonumber( s:sub(3, 6),  16 )\
  local n2 = tonumber( s:sub(9, 12), 16 )\
  -- Surrogate pair?\
  if n2 then\
    return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)\
  else\
    return codepoint_to_utf8(n1)\
  end\
end\
\
\
local function parse_string(str, i)\
  local has_unicode_escape = false\
  local has_surrogate_escape = false\
  local has_escape = false\
  local last\
  for j = i + 1, #str do\
    local x = str:byte(j)\
\
    if x < 32 then\
      decode_error(str, j, \"control character in string\")\
    end\
\
    if last == 92 then -- \"\\\\\" (escape char)\
      if x == 117 then -- \"u\" (unicode escape sequence)\
        local hex = str:sub(j + 1, j + 5)\
        if not hex:find(\"%x%x%x%x\") then\
          decode_error(str, j, \"invalid unicode escape in string\")\
        end\
        if hex:find(\"^[dD][89aAbB]\") then\
          has_surrogate_escape = true\
        else\
          has_unicode_escape = true\
        end\
      else\
        local c = string.char(x)\
        if not escape_chars[c] then\
          decode_error(str, j, \"invalid escape char '\" .. c .. \"' in string\")\
        end\
        has_escape = true\
      end\
      last = nil\
\
    elseif x == 34 then -- '\"' (end of string)\
      local s = str:sub(i + 1, j - 1)\
      if has_surrogate_escape then\
        s = s:gsub(\"\\\\u[dD][89aAbB]..\\\\u....\", parse_unicode_escape)\
      end\
      if has_unicode_escape then\
        s = s:gsub(\"\\\\u....\", parse_unicode_escape)\
      end\
      if has_escape then\
        s = s:gsub(\"\\\\.\", escape_char_map_inv)\
      end\
      return s, j + 1\
\
    else\
      last = x\
    end\
  end\
  decode_error(str, i, \"expected closing quote for string\")\
end\
\
\
local function parse_number(str, i)\
  local x = next_char(str, i, delim_chars)\
  local s = str:sub(i, x - 1)\
  local n = tonumber(s)\
  if not n then\
    decode_error(str, i, \"invalid number '\" .. s .. \"'\")\
  end\
  return n, x\
end\
\
\
local function parse_literal(str, i)\
  local x = next_char(str, i, delim_chars)\
  local word = str:sub(i, x - 1)\
  if not literals[word] then\
    decode_error(str, i, \"invalid literal '\" .. word .. \"'\")\
  end\
  return literal_map[word], x\
end\
\
\
local function parse_array(str, i)\
  local res = {}\
  local n = 1\
  i = i + 1\
  while 1 do\
    local x\
    i = next_char(str, i, space_chars, true)\
    -- Empty / end of array?\
    if str:sub(i, i) == \"]\" then\
      i = i + 1\
      break\
    end\
    -- Read token\
    x, i = parse(str, i)\
    res[n] = x\
    n = n + 1\
    -- Next token\
    i = next_char(str, i, space_chars, true)\
    local chr = str:sub(i, i)\
    i = i + 1\
    if chr == \"]\" then break end\
    if chr ~= \",\" then decode_error(str, i, \"expected ']' or ','\") end\
  end\
  return res, i\
end\
\
\
local function parse_object(str, i)\
  local res = {}\
  i = i + 1\
  while 1 do\
    local key, val\
    i = next_char(str, i, space_chars, true)\
    -- Empty / end of object?\
    if str:sub(i, i) == \"}\" then\
      i = i + 1\
      break\
    end\
    -- Read key\
    if str:sub(i, i) ~= '\"' then\
      decode_error(str, i, \"expected string for key\")\
    end\
    key, i = parse(str, i)\
    -- Read ':' delimiter\
    i = next_char(str, i, space_chars, true)\
    if str:sub(i, i) ~= \":\" then\
      decode_error(str, i, \"expected ':' after key\")\
    end\
    i = next_char(str, i + 1, space_chars, true)\
    -- Read value\
    val, i = parse(str, i)\
    -- Set\
    res[key] = val\
    -- Next token\
    i = next_char(str, i, space_chars, true)\
    local chr = str:sub(i, i)\
    i = i + 1\
    if chr == \"}\" then break end\
    if chr ~= \",\" then decode_error(str, i, \"expected '}' or ','\") end\
  end\
  return res, i\
end\
\
\
local char_func_map = {\
  [ '\"' ] = parse_string,\
  [ \"0\" ] = parse_number,\
  [ \"1\" ] = parse_number,\
  [ \"2\" ] = parse_number,\
  [ \"3\" ] = parse_number,\
  [ \"4\" ] = parse_number,\
  [ \"5\" ] = parse_number,\
  [ \"6\" ] = parse_number,\
  [ \"7\" ] = parse_number,\
  [ \"8\" ] = parse_number,\
  [ \"9\" ] = parse_number,\
  [ \"-\" ] = parse_number,\
  [ \"t\" ] = parse_literal,\
  [ \"f\" ] = parse_literal,\
  [ \"n\" ] = parse_literal,\
  [ \"[\" ] = parse_array,\
  [ \"{\" ] = parse_object,\
}\
\
\
parse = function(str, idx)\
  local chr = str:sub(idx, idx)\
  local f = char_func_map[chr]\
  if f then\
    return f(str, idx)\
  end\
  decode_error(str, idx, \"unexpected character '\" .. chr .. \"'\")\
end\
\
\
function exports.decode(str)\
  if type(str) ~= \"string\" then\
    error(\"expected argument of type string, got \" .. type(str))\
  end\
  local res, idx = parse(str, next_char(str, 1, space_chars, true))\
  idx = next_char(str, idx, space_chars, true)\
  if idx <= #str then\
    decode_error(str, idx, \"trailing garbage\")\
  end\
  return res\
end",
}, ...)