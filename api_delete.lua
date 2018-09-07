package.cpath = ngx.var.lua_dir .. "lib/?.so;;"
package.path = ngx.var.lua_dir .. "?.lua;;"
local cjson = require "cjson"

function e(message)
    local r = {}
    r['code'] = 0 
    r['message'] = message
    ngx.say(cjson.encode(r))
end
function s(message)
    local r = {}
    r['code'] = 1 
    r['message'] = message
    ngx.say(cjson.encode(r))
end

if "POST" ~= ngx.var.request_method then
    return e('Only accept POST request.')
end

local header = ngx.req.get_headers()
if "application/x-www-form-urlencoded" ~= header['content-type'] then
    return e('Only accept Content-Type:application/x-www-form-urlencoded.')
end

ngx.req.read_body()
local post = ngx.req.get_post_args()
if post['domain'] == nil then
    return e('Parameter domain can not empty.')
end

local mysql = require "lib.resty.mysql"
local mysql_config = require "config.mysql"

local db, err = mysql:new()
if not db then
    return e("failed to instantiate mysql: ", err)
end
local ok, err, errcode, sqlstate = db:connect(mysql_config)
if not ok then
    return e("failed to connect: ", err, ": ", errcode, " ", sqlstate)
end

local sql = string.format( "SELECT * FROM map WHERE domain = '%s'", post['domain'])
local res, err, errno, sqlstate = db:query(sql)
if #res <= 0 then
    return e("Record does not exist")
end

sql = string.format( "DELETE FROM map WHERE domain = '%s'", post['domain'])
res, err, errno, sqlstate = db:query(sql)
if not res then
    return e(err)
end

db:close()

local redis = require "lib.resty.redis"
redis.add_commands("del")
local red = redis:new()
local redis_config = require "config.redis"
local ok, err = red:connect(redis_config.host, redis_config.port)
if not ok then
    return e("failed to connect: ", err)
end
if redis_config.auth ~= '' then
    local res, err = red:auth("foobared")
    if not res then
        return e("failed to authenticate: ", err)
    end
end
ok, err = red:del(redis_config.prefix .. post['domain'])
return s('ok')
