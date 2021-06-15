FROM lorisleiva/laravel-docker:latest
LABEL maintainer Mark <chumheramis@gmail.com>

# build arguments
ARG WWWGROUP=1000
ARG WWWUSER="sail"
ARG GIT_REPOSITORY=null
ARG GIT_BRANCH="master"
# environment variables
ENV GIT_UPDATE=0
# create user and user group
#RUN addgroup -S -g ${WWWGROUP} ${WWWUSER}
#RUN adduser -s /bin/bash --disabled-password -G ${WWWUSER} --uid "1337" ${WWWUSER}
 # Copy Secret to id_rsa
#RUN mkdir -p /home/${WWWUSER}/.ssh && ln -s /run/secrets/id_rsa /home/${WWWUSER}/.ssh/id_rsa
#RUN chown -R ${WWWUSER}:${WWWUSER} /home/${WWWUSER}/.ssh
# fix work iconv library with alphine
#RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted gnu-libiconv
#ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php
#RUN chown -R ${WWWUSER}:${WWWUSER} /var/www/html
COPY ./xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
COPY ./start-container /usr/local/bin/start-container
RUN chmod +x /usr/local/bin/start-container
#USER ${WWWUSER}
WORKDIR /var/www/html
EXPOSE 8000
ENTRYPOINT ["start-container"]