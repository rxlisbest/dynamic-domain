ngx.req.read_body()
local postargs = ngx.req.get_post_args()
postargs["test"]
return
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

local res, err, errno, sqlstate = db:query(sql)
db:close()
-- ngx.say(#res)
if not res then
    ngx.say(err)
    return
end
if #res > 0 then
    ok, err = red:set(redis_config.prefix .. ngx.var.host, res[1]['directory'])
end


local redis = require "lib.resty.redis"
local red = redis:new()
local redis_config = require "config.redis"
local ok, err = red:connect(redis_config.host, redis_config.port)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

local res, err = red:get(redis_config.prefix .. ngx.var.host)
if not res then
    ngx.say("failed to get the key: ", err)
    return
end
if res == ngx.null then
    return
else
end

