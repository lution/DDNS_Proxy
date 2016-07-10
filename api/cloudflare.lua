--
-- CLoudflare DNS API
-- Date:2015-12-25
--
local M = {}
local json = require('utils.json')

function process(auth, record, ip)
    local identifier = {}
    identifier.zone = getZone(auth, record)
    if identifier.zone then
        identifier.record, data = getRecord(auth, identifier.zone, record)
        if identifier.record then
            local result = updateRecord(auth, identifier, ip, data)
        end
    end
end

--
-- List all zones of this account
-- see https://api.cloudflare.com/#zone-list-zones
--

function getZone(auth, record)
    local raw_resp = ngx.location.capture(
    '/api/cloudflare/zones',
    { vars = {email = auth.email, api_key = auth.API_key} }
    )
    -- FIXME resp status check
    local data, err = json:decode(raw_resp.body)
    if not err then
        if data.success == true then
            for _, zone in pairs(data.result) do 
                local a, b = #zone.name, #record
                if b > a then
                    local tmp = string.sub(record, b - a + 1, b)
                    if (tmp == zone.name) then
                        return zone.id
                    end
                end
            end
            return nil
        else
            showError(data.errors)
        end
    else
        -- FIXME error message
        return nil
    end
end

--
-- List DNS records of a specific zone
-- see https://api.cloudflare.com/#dns-records-for-a-zone-list-dns-records
--

function getRecord(auth, zone, record)
    local raw_resp = ngx.location.capture(
    '/api/cloudflare/zones/' .. zone .. '/dns_records?name=' .. record,
    { vars = {email = auth.email, api_key = auth.API_key} }
    )
    -- FIXME resp status check
    local data, err = json:decode(raw_resp.body)
    if not err then
        if data.success == true then
            return data.result[1].id, data
        else
            showError(data.errors)
        end
    else
        -- FIXME error message
        return nil
    end
end

--
-- Update the DDNS record
-- see https://api.cloudflare.com/#dns-records-for-a-zone-update-dns-record
--

function updateRecord(auth, identifier, ip, data)
    data.result[1].content = ip
    local raw_resp = ngx.location.capture(
    -- FIXME modified_on not modified
    '/api/cloudflare/zones/' .. identifier.zone .. '/dns_records/' .. identifier.record,
    { vars = {email = auth.email, api_key = auth.API_key}, method = ngx.HTTP_PUT, body = json:encode(data.result[1]) }
    )
    -- FIXME resp status check
    local data, err = json:decode(raw_resp.body)
    if not err then
        if data.success == true then
            ngx.say("Success")
        else
            showError(data.errors)
        end
    else
        -- FIXME error message
        return nil
    end
end

function showError(data)
    -- FIXME return non 200 status on error
    ngx.say(json:encode(data))
end

M.process = process

return M
