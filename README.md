# dynamic-domain
#### nginx 配置
```
    geo $lua_dir {
       default "/Library/WebServer/Documents/lua/openresty/dynamic_domain/"; # must-have
    }
    server {
        listen 80;
        server_name localhost;
        lua_code_cache off;
        location = /api/add {
            default_type application/json;
            set $lua_file "api_add.lua"; # must-have
            content_by_lua_file $lua_dir$lua_file;
        }
        location = /api/delete {
            default_type application/json;
            set $lua_file "api_delete.lua"; # must-have
            content_by_lua_file $lua_dir$lua_file;
        }
    }
    server {
        listen 80 default;
        lua_code_cache off;
        location / {
            default_type text/html;
            set $lua_file "proxy.lua"; # must-have
            content_by_lua_file $lua_dir$lua_file;
        }
        location ~* /.*/.* {
            root /Library/WebServer/Documents/htdocs/upload_server/public/upload;
            default_type application/octet-stream;
        }
    }
```
