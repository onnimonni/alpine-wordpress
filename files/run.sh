#!/bin/sh

[ -f /run-pre.sh ] && /run-pre.sh

if [ ! -d /data/code/htdocs ] ; then
  mkdir -p /data/code/htdocs
  chown nginx:www-data /data/code/htdocs
fi

# start php-fpm
mkdir -p /data/logs/php-fpm
php-fpm

# start nginx
mkdir -p /data/logs/nginx
mkdir -p /tmp/nginx
chown nginx /tmp/nginx
nginx