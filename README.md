# Scripting Package - pierrelasse/lib

Various rather small libraries.

### [pierrelasse/lib/integration/luckperms](./@pierrelasse/lib/integration/luckperms.lua)

Access the [LuckPerms API](https://luckperms.net/wiki/Developer-API-Usage).

**Example:**

```lua
local luckperms = require("@pierrelasse/lib/integration/luckperms")


local player = bukkit.player("example")

local prefix = luckperms.getPrefix(player) or ""
local suffix = luckperms.getSuffix(player) or ""

-- Set using:
-- - /lp user <user> meta set custom-value <value>
-- - /lp group <group> meta set custom-value <value>
local customValue = luckperms.getMetaValue(player, "custom-value")

-- & more
```

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

### [pierrelasse/lib/complete](./@pierrelasse/lib/complete.lua)

Command tab completer.

**Example:**

```lua
commands.add("example", function (sender, args) end)
    .complete(function (completions, sender, args)
        complete(completions, args[1],
            bukkit.playersLoop(), -- iterator
            function (i) return i.getName() end -- mapper
        )
    end)
```

### [pierrelasse/lib/discordWebhook](./@pierrelasse/lib/discordWebhook.lua)

Send messages and/or embeds to a Discord channel using a webhook.

**Example:**

```lua
local WEBHOOK_ID, WEBHOOK_TOKEN = "123456789012345678", "c29tZSBjb29sIHRva2VuIHlheQo"

discordWebhook.send(WEBHOOK_ID, WEBHOOK_TOKEN, {
    content = "Hello from Scripting!",
    embeds = {{
        title = "Test Embed",
        description = "This is a sample message.",
        color = 0x00ff00
    }}
})
```

### [pierrelasse/lib/http](./@pierrelasse/lib/http.lua)

Simple HTTP requests.

### [pierrelasse/lib/SimpleCooldowns](./@pierrelasse/lib/SimpleCooldowns.lua)

Manages cooldown timers.

**Example:**

```lua
local cooldowns = SimpleCooldowns.new()

-- set cooldown 'ability1' for 'user1' to 10 seconds
cooldowns:set("user1", "ability1", 10)


if cd:checkOrSet("player1", "ability1", 10) then
    print("Still on cooldown!")
else
    print("Ability used!")
end


print("Remaining: ", cd:getRemaining("player1", "ability1"))
```

### [pierrelasse/lib/smallCaps](./@pierrelasse/lib/smallCaps.lua)

Converts "example" to "ᴇxᴀᴍᴘʟᴇ".

### [pierrelasse/lib/trueDamage](./@pierrelasse/lib/trueDamage.lua)

Damage entities bypassing damage modifiers like armor.
