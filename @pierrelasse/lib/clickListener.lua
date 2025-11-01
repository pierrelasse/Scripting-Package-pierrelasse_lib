local PlayerInteractEvent = import("org.bukkit.event.player.PlayerInteractEvent")


---@class pierrelasse.lib.clickListener.Event
---@field event java.Object
---@field player bukkit.entity.Player
---@field itemStack bukkit.ItemStack?
---@field button "left"|"right"
---@field at "block"|"air"
---@field hand "hand"|"offhand"
---@field private item bukkit.ItemStack?

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
---@param action any
local function trigger(event, action)
    ---@type pierrelasse.lib.clickListener.Event
    local ev = {
        event = event,
        player = event.getPlayer(),
        itemStack = event.getItem(),
        button = (action == "LEFT_CLICK_AIR" or action == "LEFT_CLICK_BLOCK") and "left" or "right",
        at = (action == "LEFT_CLICK_AIR" or action == "RIGHT_CLICK_AIR") and "air" or "block",
        hand = event.getHand().name() == "OFF_HAND" and "offhand" or "hand",
        item = event.getItem(), -- TODO
    }

    for listener in forEach(this.listeners) do
        if listener(ev) == true then break end
    end
end

events.onStarted(function()
    events.listen(PlayerInteractEvent, function(event)
        if not event.isCancelled() then return end

        local action = event.getAction().name()
        if action ~= "LEFT_CLICK_AIR" and action ~= "RIGHT_CLICK_AIR" then return end

        trigger(event, action)
    end)
    .priority("HIGH")
    .ignoreCancelled = true

    events.listen(PlayerInteractEvent, function(event)
        local action = event.getAction().name()
        if action ~= "LEFT_CLICK_BLOCK" and action ~= "RIGHT_CLICK_BLOCK" then return end

        trigger(event, action)
    end)
end)

return this
