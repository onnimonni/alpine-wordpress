# PHP-FPM & Nginx Docker Image

Lightwight Docker image for the (latest) PHP-FPM and Nginx based on [AlpineLinux](http://alpinelinux.org)

* Image size only ~100MB !
* Very new packages (alpine:edge) 2015-04-03:
  * [PHP](http://pkgs.alpinelinux.org/package/main/x86/php) 5.6.7
  * [Nginx](http://pkgs.alpinelinux.org/package/main/x86/nginx) 1.6.2
  
  
### Usage
```bash
sudo docker run -e VIRTUAL_HOST=etopian.com -e VIRTUAL_PORT=8081 -v /data/sites/etopian.com:/DATA -p 8081:80 etopian/docker-alpine-nginx-wordpress

```

### Volume structure

* `htdocs`: Webroot
* `logs`: Nginx/PHP error logs
