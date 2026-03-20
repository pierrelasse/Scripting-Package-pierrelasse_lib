---@class pierrelasse.lib.AttributeModifier
---@field attribute bukkit.attribute.Attribute
---@field modifier bukkit.attribute.AttributeModifier
local this = {}
this.__index = this

---@param attribute bukkit.attribute.AttributeLike
---@param key bukkit.NamespacedKeyLike
---@param amount number
---@param operation bukkit.attribute.AttributeModifierOperation*|bukkit.attribute.AttributeModifierOperation
---@param slot? bukkit.inventory.EquipmentSlotGroup*|bukkit.inventory.EquipmentSlotGroup
function this.new(attribute, key, amount, operation, slot)
    return setmetatable({
        attribute = bukkit.attribute(attribute) or error(),
        modifier = bukkit.attributes.modifier(key, amount, operation, slot)
    }, this)
end

---@param player bukkit.entity.Player
function this:has(player)
    local attr = player.getAttribute(self.attribute)
    if attr == nil then return false end

    local key = self.modifier.getKey()
    for mod in forEach(attr.getModifiers()) do
        if mod.getKey() == key then
            return true
        end
    end

    return false
end

---@param player bukkit.entity.Player
function this:remove(player)
    local attr = player.getAttribute(self.attribute)
    if attr == nil then return end

    local key = self.modifier.getKey()
    for mod in forEach(attr.getModifiers()) do
        if mod.getKey() == key then
            attr.removeModifier(mod)
        end
    end
end

---@param player bukkit.entity.Player
function this:add(player)
    local attr = player.getAttribute(self.attribute)
    if attr == nil then return end

    if self:has(player) then return end
    attr.addModifier(self.modifier)
end

---@param player bukkit.entity.Player
function this:readd(player)
    self:remove(player)
    self:add(player)
end

return this
