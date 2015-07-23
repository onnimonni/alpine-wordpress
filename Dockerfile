FROM alpine:edge
MAINTAINER Etopian Inc. <contact@etopian.com>

RUN apk update \
    && apk add bash nginx ca-certificates \
    php-fpm php-json php-zlib php-xml php-pdo php-phar php-openssl \
    php-pdo_mysql php-mysqli \
    php-gd php-iconv php-mcrypt \
    php-mysql php-curl php-opcache php-ctype php-apcu \
    php-intl php-bcmath

# fix php-fpm "Error relocating /usr/bin/php-fpm: __flt_rounds: symbol not found" bug
RUN apk add -u musl
RUN rm -rf /var/cache/apk/*

ADD files/nginx.conf /etc/nginx/
ADD files/php-fpm.conf /etc/php/
ADD files/run.sh /
RUN chmod +x /run.sh


EXPOSE 80
VOLUME ["/DATA"]

CMD ["/run.sh"]
