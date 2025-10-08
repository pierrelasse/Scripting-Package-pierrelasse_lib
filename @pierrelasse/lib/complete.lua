---@generic T
---@param completions java.List<string>
---@param arg nil|string
---@param iterator (fun(): T)|T[]
---@param mapper nil|(fun(i: T): nil|string)
local function complete(completions, arg, iterator, mapper)
    local input = arg and arg:lower() or nil
    if type(iterator) == "table" then iterator = table.valuesLoop(iterator) end
    for item in iterator do
        local value = tostring(mapper and mapper(item) or item)
        if value ~= nil and (input == nil or value:lower():startsWith(input)) then
            completions.add(value)
        end
    end
end

return complete
