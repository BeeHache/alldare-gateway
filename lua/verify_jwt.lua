package.path = "/etc/nginx/lua/?.lua;/usr/local/openresty/site/lualib/?.lua;" .. package.path
local auth_utils = require("auth_utils")

local method = ngx.req.get_method()
local token = auth_utils.get_token()

-- Allow unauthenticated GET requests to pass through to public microservice routes
if method == "GET" and not token then
    return
end

local payload, err = auth_utils.verify_and_extract()

if not payload then
    -- For GET requests with invalid/expired tokens, strip bad token headers so downstream spring security permits public read
    if method == "GET" then
        ngx.req.clear_header("Authorization")
        ngx.req.clear_header("authorization")
        ngx.req.set_header("Authorization", nil)
        ngx.req.set_header("authorization", nil)
        return
    end
    ngx.status = 401
    ngx.say('{"error": "' .. (err or "unauthorized") .. '"}')
    return ngx.exit(401)
end

-- Inject headers for downstream services and expose to UI
local user_id = payload.userId or payload.sub or "anonymous"
ngx.req.set_header("X-User-ID", user_id)
ngx.header["X-User-ID"] = user_id

if payload.roles then
    local roles = payload.roles
    if type(roles) == "table" then
        roles = table.concat(roles, " ")
    end
    ngx.req.set_header("X-User-Roles", roles)
    ngx.header["X-User-Roles"] = roles
end
