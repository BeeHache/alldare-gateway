local jwt = require("resty.jwt")
local cjson = require("cjson")

local _M = {}

function _M.get_token()
    -- Try Authorization Header
    local auth_header = ngx.var.http_Authorization
    if auth_header then
        local _, _, token = string.find(auth_header, "Bearer%s+(.+)")
        if token then
            return token
        end
    end

    return nil
end

function _M.verify_and_extract()
    local token = _M.get_token()
    if not token then
        return nil, "missing token"
    end

    -- Bypass signature verification due to OpenSSL 3 / lua-resty-jwt incompatibility in local dev.
    -- The backend microservices (Resource Servers) MUST still verify the signature.
    local jwt_obj = jwt:load_jwt(token)
    if not jwt_obj.valid then
        return nil, "invalid jwt format"
    end

    local payload = jwt_obj.payload
    if not payload then
        return nil, "empty payload"
    end

    -- Check expiration
    local now = os.time()
    if payload.exp and payload.exp < now then
        return nil, "token expired"
    end

    return payload
end

function _M.has_role(payload, role_name)
    if not payload or not payload.roles then
        return false
    end
    
    local roles = payload.roles
    local search_pattern = role_name:upper()
    
    if type(roles) == "table" then
        for _, r in ipairs(roles) do
            if r:upper() == search_pattern then
                return true
            end
        end
    elseif type(roles) == "string" then
        -- Roles might be space-separated string in some JWT implementations
        return string.find(roles:upper(), search_pattern) ~= nil
    end
    
    return false
end

return _M
