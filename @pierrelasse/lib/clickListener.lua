local PlayerInteractEvent = import("org.bukkit.event.player.PlayerInteractEvent")
local PlayerInteractEntityEvent = import("org.bukkit.event.player.PlayerInteractEntityEvent")


---@class pierrelasse.lib.clickListener.Event
---@field event java.Object
---
---@field player bukkit.entity.Player
---@field hand "hand"|"offhand"
---@field button "left"|"right"
---@field at "air"|"block"|"entity"
---
---@field itemStack bukkit.ItemStack?
---@field private item bukkit.ItemStack?
---
---@field block? bukkit.block.Block
---@field blockFace? bukkit.block.BlockFace
---
---@field entity? bukkit.Entity

---@alias pierrelasse.lib.clickListener.Listener fun(event: pierrelasse.lib.clickListener.Event): boolean?

---```
---paman.need("pierrelasse/lib/clickListener")
---```
local this = {}

---@type java.List<pierrelasse.lib.clickListener.Listener>
this.listeners = java.list()

---@param handler pierrelasse.lib.clickListener.Listener
function this.listen(handler)
    this.listeners.add(handler)
end

---@param event java.Object
---@param action string
local function trigger(event, action)
    local ev = {
        event = event,

        player = event.player,
    }
    ---@cast ev pierrelasse.lib.clickListener.Event

    ev.hand = event.hand.name() == "HAND" and "hand" or "offhand"

    if instanceof(event, PlayerInteractEvent) then
        ev.button = action:startsWith("LEFT_CLICK") and "left" or "right"

        ev.block = event.getClickedBlock()
        if ev.block ~= nil then
            ev.at = "block"
            ev.blockFace = event.getBlockFace()
        else
            ev.at = "air"
        end

        ev.itemStack = event.item
        -- TODO
        ---@diagnostic disable-next-line: invisible
        ev.item = ev.itemStack
    elseif instanceof(event, PlayerInteractEntityEvent) then
        ev.at = "entity"
        ev.button = "right"
        ev.entity = event.getRightClicked()
    end

    for listener in forEach(this.listeners) do
        if listener(ev) == true then break end
    end
end

events.onStarted(function()
    events.listen(PlayerInteractEvent, function(event)
        if not event.isCancelled() then return end
        local action = event.getAction().name()
        if action:endsWith("AIR") then
            trigger(event, action)
        end
    end)
    .priority("HIGH")
    .ignoreCancelled = true

    events.listen(PlayerInteractEvent, function(event)
        local action = event.getAction().name()
        if action:endsWith("BLOCK") then
            trigger(event, action)
        end
    end)

    events.listen(PlayerInteractEntityEvent, function(event)
        if not instanceof(event, PlayerInteractEntityEvent, true) then return end -- TODO
        trigger(event, "ENTITY")
    end)
end)

return this
