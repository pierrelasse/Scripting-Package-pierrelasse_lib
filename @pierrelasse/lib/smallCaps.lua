local StringBuilder = import("java.lang.StringBuilder")


local lookup = arrayOf(
    "ᴀ", "ʙ", "ᴄ", "ᴅ", "ᴇ", "ꜰ", "ɢ", "ʜ", "ɪ",
    "ᴊ", "ᴋ", "ʟ", "ᴍ", "ɴ", "ᴏ", "ᴘ", "q", "ʀ",
    "s", "ᴛ", "ᴜ", "ᴠ", "ᴡ", "x", "ʏ", "ᴢ")

---@param s string
local function smallCaps(s)
    local sb = StringBuilder(#s)
    for i = 1, #s do
        local c = s:byte(i)
        if c >= 65 and c <= 90 then c = c + 32 end -- uppercase to lowercase ascii
        local idx = c - 96                         -- 'a' = 97, so 'a'->1
        local ch = (idx >= 1 and idx <= #lookup) and lookup[idx] or string.char(c)
        sb.append(ch)
    end
    return sb.toString()
end

return smallCaps
