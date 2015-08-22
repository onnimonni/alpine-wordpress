FROM alpine:edge
MAINTAINER Etopian Inc. <contact@etopian.com>

LABEL devoply.type="site"
LABEL devoply.cms="wordpress"
LABEL devoply.framework="wordpress"
LABEL devoply.language="php"
LABEL devoply.require="mariadb etopian/nginx-proxy"
LABEL devoply.recommend="redis"

RUN apk update \
    && apk add bash less vim nginx ca-certificates \
    php-fpm php-json php-zlib php-xml php-pdo php-phar php-openssl \
    php-pdo_mysql php-mysqli \
    php-gd php-iconv php-mcrypt \
    php-mysql php-curl php-opcache php-ctype php-apcu \
    php-intl php-bcmath php-dom php-xmlreader mysql-client && apk add -u musl

RUN rm -rf /var/cache/apk/*

ENV TERM="xterm" DB_HOST="172.17.42.1" DB_NAME= DB_USER= DB_PASS=
ADD files/nginx.conf /etc/nginx/
ADD files/php-fpm.conf /etc/php/
ADD files/run.sh /
RUN chmod +x /run.sh

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/bin/wp-cli

EXPOSE 80
VOLUME ["/DATA"]

CMD ["/run.sh"]
