# Using Supervisor

**Note**: If you have not checked the basic usage, I recommend that you [click here](basic.md)

This document will show you how to use this [supervisor](http://supervisord.org) to create background processes inside this `Dockerfile`.

First, you need to create your own supervisor config file as follows

```
touch supervisor.conf
```

Then append this to the file

```
[supervisord]
nodaemon=true
user=root
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid
```

This will configure your supervisor service's default behaviour, like logging and the user in which the process runs in.

**Author's note**: root might not be safe. not sure. will investigate.

Then you can then begin to add your custom commands.



So you don't need to invoke the `php artisan serve` and `php artisan queue:work` anymore.

But in any case you need to have something else running, all you need to do is just follow the format and write in in your `supervisor.conf` file that you just created


```
[program:your-command]
command=your cli command here
user=sail
```

and then add the following line to your Dockerfile

```
COPY ./supervisor.conf /etc/supervisor/conf.d/custom.conf
```

This line will copy your `supervisor.conf` file inside `/etc/supervisor/conf.d/` inside the Docker Container.

In the end, your `Dockerfile` should look like this

```
FROM wendyourway/laravel-docker:latest
LABEL maintainer Mark <chumheramis@gmail.com>

COPY . /var/www/html
COPY ./supervisor.conf /etc/supervisor/conf.d/custom.conf
```

## By Default

By default we had the following commands already built in
```
[program:php-serve]
command=/usr/bin/php -d variables_order=EGPCS /var/www/html/artisan serve --host=0.0.0.0 --port=80
user=sail
environment=LARAVEL_SAIL="1"
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:php-queue]
command=/usr/bin/php -d variables_order=EGPCS /var/www/html/artisan queue:work
user=sail
environment=LARAVEL_SAIL="1"
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
```

you can find this in `/etc/supervisor/conf.d/default.conf` inside the Dockerfile

To learn more about `supervisor` [click here](http://supervisord.org)