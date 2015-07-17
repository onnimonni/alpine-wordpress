# Lightweight WordPress PHP-FPM & Nginx Docker Image

http://www.dockerwordpress.com

Lightwight Docker image for the (latest) PHP-FPM and Nginx to run WordPress based on [AlpineLinux](http://alpinelinux.org)

* Image size only ~50MB !
* Very new packages (alpine:edge) 2015-04-03:
  * [PHP](http://pkgs.alpinelinux.org/package/main/x86/php) 5.6.7
  * [Nginx](http://pkgs.alpinelinux.org/package/main/x86/nginx) 1.6.2
  * Memory usage is around 50mb on a simple install.
  
  
## A simple example
### Say you want to run a single site on a VPS with Docker

```bash

mkdir -p /data/sites/etopian.com/htdocs

sudo docker run -e VIRTUAL_HOST=etopian.com -v /data/sites/etopian.com:/DATA -p 80:80 etopian/alpine-nginx-wordpress

```
The following user and group id are used, the files should be set to this:
User ID: 
Group ID: 

```bash
chown -R 100:101 /data/sites/etopian.com/htdocs
```

### Say you want to run a multiple WP sites on a VPS with Docker

```bash

sudo docker run -p 80:80 etopian/nginx-proxy
mkdir -p /data/sites/etopian.com/htdocs

sudo docker run -e VIRTUAL_HOST=etopian.com -v /data/sites/etopian.com:/DATA etopian/alpine-nginx-wordpress

mkdir -p /data/sites/etopian.net/htdocs
sudo docker run -e VIRTUAL_HOST=etopian.net -v /data/sites/etopian.net:/DATA etopian/alpine-nginx-wordpress
```

Populate /data/sites/etopian.com/htdocs and  /data/sites/etopian.net/htdocs with your WP files. See http://www.dockerwordpress.com if you need help on how to configure things.

The following user and group id are used, the files should be set to this:
User ID: 
Group ID: 

```bash
chown -R 100:101 /data/sites/etopian.com/htdocs
```



### Volume structure

* `htdocs`: Webroot
* `logs`: Nginx/PHP error logs
