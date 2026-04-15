local Projectile = import("org.bukkit.entity.Projectile")
local EntityDamageEvent = import("org.bukkit.event.entity.EntityDamageEvent")
local EntityDamageByEntityEvent = import("org.bukkit.event.entity.EntityDamageByEntityEvent")


---@alias pierrelasse.lib.damageListeners.Event.Cause
---| "custom"
---| "kill" # Damage caused by /kill command. Damage: {@link Float#MAX_VALUE}
---| "world_border" # Damage caused by the World Border. Damage: {@link WorldBorder#getDamageAmount()} <!-- todo not accurate -->
---| "contact" # Damage caused when an entity contacts a block such as a Cactus, Dripstone (Stalagmite) or Berry Bush.
---| "entity_attack" # Damage caused when an entity attacks another entity.
---| "entity_sweep_attack" # Damage caused when an entity attacks another entity in a sweep attack.
---| "projectile" # Damage caused when attacked by a projectile.
---| "suffocation" # Damage caused by being put in a block. Damage: 1
---| "fall" # Damage caused when an entity falls a distance greater than the {@link org.bukkit.attribute.Attribute#SAFE_FALL_DISTANCE safe fall distance}. Damage: fall height
---| "fire" # Damage caused by direct exposure to fire. Damage: 1 or 2 (for soul fire)
---| "fire_tick" # Damage caused due to burns caused by fire. Damage: 1
---| "melting" # Damage caused due to a snowman melting. Damage: 1
---| "lava" # Damage caused by direct exposure to lava. Damage: 4
---| "drowning" # Damage caused by running out of air while in water. Damage: 1 or 2
---| "block_explosion" # Damage caused by being in the area when a block explodes.
---| "entity_explosion" # Damage caused by being in the area when an entity, such as a Creeper, explodes.
---| "void" # Damage caused by falling into the void. Damage: {@link org.bukkit.World#getVoidDamageAmount()}
---| "lightning" # Damage caused by being struck by lightning. Damage: 5 or {@link Float#MAX_VALUE} for turtle
---| "suicide" # Damage caused by committing suicide.
---| "starvation" # Damage caused by starving due to having an empty hunger bar. Damage: 1
---| "poison" # Damage caused due to an ongoing poison effect. Damage: 1
---| "magic" # Damage caused by being hit by a damage potion or spell.
---| "wither" # Damage caused by Wither potion effect
---| "falling_block" # Damage caused by being hit by a falling block which deals damage.
---| "thorns" # Damage caused in retaliation to another attack by the thorns enchantment or guardian. Damage: 1-5 (thorns) or 2 (guardian)
---| "fly_into_wall" # Damage caused when an entity runs into a wall.
---| "hot_floor" # Damage caused when an entity steps on {@link Material#MAGMA_BLOCK}. Damage: 1
---| "campfire" # Damage caused when an entity steps on {@link Material#CAMPFIRE} or {@link Material#SOUL_CAMPFIRE}. Damage: 1 or 2 (for soul fire)
---| "cramming" # Damage caused when an entity is colliding with too many entities
---| "dryout" # Damage caused when an entity that should be in water is not. Damage: 1 or 2
---| "freeze" # Damage caused from freezing. Damage: 1 or 5 (for {@link org.bukkit.Tag#ENTITY_TYPES_FREEZE_HURTS_EXTRA_TYPES sensitive} entities)
---| "sonic_boom" # Damage caused by the Sonic Boom attack from {@link org.bukkit.entity.Warden}. Damage: 10

---@class pierrelasse.lib.damageListeners.Event
---@field cancelled? true
---
---@field entity bukkit.entity.Damageable damaged entity
---@field player? bukkit.entity.Player damaged entity if a Player
---@field itemStack? bukkit.ItemStack
---
---@field damage number
---@field finalDamage number
---@field isDeadly boolean
---@field cause pierrelasse.lib.damageListeners.Event.Cause
---
---@field damager? bukkit.Entity
---@field attacker? bukkit.Entity ie. projectile shooter

---@alias pierrelasse.lib.damageListeners.Listener fun(event: pierrelasse.lib.damageListeners.Event): nil|boolean

local this = {}

---@type java.List<pierrelasse.lib.damageListeners.Listener>
this.listeners = java.list()

---@param listener pierrelasse.lib.damageListeners.Listener
function this.add(listener)
    this.listeners.add(listener)
    return listener
end

---@param listener pierrelasse.lib.damageListeners.Listener
function this.remove(listener)
    return this.listeners.remove(listener)
end

---@param event pierrelasse.lib.damageListeners.Event
function this.emit(event)
    for listener in forEach(this.listeners) do
        if listener(event) == true then return true end
    end
end

events.onStarted(function()
    events.listen(EntityDamageEvent, function(event)
        -- TODO
        if event.getClass() == EntityDamageByEntityEvent.class then return end

        local entity = event.getEntity() ---@type bukkit.entity.Damageable

        local damage = event.getDamage()
        local finalDamage = event.getFinalDamage()

        ---@type pierrelasse.lib.damageListeners.Event
        local ev = {
            entity = entity,
            player = bukkit.isPlayer(entity) ---@cast entity bukkit.entity.Player
                and entity or nil,

            damage = damage,
            finalDamage = finalDamage,
            isDeadly = bukkit.isLivingEntity(entity)
                and finalDamage >= entity.getHealth()
                or true,
            cause = event.getCause().toString():lower()
        }
        this.emit(ev)
        if ev.cancelled then event.setCancelled(true) end
        if ev.damage ~= damage then event.setDamage(ev.damage) end
    end)

    events.listen(EntityDamageByEntityEvent, function(event)
        if event.getClass() ~= EntityDamageByEntityEvent.class then return end

        local entity = event.getEntity() ---@type bukkit.entity.Damageable

        local damager = event.getDamager() ---@type bukkit.Entity
        local attacker ---@type bukkit.Entity?
        if instanceof(damager, Projectile) then ---@cast damager bukkit.entity.Projectile
            local shooter = damager.getShooter()
            if bukkit.isEntity(shooter) then ---@cast shooter unknown
                attacker = shooter
            end
        end

        local damage = event.getDamage()
        local finalDamage = event.getFinalDamage()

        ---@type pierrelasse.lib.damageListeners.Event
        local ev = {
            entity = entity,
            player = bukkit.isPlayer(entity) ---@cast entity bukkit.entity.Player
                and entity or nil,

            damage = damage,
            finalDamage = finalDamage,
            isDeadly = finalDamage >= entity.getHealth(),
            cause = event.getCause().toString():lower(),

            damager = damager,
            attacker = attacker
        }
        this.emit(ev)
        if ev.cancelled then event.setCancelled(true) end
        if ev.damage ~= damage then event.setDamage(ev.damage) end
    end)
end)

return this
