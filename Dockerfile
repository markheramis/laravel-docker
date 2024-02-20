FROM ubuntu:22.04

LABEL maintainer="Mark Heramis"

ARG WWWGROUP=1000
ARG WWWUSER=1000

ARG NODE_VERSION=21
ARG PHP_VERSION=$PHP_VERSION

WORKDIR /var/www/html

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y gnupg gosu curl ca-certificates zip unzip git supervisor sqlite3 libcap2-bin libpng-dev python2
RUN mkdir -p ~/.gnupg && chmod 600 ~/.gnupg

RUN echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf
RUN echo "keyserver hkp://keyserver.ubuntu.com:80" >> ~/.gnupg/dirmngr.conf
RUN gpg --recv-key 0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c
RUN gpg --export 0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c > /usr/share/keyrings/ppa_ondrej_php.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu jammy main" > /etc/apt/sources.list.d/ppa_ondrej_php.list

RUN apt-get update
RUN apt-get install -y \
        php$PHP_VERSION-cli \
        php$PHP_VERSION-dev \
        php$PHP_VERSION-pgsql \
        php$PHP_VERSION-sqlite3 \
        php$PHP_VERSION-gd \
        php$PHP_VERSION-curl \
        php$PHP_VERSION-imap \
        php$PHP_VERSION-mysql \
        php$PHP_VERSION-mbstring \
        php$PHP_VERSION-xml \
        php$PHP_VERSION-zip \
        php$PHP_VERSION-bcmath \
        php$PHP_VERSION-soap \
        php$PHP_VERSION-intl \
        php$PHP_VERSION-readline \
        php$PHP_VERSION-ldap \
        php$PHP_VERSION-msgpack \
        php$PHP_VERSION-igbinary \
        php$PHP_VERSION-redis \
        php$PHP_VERSION-memcached \
        php$PHP_VERSION-pcov \
        php$PHP_VERSION-xdebug
RUN php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

RUN curl -sLS https://deb.nodesource.com/setup_$NODE_VERSION.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g npm
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarn.gpg >/dev/null
RUN echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list

RUN apt-get install -y mysql-client
RUN apt-get install -y yarn
RUN apt-get -y autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd --force -g $WWWGROUP sail
RUN useradd -ms /bin/bash --no-user-group -g $WWWGROUP -u 1337 sail

COPY ./php/php.ini /etc/php/$PHP_VERSION/cli/conf.d/99-sail.ini
COPY ./php/xdebug.ini /etc/php/$PHP_VERSION/mods-available/xdebug.ini
COPY ./supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./start-container /usr/local/bin/start-container
RUN chmod +x /usr/local/bin/start-container

USER sail


EXPOSE 80

ENTRYPOINT ["start-container"]
