FROM ubuntu:22.04

LABEL maintainer="Mark Heramis"

ARG WWWGROUP=1000
ARG WWWUSER=1000

ARG NODE_VERSION=16

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
        php8.1-cli \
        php8.1-dev \
        php8.1-pgsql \
        php8.1-sqlite3 \
        php8.1-gd \
        php8.1-curl \
        php8.1-imap \
        php8.1-mysql \
        php8.1-mbstring \
        php8.1-xml \
        php8.1-zip \
        php8.1-bcmath \
        php8.1-soap \
        php8.1-intl \
        php8.1-readline \
        php8.1-ldap \
        php8.1-msgpack \
        php8.1-igbinary \
        php8.1-redis \
        php8.1-memcached \
        php8.1-pcov \
        php8.1-xdebug
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

RUN setcap "cap_net_bind_service=+ep" /usr/bin/php8.1

RUN groupadd --force -g $WWWGROUP sail
RUN useradd -ms /bin/bash --no-user-group -g $WWWGROUP -u 1337 sail

COPY ./php/php.ini /etc/php/8.1/cli/conf.d/99-sail.ini
COPY ./php/xdebug.ini /etc/php/8.1/mods-available/xdebug.ini
COPY ./supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./start-container /usr/local/bin/start-container
RUN chmod +x /usr/local/bin/start-container

EXPOSE 80

ENTRYPOINT ["start-container"]
