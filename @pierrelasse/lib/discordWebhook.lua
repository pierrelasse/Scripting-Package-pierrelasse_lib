local String = import("java.lang.String")

local json = require("@base/json")
local http = require("@pierrelasse/lib/http")


local function stringToBytes(str)
    return String(str).getBytes()
end

---@class pierrelasse.lib.discordWebhook.EmbedFooter
---@field text string
---@field icon_url? string
---@field proxy_icon_url? string

---@class pierrelasse.lib.discordWebhook.EmbedImage
---@field url string
---@field proxy_url? string
---@field height? integer
---@field width? integer

---@class pierrelasse.lib.discordWebhook.EmbedThumbnail
---@field url string
---@field proxy_url? string
---@field height? integer
---@field width? integer

---@class pierrelasse.lib.discordWebhook.EmbedVideo
---@field url? string
---@field height? integer
---@field width? integer

---@class pierrelasse.lib.discordWebhook.EmbedProvider
---@field name? string
---@field url? string

---@class pierrelasse.lib.discordWebhook.EmbedAuthor
---@field name string
---@field url? string
---@field icon_url? string
---@field proxy_icon_url? string

---@class pierrelasse.lib.discordWebhook.EmbedField
---@field name string
---@field value string
---@field inline? boolean

---@class DiscordEmbed
---@field title? string
---@field type? string
---@field description? string
---@field url? string
---@field timestamp? string
---@field color? integer
---@field footer? pierrelasse.lib.discordWebhook.EmbedFooter
---@field image? pierrelasse.lib.discordWebhook.EmbedImage
---@field thumbnail? pierrelasse.lib.discordWebhook.EmbedThumbnail
---@field video? pierrelasse.lib.discordWebhook.EmbedVideo
---@field provider? pierrelasse.lib.discordWebhook.EmbedProvider
---@field author? pierrelasse.lib.discordWebhook.EmbedAuthor
---@field fields? pierrelasse.lib.discordWebhook.EmbedField[]

---@class pierrelasse.lib.discordWebhook.WebhookPayload
---@field content? string
---@field username? string
---@field avatar_url? string
---@field tts? boolean
---@field embeds? DiscordEmbed[]
---@field allowed_mentions? table
---@field components? table
---@field attachments? table

local this = {}

this.httpClient = http.newClient()

---@param id string
---@param token string
---@param data pierrelasse.lib.discordWebhook.WebhookPayload
function this.send(id, token, data)
    local body = stringToBytes(json.encode(data))

    local resp = this.httpClient:perform({
        method = "POST",
        url = "https://discord.com/api/webhooks/"..id.."/"..token,
        headers = {
            ["Content-Type"] = "application/json"
        },
        body = body
    })

    if resp.statusCode ~= 204 and resp.statusCode ~= 200 then
        scripting.warning("pierrelasse/lib/discordWebhook: failed id="..id..". code="..resp.statusCode)
    end
end

return this
