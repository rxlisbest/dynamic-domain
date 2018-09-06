package.cpath = ngx.var.lua_dir .. "lib/?.so;;"
package.path = ngx.var.lua_dir .. "?.lua;;"
local cjson = require "cjson"
if true then
    local test = {}
    test['a'] = 1
    ngx.say(cjson.encode(test))
    return
end

if true then
    local test = {}
    test['a'] = 1
    ngx.say(ngx.var.lua_dir)
    return
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
    local sql = string.format("SELECT b.name, b.user_id, bd.domain FROM %sbucket_domain bd LEFT JOIN %sbucket b ON b.id = bd.bucket_id WHERE bd.domain = '%s'", mysql_config.prefix, mysql_config.prefix, ngx.var.host)

    local res, err, errno, sqlstate = db:query(sql)
    db:close()
    -- ngx.say(#res)
    if not res then
        ngx.say(err)
        return
    end
    if #res > 0 then
        local dir = string.format("/%s/%s/", res[1]['user_id'], res[1]['name'])
        ok, err = red:set(redis_config.prefix .. ngx.var.host, dir)
        ngx.exec(dir .. string.sub(ngx.var.uri, 2))
    end
    return
else
    ngx.exec(res .. string.sub(ngx.var.uri, 2))
end

