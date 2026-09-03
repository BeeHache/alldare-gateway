local _M = {}

function _M.ensure_correlation_id()
    local cid = ngx.req.get_headers()["X-Correlation-ID"] or ngx.req.get_headers()["x-correlation-id"]
    if not cid or cid == "" then
        local status, resty_uuid = pcall(require, "resty.jit-uuid")
        if status and resty_uuid then
            resty_uuid.seed()
            cid = resty_uuid.generate()
        else
            cid = string.format("%04x%04x-%04x-%04x-%04x-%04x%04x%04x",
                math.random(0, 0xffff), math.random(0, 0xffff),
                math.random(0, 0xffff),
                math.random(0, 0x0fff) + 0x4000,
                math.random(0, 0x3fff) + 0x8000,
                math.random(0, 0xffff), math.random(0, 0xffff), math.random(0, 0xffff)
            )
        end
    end

    ngx.req.set_header("X-Correlation-ID", cid)
    ngx.header["X-Correlation-ID"] = cid
    return cid
end

return _M
