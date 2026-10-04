#!/bin/sh
set -eu

: "${PORT:=8080}"
export PORT

mkdir -p /run/nginx /var/log/nginx

envsubst '${PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
nginx -t

exec /usr/bin/supervisord -c /etc/supervisord.conf -n
