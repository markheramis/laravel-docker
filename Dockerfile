FROM ubuntu:20.04

LABEL maintainer="Mark Heramis"
ARG WWWUSER=sail
ARG WWWGROUP=1000

WORKDIR /var/www/html
ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y  g++ gnupg gosu libssl-dev libcap2-bin libpng-dev curl python2 make nano unzip ca-certificates zip \
                        git supervisor cron vim htop git
RUN mkdir -p ~/.gnupg
RUN chmod 600 ~/.gnupg
RUN echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf
RUN apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E5267A6C
RUN apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C300EE8C
RUN echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main" > /etc/apt/sources.list.d/ppa_ondrej_php.list
# Installing PHP Dependencies
RUN apt-get update
RUN apt-get install -y php-mbstring php-xml php-bcmath php8.0-cli php8.0-curl php8.0-mysql php8.0-zip php8.0-redis
# Installing Composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    HASH=`curl -sS https://composer.github.io/installer.sig` && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { \
        echo 'Installer verified'; \
    } else { \
        echo 'Installer corrupt'; unlink('composer-setup.php'); \
    } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"

# setting up npm for global installation without sudo
# http://stackoverflow.com/a/19379795/580268
RUN MODULES="local" && \
    echo prefix = ~/$MODULES >> ~/.npmrc && \
    echo "export PATH=\$HOME/$MODULES/bin:\$PATH" >> ~/.bashrc && \
    . ~/.bashrc && \
    mkdir ~/$MODULES

# install Node.js and npm
# https://gist.github.com/isaacs/579814#file-node-and-npm-in-30-seconds-sh
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && apt-get install -y nodejs
# Install YARN
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list
RUN apt-get update
RUN apt-get install -y yarn
# ADD DATABASE CLIENT
# @todo: probably add conditional here to decide if to use mysql or postgresql client
RUN apt-get install -yq mysql-client
RUN apt-get install -yq postgresql-client

# Clean OS
RUN apt-get -y autoremove
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pecl channel-update https://pecl.php.net/channel.xml \
    && pecl install swoole \
    && pecl clear-cache \
    && rm -rf /tmp/* /var/tmp/*
RUN setcap "cap_net_bind_service=+ep" /usr/bin/php8.0

# create cron log
RUN touch /var/log/cron.log

COPY ./php/php.ini /etc/php/8.0/cli/conf.d/99-sail.ini
COPY ./php/xdebug.ini /etc/php/8.0/mods-available/xdebug.ini
COPY ./supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./cronjob /etc/cron.d/app_cron
COPY ./start-container /usr/local/bin/start-container

RUN chmod 644 /etc/cron.d/app_cron
RUN chmod +x /usr/local/bin/start-container

RUN groupadd --force -g $WWWGROUP $WWWUSER
RUN useradd -ms /bin/bash --no-user-group -g $WWWGROUP -u 1337 $WWWUSER
RUN usermod -aG sudo $WWWUSER
RUN usermod -a -G www-data $WWWUSER

RUN chown $WWWUSER:$WWWUSER /var/www/html -R

RUN pecl install xdebug
RUN crontab /etc/cron.d/app_cron

EXPOSE 8000
ENTRYPOINT ["start-container"]