# With Cron Jobs

**Note**: If you have not checked the basic usage, I recommend that you [click here](basic.md)

This document will show you how to use with custom `Cron Jobs`.

First, you just need to create a cronjob file in your project root.

```bash
touch cronjob
```

**Tips**: Optionally though, you can put the cronjob file inside the `resources` directory in `Laravel`... I think it looks cleaner if you do that.

Then in that file you can put your custom cron command there..

We already defined a default cron to run the laravel schedule command

```bash
* * * * * cd /var/www/html && php artisan schedule:run >> /var/log/cron.log 2>&1
```

if you need to do something else,

just write that command in the cronjob file you just created along with your new command as follows

```bash
* * * * * cd /var/www/html && php artisan schedule:run >> /var/log/cron.log 2>&1
# your new command below
```

Example:

```bash
* * * * * cd /var/www/html && php artisan schedule:run >> /var/log/cron.log 2>&1
# your new command below
* * * * * cd /var/www/html && php artisan custom:command >> /var/log/cron.log 2>&1
```

and then add this line in your `Dockerfile`


```bash
COPY ./cronjob /etc/cron.d/app_cron
RUN chmod 644 /etc/cron.d/app_cron
RUN crontab /etc/cron.d/app_cron
```

In the end, your `Dockerfile` should look like this:

```bash
FROM wendyourway/laravel-docker:latest
LABEL maintainer Mark <chumheramis@gmail.com>

COPY . /var/www/html

COPY ./cronjob /etc/cron.d/app_cron
RUN chmod 644 /etc/cron.d/app_cron
RUN crontab /etc/cron.d/app_cron
```