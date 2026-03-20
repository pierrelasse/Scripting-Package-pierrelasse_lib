---@class pierrelasse.lib.EntityMetadata<T> : {
---  get: fun(self: self, entity: bukkit.Entity): T?;
---  set: fun(self: self, entity: bukkit.Entity, value: T?);
---}
---@field key string
local this = {}
this.__index = this

---@generic T
---@param key string|bukkit.NamespacedKeyLike
---@return pierrelasse.lib.EntityMetadata
function this.new(key)
    if type(key) ~= "string" then
        key = bukkit.nsk(key)
        key = key.asString()
    end
    local self = setmetatable({ key = key }, this)
    return self
end

---@param entity bukkit.Entity
function this:get(entity)
    return bukkit.getEntityMetadata(entity, self.key)
end

---@param entity bukkit.Entity
function this:set(entity, value)
    if value == nil then
        bukkit.removeEntityMetadata(entity, self.key)
    else
        bukkit.setEntityMetadata(entity, self.key, value)
    end
end

return this
