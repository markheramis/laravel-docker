FROM ubuntu:devel

LABEL maintainer="Mark Heramis"
ARG WWWGROUP=1000

WORKDIR /var/www/html

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update

RUN apt-get install -y \
    gnupg \
    gosu \
    curl \
    ca-certificates \
    zip \
    unzip \
    git \
    supervisor \
    libcap2-bin \
    libpng-dev \
    python2 \
    cron \
    vim

        
RUN mkdir -p ~/.gnupg
RUN chmod 600 ~/.gnupg
RUN echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf
RUN apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E5267A6C
RUN apt-key adv --homedir ~/.gnupg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C300EE8C
RUN echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu hirsute main" > \
    /etc/apt/sources.list.d/ppa_ondrej_php.list
# Installing PHP Dependencies
RUN apt-get update

RUN apt-get install -y \
    php8.0-cli \
    php8.0-dev \
    php8.0-curl \
    php8.0-mysql \
    php8.0-mbstring \
    php8.0-xml \
    php8.0-zip \
    php8.0-bcmath \
    php8.0-intl \
    php8.0-readline \
    php8.0-pcov \
    php8.0-igbinary \
    php8.0-ldap \
    php8.0-redis \
    php8.0-swoole
    # php8.0-xdebug

RUN apt-get install -yq mysql-client
# RUN apt-get install -yq postgresql-client

# Clean OS
RUN apt-get -y autoremove
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN setcap "cap_net_bind_service=+ep" /usr/bin/php8.0

COPY ./php/php.ini /etc/php/8.0/cli/conf.d/99-sail.ini
COPY ./php/xdebug.ini /etc/php/8.0/mods-available/xdebug.ini
COPY ./supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./cronjob /etc/cron.d/app_cron
COPY ./start-container /usr/local/bin/start-container

RUN chmod 644 /etc/cron.d/app_cron
RUN chmod +x /usr/local/bin/start-container

# create cron log
RUN touch /var/log/cron.log

RUN groupadd --force -g $WWWGROUP sail
RUN useradd -ms /bin/bash --no-user-group -g $WWWGROUP -u 1337 sail


RUN crontab /etc/cron.d/app_cron

EXPOSE 80
# USER sail
ENTRYPOINT ["start-container"]