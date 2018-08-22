-- ngx.exec('/1/bucket_1' .. '/' ..ngx.var.uri)
-- ngx.say(ngx.var.uri)
-- ngx.say(ngx.var.host)

local mysql = require "resty.mysql"
local db, err = mysql:new()
if not db then
    ngx.say("failed to instantiate mysql: ", err)
    return
end
local ok, err, errcode, sqlstate = db:connect{
                    host = "127.0.0.1",
                    port = 3306,
                    database = "dynamic_domain",
                    user = "root",
                    password = "root",
                    charset = "utf8",
                    max_packet_size = 1024 * 1024,
                }
if not ok then
    ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
    return
end
local sql = "SELECT * FROM map WHERE domain = '" .. ngx.var.host .. "'"
-- ngx.say(sql)
local res, err, errno, sqlstate = db:query(sql)
db:close()
-- ngx.say(#res)
if not res then
    ngx.say(err)
    return
end
if #res > 0 then
    -- ngx.say(res[1]['directory'] .. ngx.var.uri)
    ngx.exec(res[1]['directory'] .. ngx.var.uri)
end
