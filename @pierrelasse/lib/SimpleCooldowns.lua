---```lua
---paman.need("pierrelasse/lib/SimpleCooldowns")
---```
---
---@class pierrelasse.lib.SimpleCooldowns
---@field data java.Map<string, java.Map<string, number>>
---@field task? ScriptTask
local this = {}
this.__index = this

---@return pierrelasse.lib.SimpleCooldowns
function this.new()
    local self = setmetatable({}, this)

    self.data = java.map()

    return self
end

---@package
---@return integer
function this:now()
    return time.unixMs()
end

---@protected
function this:updateTask()
    if self.data.isEmpty() then
        if self.task ~= nil then
            self.task.cancel()
            self.task = nil
        end
    elseif self.task == nil then
        self.task = every(20 * 8, function()
            self:cleanup()
        end)
    end
end

---@protected
function this:cleanup()
    local now = self:now()

    local usersItr = self.data.values().iterator() ---@type java.Iterator<java.Map<string, number>>
    while usersItr.hasNext() do
        local map = usersItr.next()

        local mapItr = map.values().iterator() ---@type java.Iterator<number>
        while mapItr.hasNext() do
            if mapItr.next() < now then
                mapItr.remove()
            end
        end

        if map.isEmpty() then
            usersItr.remove()
        end
    end

    self:updateTask()
end

---@protected
---@param id string
function this:getDataOrCreate(id)
    local map = self.data.get(id)
    if map == nil then
        map = java.map()
        self.data.put(id, map)
    end
    return map
end

---@param id string
---@param key string
---@param duration number seconds
---@param threshold? number seconds
---@return boolean # if the cooldown is active
function this:checkOrSet(id, key, duration, threshold)
    if self:isActive(id, key, threshold) then return true end
    self:set(id, key, duration)
    return false
end

---@param id string
---@param key string
---@param duration number seconds
---@param threshold? number seconds
---@return boolean # if the cooldown is active
function this:checkOrAdd(id, key, duration, threshold)
    if self:isActive(id, key, threshold) then return true end
    self:add(id, key, duration)
    return false
end

---@param id string
---@param key string
---@param duration number seconds
---@param threshold? number seconds
---@return boolean # if the cooldown is active
function this:checkAndAdd(id, key, duration, threshold)
    local active = self:isActive(id, key, threshold)
    self:add(id, key, duration)
    return active
end

---@param id string
---@param key string
---@param duration number seconds
function this:set(id, key, duration)
    local map = self:getDataOrCreate(id)
    map.put(key, self:now() + (duration * 1000))

    self:updateTask()
end

---@param id string
---@param key string
---@param duration number seconds
function this:add(id, key, duration)
    local map = self:getDataOrCreate(id)
    local v = math.max(map.get(key) or 0, self:now()) + (duration * 1000)
    map.put(key, v)

    self:updateTask()
end

---@param id string
---@param key string
---@param threshold? number seconds
---@return boolean
function this:isActive(id, key, threshold)
    local map = self.data.get(id)
    if map == nil then return false end
    local t = map.get(key)
    if t == nil then return false end
    if threshold == nil then threshold = 0 end
    return t > (self:now() + (threshold * 1000))
end

---@param id string
---@param key string
---@return number
function this:getRemaining(id, key)
    local map = self.data.get(id)
    if map == nil then return 0 end
    local t = map.get(key)
    if t == nil then return 0 end
    return math.max(0, t - self:now()) / 1000
end

---@param id string
---@param key string
function this:clear(id, key)
    local map = self.data.get(id)
    if map == nil then return end
    map.remove(key)
    if map.isEmpty() then
        self.data.remove(id)
    end

    self:updateTask()
end

---@param id string
function this:clearAll(id)
    self.data.remove(id)

    self:updateTask()
end

return this
