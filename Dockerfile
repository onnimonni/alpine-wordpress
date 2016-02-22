FROM alpine:edge
MAINTAINER Onni Hakala - Geniem Oy. <onni.hakala@geniem.com>

LABEL   devoply.type="site" \
        devoply.cms="wordpress" \
        devoply.framework="wordpress" \
        devoply.language="php" \
        devoply.require="mariadb etopian/nginx-proxy" \
        devoply.recommend="redis" \
        devoply.description="WordPress on Nginx and PHP-FPM with WP-CLI." \
        devoply.name="WordPress" \
        devoply.params="docker run -d --name {container_name} -e VIRTUAL_HOST={virtual_hosts} -v /data/sites/{domain_name}:/DATA geniem/alpine-php-wordpress"

# Install php + nginx
RUN apk update \
    && apk add bash less vim nano git mysql-client nginx ca-certificates \
    # PHP 5.6
    php php-fpm php-json php-zlib php-xml php-pdo php-phar php-openssl \
    php-pdo_mysql php-mysqli \
    php-gd php-mcrypt \
    php-curl php-opcache php-ctype  \
    php-intl php-bcmath php-dom php-xmlreader php-apcu php-mysql php-iconv \
    # Libs for php
    libssh2 curl libpng freetype libjpeg-turbo libgcc libxml2 libstdc++ icu-libs libltdl libmcrypt \
    && apk add -u musl

##
# Install PhantomJS
##

# Add preconfigured phantomjs package build with: https://github.com/fgrehm/docker-phantomjs2
# This adds all sorts of dependencies from dockerize magic
ADD lib/phantomjs-dependencies.tar.gz /

# Update phantomjs binary to 2.1.1
RUN cd /tmp && \
    wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
    tar -xjf phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
    mv phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs && \
    chmod +x /usr/local/bin/phantomjs && \
    rm -r /tmp/*

##
# Install ruby + poltergeist
##
RUN apk add ruby ruby-nokogiri ruby-json build-base ruby-dev && \
    gem install rspec rspec-retry poltergeist capybara --no-ri --no-rdoc && \
    apk del build-base ruby-dev

# Add S6-overlay to use S6 process manager
# https://github.com/just-containers/s6-overlay/#the-docker-way
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz /tmp/
RUN gunzip -c /tmp/s6-overlay-amd64.tar.gz | tar -xf - -C /

# Small fixes
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/php.ini && \
    sed -i 's/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/sbin\/nologin/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/bin\/bash/g' /etc/passwd && \
    sed -i 's/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/sbin\/nologin/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/bin\/bash/g' /etc/passwd-

# Install wp-cli
# Add wp-cli wrapper
ADD scripts/wp /usr/local/bin/wp

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp-cli && chmod +x /usr/local/bin/wp

# Install composer
# source: https://getcomposer.org/download/
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

##
# Add Project files like nginx and php-fpm processes and configs
##
ADD files/etc/ /etc/

###
# Additions
###

# Add .bashrc for root to easier debugging inside container
ADD root/.bashrc /root/.bashrc

ENV TERM="xterm" \
    DB_HOST="172.17.0.1" \
    DB_NAME="" \
    DB_USER=""\
    DB_PASS=""\
    WP_CORE="/data/code/htdocs/wp"

RUN rm -rf /var/cache/apk/*

EXPOSE 80
VOLUME ["/data"]

ENTRYPOINT ["/init"]