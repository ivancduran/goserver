#!/bin/bash

PATH=$1

echo "#!/bin/bash

case \$1 in
    start)
    echo \"Starting Go Server.\"
        sudo nginx -c \"$PATH/service/output/nginx.conf\" &
        cd \"$PATH/backend/\"; ./main &
        ;;
    stop)
    echo \"Stopping Go Server.\"
        sudo nginx -s stop &
        sudo kill \$(sudo lsof -t -i:8080)
        ;;
    restart)
    echo -n \"Restarting Web Service for Golang: \"
        sudo kill \$(sudo lsof -t -i:8080)
        sleep 1
        cd \"$PATH/backend/\"; ./main &
        echo \"Ready.\"
        ;;
    *)
        echo \"Options:\"
        echo $\"Usage \$0 {start|stop|restart}\"
        exit 1
esac
exit 0" > output/goserver

echo "[Unit]
Description=Golang Web Server

[Service]
ExecStart=/etc/init.d/goserver

[Install]
WantedBy=multi-user.target" > output/goserver.service

echo "events {
    # Server processes
    # worker_processes 1;
    # Max conections/second
    worker_connections  1024;
}

http {
    # Local cache config folder
    proxy_cache_path  $PATH/cache  levels=1:2    keys_zone=STATIC:10m inactive=24h max_size=1g;

    # General server config
    charset utf-8;
    access_log off;
    client_body_timeout 12;
    client_header_timeout 12;
    keepalive_timeout 15;
    send_timeout 10;

    # Gzip config
    gzip  on;
    gzip_http_version 1.0;
    gzip_types        text/plain
                      text/xml
                      text/css
                      application/xml
                      application/xhtml+xml
                      application/rss+xml
                      application/atom_xml
                      application/javascript
                      application/x-javascript
                      application/json;

    gzip_disable      \"MSIE [1-6]\.\";
    gzip_disable      \"Mozilla/4\";
    gzip_comp_level   6;
    gzip_proxied      no-cache no-store private expired auth;
    # gzip_proxied    any;
    # gzip_vary       on;
    # gzip_buffers    4 32k;
    # gzip_min_length 1000;

    server {
        listen 80;

        # ROOT DOCUMENT
        location / {
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$remote_addr;
            proxy_set_header Host \$host;
            proxy_pass http://127.0.0.1:8080;
        }

        # ASSETS / PUBLIC
        location /public {
            gzip_static on;

            proxy_set_header       Host \$host;
            proxy_cache            STATIC;
            proxy_cache_valid      200 302 120m;
            proxy_cache_valid      404 1m;
            proxy_cache_use_stale  error timeout invalid_header updating http_500 http_502 http_503 http_504;
            proxy_pass             http://127.0.0.1:8080;
        }

        # API
        location /v1 {
            add_header Cache-Control \"no-cache, must-revalidate, max-age=0\";
            add_header X-Cache-Status \$upstream_cache_status;

            proxy_cache_methods GET HEAD;
            proxy_cache            STATIC;

            proxy_cache_use_stale updating;
            proxy_cache_lock on;
            proxy_cache_valid any 2m;

            # proxy_ignore_headers X-Accel-Expires Expires Cache-Control;
            # proxy_set_header Authorization \"Basic VGhhbmsgeW91IGZvciByZWFkaW5nIGJuZWlqdC5ubAo=\";

            proxy_pass http://127.0.0.1:8080;
        }

    }
}" > output/nginx.conf
