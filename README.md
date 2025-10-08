# Scripting Package - pierrelasse/lib

Various rather small libraries.

### [pierrelasse/lib/chatcb](./@pierrelasse/lib/chatcb.lua)

Simple callbacks for players sending chat messages.

**Example:**

```lua
local player ---@type bukkit.entity.Player
local timeout = 20 * 4 -- 4 seconds

chatcb.reg(player, timeout, {
    accept = function(message)
        if message ~= "123" then
            bukkit.send(player, "Please say 123!")
            return false
        end

        bukkit.send(player, "Success!")
    end,
    timeout = function()
        bukkit.send(player, "You didn't say 123 within 4 seconds!")
    end
})
```

### [pierrelasse/lib/clickListener](./@pierrelasse/lib/clickListener.lua)

Simplifies detecting and handling player click interactions.

**Example:**

```lua
clickListener.listen(function(event)
    if event.button == "right" and event.at == "block" then
        bukkit.send(event.player, "You right-clicked a block!")
    end
end)
```

### [pierrelasse/lib/http](./@pierrelasse/lib/http.lua)

Simple HTTP requests.
