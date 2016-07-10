local base64 = require('utils.base64')
local json = require('utils.json')

--
-- Get Email and API key using basic authentacation
--

local auth = {}
local record = ngx.var.record
local ip = ngx.var.remote_addr
local auth_header = ngx.var.http_Authorization

if not auth_header then
    ngx.status = 401
    ngx.header["WWW-Authenticate"] = 'Basic realm="Welcome,Please log in."'
    ngx.say('Not Authorized')
    ngx.exit(ngx.HTTP_OK)
else
    -- Auth Header value looks like "Basic Og=="
    local raw_auth_data = string.sub(ngx.var.http_Authorization, #"Basic " + 1, #ngx.var.http_Authorization)
    local auth_data = base64.decode(raw_auth_data)
    -- Original pattern from http://stackoverflow.com/questions/21040325/email-address-validation-using-corona-sdk
    auth.email = string.match(auth_data, '^([A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?):.*')
    if not auth.email then
        ngx.status = 401
        ngx.header["WWW-Authenticate"] = 'Basic realm="Please provide a valid email address as username"'
        ngx.exit(ngx.HTTP_OK)
    end
    auth.API_key = string.match(auth_data, "^[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?:(.*)$")
    if not auth.API_key then
        ngx.status = 401
        ngx.header["WWW-Authenticate"] = 'Basic realm="Please provide your API key as password"'
        ngx.exit(ngx.HTTP_OK)
    end
end

--
-- Call target API to process request
--

local cloudflare = require('api.cloudflare')
cloudflare.process(auth, record, ip)
