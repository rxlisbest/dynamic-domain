-- ngx.exec('/1/bucket_1' .. '/' ..ngx.var.uri)
-- ngx.say(ngx.var.uri)
-- ngx.say(ngx.var.host)

local mysql = require "lib.resty.mysql"
local mysql_config = require "config.mysql"

local db, err = mysql:new()
if not db then
    ngx.say("failed to instantiate mysql: ", err)
    return
end
local ok, err, errcode, sqlstate = db:connect(mysql_config)
if not ok then
    ngx.say("failed to connect: ", err, ": ", errcode, " ", sqlstate)
    return
end
local sql = "SELECT * FROM map WHERE domain = '" .. ngx.var.host .. "'"
ngx.say(sql)
local res, err, errno, sqlstate = db:query(sql)
db:close()
-- ngx.say(#res)
if not res then
    ngx.say(err)
    return
end
    ngx.say(res[1]['directory'] .. ngx.var.uri)
if #res > 0 then
    ngx.say(res[1]['directory'] .. ngx.var.uri)
    -- ngx.exec(res[1]['directory'] .. ngx.var.uri)
end
