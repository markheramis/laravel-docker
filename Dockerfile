FROM lorisleiva/laravel-docker:latest
LABEL maintainer Mark <chumheramis@gmail.com>

# build arguments
ARG WWWGROUP=1000
ARG WWWUSER="sail"
ARG GIT_REPOSITORY=null
ARG GIT_BRANCH="master"
# environment variables
ENV ARTISAN_MIGRATE=1
ENV ARTISAN_SERVE=1
COPY ./xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
COPY ./start-container /usr/local/bin/start-container
RUN chmod +x /usr/local/bin/start-container
WORKDIR /var/www/html
EXPOSE 8000
ENTRYPOINT ["start-container"]