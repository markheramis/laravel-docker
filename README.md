# LARAVEL DOCKER

Is a Docker project inspired by Laravel's Sail. This project is designed to work with Laravel Projects.

## Project Objective
Is to have a custom Dockerfile I can build a new Docker files on top of featuring all the tools that is used in a day-to-day basis.
## Usage
If you're building a new project you can build your new dockerfile on top of this as follows

- For basic usage documentation, see [here](/docs/basic.md)
- For using with custom `cronjobs`, see [here](/docs/cron.md)
- For using with `supervisor` to run custom background applications, see [here](/docs/supervisor.md)
- For adding custom setup scripts before your application runs, see [here](/docs/setup.md)

## Todo
- Have an optional way to compile xdebug (maybe a separate tag exclusively for development?).
- Secure supervisor, probably not good idea to run as root. **investigate!**.
- Run cronjob not as root.
- Trim Docker Image (some package might not be useful **Investigate!**).