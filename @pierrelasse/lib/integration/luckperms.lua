local LuckPermsProvider = importOrNil("net.luckperms.api.LuckPermsProvider")


---@alias pierrelasse.lib.integration.luckperms.UserId java.UUID|string|bukkit.entity.Player

---```
---paman.need("pierrelasse/lib/luckperms")
---```
---<br>
---This package provides a simple interface to the LuckPerms API,<br>
---allowing you to manage player metadata such as prefixes and suffixes.<br>
---<br>
---**Example:**
---```lua
---local luckperms = require("@pierrelasse/lib/luckperms")
---
---
---local player = bukkit.getPlayer("playerName")
---
---local prefix = luckperms.getPrefix(player)
---local suffix = luckperms.getSuffix(player)
---```
local this = {}

---The LuckPerms provider.
---@type java.Object?
this.prov = LuckPermsProvider ~= nil and LuckPermsProvider.get() or nil
if this.prov == nil then
    scripting.warning("pierrelasse/lib/integration/luckperms: not available")
end

this.unavailable = this.prov == nil

---@protected
function this.isPlayer(o)
    if bukkit ~= nil then
        return bukkit.isPlayer(o)
        ---@diagnostic disable-next-line: undefined-global
    elseif velocity ~= nil then
        ---@diagnostic disable-next-line: undefined-global
        return velocity.isPlayer(o)
    else
        return false
    end
end

---@protected
---@param userId pierrelasse.lib.integration.luckperms.UserId
---@return java.Object
function this.uuidFromUserId(userId)
    if this.isPlayer(userId) then return userId.getUniqueId() end
    if type(userId) == "string" then return java.uuidFromString(userId) or error() end
    return userId
end

---#region UserManager

---@protected
---@return java.Object?
function this.getUserManager()
    return this.prov and this.prov.getUserManager()
end

---@param userId pierrelasse.lib.integration.luckperms.UserId
---@return java.Object?
function this.getUser(userId)
    local userManager = this.getUserManager()
    return userManager and userManager.getUser(this.uuidFromUserId(userId))
end

---@param user java.Object
function this.saveUser(user)
    local userManager = this.getUserManager()
    return userManager and userManager.saveUser(user)
end

---@param userId pierrelasse.lib.integration.luckperms.UserId
---@return java.Object?
function this.getMetaData(userId)
    local user = this.getUser(userId)
    return user and user.getCachedData().getMetaData() -- MetaDataType.INHERITED
end

---@param userId pierrelasse.lib.integration.luckperms.UserId
---@param key string
---@return string?
function this.getMetaValue(userId, key)
    local metaData = this.getMetaData(userId)
    return metaData and metaData.getMetaValue(key)
end

---@param userId pierrelasse.lib.integration.luckperms.UserId
---@return string?
function this.getPrefix(userId)
    local metaData = this.getMetaData(userId)
    return metaData and metaData.getPrefix()
end

---@param userId pierrelasse.lib.integration.luckperms.UserId
---@return string?
function this.getSuffix(userId)
    local metaData = this.getMetaData(userId)
    return metaData and metaData.getSuffix()
end

---@param userId pierrelasse.lib.integration.luckperms.UserId
---@param default? integer=`0`
---@return integer
function this.getWeight(userId, default)
    if default == nil then default = 0 end
    local metaData = this.getMetaData(userId)
    if metaData == nil then return default end
    return metaData.getWeight() or default
end

--#endregion

--#region GroupManager

---@protected
---@return java.Object?
function this.getGroupManager()
    return this.prov and this.prov.getGroupManager()
end

---@param id string
---@return java.Object?
function this.getGroup(id)
    local groupManager = this.getGroupManager()
    return groupManager and groupManager.getGroup(id)
end

--#endregion

return this
