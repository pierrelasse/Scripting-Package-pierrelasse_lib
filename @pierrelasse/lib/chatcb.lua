local AsyncPlayerChatEvent = import("org.bukkit.event.player.AsyncPlayerChatEvent")


---@class pierrelasse.lib.chatcb.Callback
---@field cancel? fun(): boolean?
---@field timeout? fun()
---@field timeoutTask? ScriptTask
---@field accept fun(message: string): boolean?

local this = {}

---@package
---@type java.Map<string, pierrelasse.lib.chatcb.Callback>
this.callbacks = java.map()

---@param playerId string
function this.get(playerId)
    return this.callbacks.get(playerId)
end

---@param playerId string
function this.has(playerId)
    return this.callbacks.containsKey(playerId)
end

---@param playerId string
function this.clear(playerId)
    local cb = this.callbacks.remove(playerId)
    if cb.timeoutTask ~= nil then
        cb.timeoutTask.cancel()
    end
    return cb
end

---@param playerId string
function this.cancel(playerId)
    local cb = this.get(playerId)
    if cb ~= nil and (cb.cancel == nil and cb.cancel() ~= false) then
        this.clear(playerId)
    end
end

---@param playerId string
---@param cb pierrelasse.lib.chatcb.Callback
function this.register(playerId, cb)
    this.cancel(playerId)
    this.callbacks.put(playerId, cb)
end

---@param player bukkit.entity.Player
---@param timeout integer ticks
---@param cb pierrelasse.lib.chatcb.Callback
function this.reg(player, timeout, cb)
    local playerId = bukkit.uuid(player)
    cb.timeoutTask = tasks.wait(timeout, function()
        if cb.timeout ~= nil then cb.timeout() end
        this.clear(playerId)
    end)
    this.register(playerId, cb)
end

events.onStarted(function()
    events.listen(AsyncPlayerChatEvent, function(event)
        local player = event.getPlayer() ---@type bukkit.entity.Player
        local playerId = bukkit.uuid(player)

        local cb = this.get(playerId)
        if cb == nil then return end

        local message = event.getMessage() ---@type string

        if cb.accept(message) ~= false then
            this.clear(playerId)
        end

        event.setCancelled(true)
    end)
        .priority("LOWEST")
end)

return this
