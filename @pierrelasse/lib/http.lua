local URL = import("java.net.URL")
local Util = import("net.bluept.scripting.Util")


---@alias pierrelasse.lib.http.Method string
---|>"GET"
---| "POST"

---@class pierrelasse.lib.http.Request
---@field url string
---@field method pierrelasse.lib.http.Method
---@field headers? table<string, string|string[]>
---@field body? string|java.array<java.byte>

---@class pierrelasse.lib.http.Response
---@field ok boolean -- @experimental
---@field status string
---@field statusCode integer
local Response = {
    ---@package
    ---@type java.Object
    conn = nil
}
Response.__index = Response

---@return string
function Response:readBody()
    return Util.readStreamString(self.conn.getInputStream())
end

---@class pierrelasse.lib.http.Client
---@field defaultHeaders table<string, string[]>
---@field timeoutConnect integer
---@field timeoutRead integer
local Client = {}
Client.__index = Client

---@param request pierrelasse.lib.http.Request
function Client:perform(request)
    local url = URL(request.url)

    local headers = table.clone(self.defaultHeaders)
    if request.headers ~= nil then
        for k, v in pairs(request.headers) do
            local headersValue = headers[k]
            if headersValue == nil then
                headersValue = {}
                headers[k] = headersValue
            end
            if type(v) == "string" then
                table.insert(headersValue, v)
            else
                for vv in table.valuesLoop(v) do
                    table.insert(headersValue, vv)
                end
            end
        end
    end

    local conn = url.openConnection()
    conn.setRequestMethod(request.method)
    conn.setConnectTimeout(self.timeoutConnect)
    conn.setReadTimeout(self.timeoutRead)
    conn.setDoInput(true)
    conn.setUseCaches(false)

    for k, v in pairs(headers) do
        conn.setRequestProperty(k, v[1]) -- TODO
    end

    if request.body ~= nil then
        conn.setDoOutput(true)

        local os = conn.getOutputStream()
        os.write(request.body)
        os.flush()
        os.close()
    end

    local resp = setmetatable({}, Response)
    resp.conn = conn

    resp.status = conn.getResponseMessage()
    resp.statusCode = conn.getResponseCode()

    resp.ok = numbers.between(resp.statusCode, 200, 299)

    return resp
end

local this = {}

function this.newClient()
    local self = setmetatable({}, Client)

    self.defaultHeaders = {
        ["User-Agent"] = { "scripting-http-client/1.0" }
    }
    self.timeoutConnect = 2500
    self.timeoutRead = 1500

    return self
end

this.defaultClient = this.newClient()

---@param url string
---@param opts? {
--- method?: pierrelasse.lib.http.Method;
--- headers?: table<string, string|string[]>;
---}
function this.fetch(url, opts)
    if opts == nil then opts = {} end

    ---@type pierrelasse.lib.http.Request
    local request = {
        url = url,
        method = opts.method or "GET",
        headers = opts.headers or {}
    }

    return this.defaultClient:perform(request)
end

return this
