---@alias pierrelasse.lib.integration.packetevents.Phase
---| "common"
---| "configuration"
---| "handshaking"
---| "login"
---|>"play"
---| "status"

---@alias pierrelasse.lib.integration.packetevents.Direction "client"|"server"

---@class pierrelasse.lib.integration.packetevents.PacketType
---@field type java.Enum
---@field wrapper fun(event: java.Object): java.Object

---@class pierrelasse.lib.integration.packetevents.PacketListener : java.Object
---@field packetReceive fun(event: java.Object)
---@field packetSend fun(event: java.Object)

---@class pierrelasse.lib.integration.packetevents.PacketEvent : java.Object
---@field getPlayer fun(): bukkit.entity.Player
---@field markForReEncode fun(v: boolean)

---@alias pierrelasse.lib.integration.packetevents.Listener fun(event: pierrelasse.lib.integration.packetevents.PacketEvent, wrapper: fun(): java.Object)

local this = {}

local PacketEvents = importOrNil("com.github.retrooper.packetevents.PacketEvents")
if PacketEvents == nil then
    scripting.warning("pierrelasse/lib/integration/packetevents:§c not available")
else
    this.api = PacketEvents.getAPI()

    local PacketListenerPriority = import("com.github.retrooper.packetevents.event.PacketListenerPriority")

    classloader.addClassFile("@pierrelasse/lib/integration/packetevents",
        "pierrelasse_lib_integration_packetevents_Listener")
    local PacketListener = import("pierrelasse_lib_integration_packetevents_Listener")

    ---@param phase pierrelasse.lib.integration.packetevents.Phase
    ---@param direction pierrelasse.lib.integration.packetevents.Direction
    ---@param name string
    function this.packetType(phase, direction, name)
        local phase1Upper = phase:at(1):upper()..phase:sub(2)
        local direction1Upper = direction:at(1):upper()..direction:sub(2)
        return import("com.github.retrooper.packetevents.protocol.packettype.PacketType$"
                ..phase1Upper.."$"..direction1Upper)
            .valueOf(name)
    end

    ---@package
    ---@type java.Map<java.Object, java.List<pierrelasse.lib.integration.packetevents.Listener>>
    this.listenersReceive = java.map()
    ---@package
    ---@type java.Map<java.Object, java.List<pierrelasse.lib.integration.packetevents.Listener>>
    this.listenersSend = java.map()

    local packetListener = PacketListener(PacketListenerPriority.NORMAL)
    events.onStopping(function()
        this.api
            .getEventManager()
            .unregisterListener(packetListener.common)
    end)
    this.api
        .getEventManager()
        .registerListener(packetListener.common)

    do
        local wrapperConstructorParams = java.arrayOf(import(
            "com.github.retrooper.packetevents.event.PacketReceiveEvent"))
        packetListener.packetReceive = function(event)
            local pt = event.getPacketType() ---@type java.Object

            local listeners = this.listenersReceive.get(pt)
            if listeners == nil then return end

            local wrapperClass = pt.getWrapperClass()
            local newWrapper
            if wrapperClass then
                newWrapper = wrapperClass
                    .getDeclaredConstructor(wrapperConstructorParams)
                    .newInstance
            end
            local function wrapper() return newWrapper(java.array(nil, 1, event)) end

            for listener in forEach(listeners) do
                listener(event, wrapper)
            end
        end
    end
    do
        local wrapperConstructorParams = java.arrayOf(import("com.github.retrooper.packetevents.event.PacketSendEvent"))
        packetListener.packetSend = function(event)
            local pt = event.getPacketType() ---@type java.Object

            local listeners = this.listenersSend.get(pt)
            if listeners == nil then return end

            local wrapperClass = pt.getWrapperClass()
            local newWrapper
            if wrapperClass then
                newWrapper = wrapperClass
                    .getDeclaredConstructor(wrapperConstructorParams)
                    .newInstance
            end
            local function wrapper() return newWrapper(java.array(nil, 1, event)) end

            for listener in forEach(listeners) do
                listener(event, wrapper)
            end
        end
    end

    ---- [Packet Types](https://github.com/retrooper/packetevents/blob/2.0/api/src/main/java/com/github/retrooper/packetevents/protocol/packettype/PacketType.java)
    ---@param phase pierrelasse.lib.integration.packetevents.Phase
    ---@param direction pierrelasse.lib.integration.packetevents.Direction
    ---@param name string
    ---@param cb pierrelasse.lib.integration.packetevents.Listener
    ---@param priority? java.Object WIP
    function this.listen(phase, direction, name, cb, priority)
        local pt = this.packetType(phase, direction, name)

        java.mapComputeIfAbsent(direction == "client" and this.listenersReceive or this.listenersSend,
            pt, function() return java.list(1) end)
            .add(cb)
    end
end

return this
