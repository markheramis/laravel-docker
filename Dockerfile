FROM ubuntu:21.10

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
    python2

        
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
    php8.1-cli \
    php8.1-dev \
    php8.1-curl \
    php8.1-mysql \
    php8.1-mbstring \
    php8.1-xml \
    php8.1-zip \
    php8.1-bcmath \
    php8.1-intl \
    php8.1-readline \
    php8.1-pcov \
    php8.1-igbinary \
    php8.1-ldap \
    php8.1-redis \
    php8.1-swoole \
    php8.1-xdebug

RUN apt-get install -yq mysql-client
# RUN apt-get install -yq postgresql-client

# Clean OS
RUN apt-get -y autoremove
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN setcap "cap_net_bind_service=+ep" /usr/bin/php8.1

COPY ./php/php.ini /etc/php/8.1/cli/conf.d/99-sail.ini
COPY ./php/xdebug.ini /etc/php/8.1/mods-available/xdebug.ini
COPY ./supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./start-container /usr/local/bin/start-container

RUN chmod +x /usr/local/bin/start-container

RUN groupadd --force -g $WWWGROUP sail
RUN useradd -ms /bin/bash --no-user-group -g $WWWGROUP -u 1337 sail

EXPOSE 80
# USER sail
ENTRYPOINT ["start-container"]
