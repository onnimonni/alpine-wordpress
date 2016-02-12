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
    # Libs for php
    libssh2 curl libpng freetype libjpeg-turbo libgcc libxml2 libstdc++ icu-libs libltdl libmcrypt \
    && apk add -u musl

# php7 depracates following packages: php-apcu php-mysql php-iconv
# Install php 7
RUN apk add php7 php7-fpm php7-json php7-zlib php7-xml php7-pdo php7-phar php7-openssl \
    php7-pdo_mysql php7-mysqli php7-mysqlnd \
    php7-gd php7-mcrypt \
    php7-curl php7-opcache php7-ctype  \
    php7-intl php7-bcmath php7-dom php7-xmlreader --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

# Small fixes
RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php7/php.ini && \
    sed -i 's/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/sbin\/nologin/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/bin\/bash/g' /etc/passwd && \
    sed -i 's/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/sbin\/nologin/nginx:x:100:101:Linux User,,,:\/var\/www\/localhost\/htdocs:\/bin\/bash/g' /etc/passwd-

ADD files/nginx.conf /etc/nginx/
ADD files/php-fpm.conf /etc/php7/
ADD files/run.sh /

RUN chmod +x /run.sh

###
# Additions
###

# Add .bashrc for root to easier debugging inside container
ADD root/.bashrc /root/.bashrc

ENV TERM="xterm" \
    DB_HOST="172.17.0.1" \
    DB_NAME="" \
    DB_USER=""\
    DB_PASS=""

# Install wp-cli
# Add wp-cli wrapper
ADD scripts/wp /usr/bin/local/wp

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/bin/local/wp-cli && chmod +x /usr/bin/local/wp

# Install composer and link php7 to php
# source: https://getcomposer.org/download/
RUN ln -s /usr/bin/php7 /usr/bin/php && \
    php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/bin/local/composer && \
    chmod +x /usr/bin/local/composer

##
# Install ruby + poltergeist
##
RUN apk add ruby ruby-nokogiri build-base ruby-dev && \
    gem install rspec rspec-retry poltergeist capybara --no-ri --no-rdoc && \
    apk del build-base ruby-dev


##
# Install PhantomJS
##

# Add preconfigured phantomjs package build with: https://github.com/fgrehm/docker-phantomjs2
# This adds all sorts of dependencies from dockerize magic
ADD lib/dockerized-phantomjs.tar.gz /

# Update phantomjs binary to 2.1.1
RUN cd /tmp && \
    wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
    tar -xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
    mv phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs && \
    chmod +x /usr/local/bin/phantomjs && \
    rm -r /tmp/*

RUN rm -rf /var/cache/apk/*

EXPOSE 80
VOLUME ["/DATA"]

CMD ["/run.sh"]
