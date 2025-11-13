local EntityDamageEvent = import("org.bukkit.event.entity.EntityDamageEvent")
local EntityDamageEvent_DamageModifier = import("org.bukkit.event.entity.EntityDamageEvent$DamageModifier")


events.onStarted(function()
    events.listen(EntityDamageEvent, function(event)
        local entity = event.getEntity()
        local amount = bukkit.getEntityMetadata(entity, "trueDamage")
        if amount == nil then return end
        bukkit.removeEntityMetadata(entity, "trueDamage")

        if bukkit.isLivingEntity(entity) then
            if event.getDamage(EntityDamageEvent_DamageModifier.ARMOR) ~= nil then
                event.setDamage(EntityDamageEvent_DamageModifier.ARMOR, 0)
            end
            if event.getDamage(EntityDamageEvent_DamageModifier.MAGIC) ~= nil then
                event.setDamage(EntityDamageEvent_DamageModifier.MAGIC, 0)
            end
            if event.getDamage(EntityDamageEvent_DamageModifier.RESISTANCE) ~= nil then
                event.setDamage(EntityDamageEvent_DamageModifier.RESISTANCE, 0)
            end
        end

        event.setDamage(amount)
    end)
end)

---Deals the given amount of damage to the target entity.
---@param entity bukkit.entity.Damageable
---@param amount number
---@param source? bukkit.Entity|java.Object org.bukkit.damage.DamageSource
return function(entity, amount, source)
    bukkit.setEntityMetadata(entity, "trueDamage", amount)
    bukkit.damage(entity, amount, source)
end
