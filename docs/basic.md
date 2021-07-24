#### Basic Usage

in your Dockerfile

```bash
FROM wendyourway/laravel-docker:latest

COPY . /var/www/html

# Do something else here for your customize needs
```

and then in your `docker-compose.yml` file do this

```yml
laravel.test:
    container_name: laravel_app
    build:
      context: ./
      dockerfile: Dockerfile
      args:
        WWWGROUP: "${WWWGROUP}"
    image: laravel/my-laravel-project
    privileged: false
    security_opt:
      - no-new-privileges:true
    ports:
      - ${APP_HTTP_PORT:-80}:80
    environment:
      WWWUSER: "${WWWUSER}"
      LARAVEL_SAIL: 1
    volumes:
      - .:/var/www/html
    networks:
      - laravel_network
    healthcheck:
      test: "curl --fail -s http://127.0.0.1:80/ || exit 1"
      interval: 1m30s
      timeout: 10s
      retries: 3
```

Notice in the `laravel.test` > `build` > `context` is set to root, if you're using [Laravel Sail](https://github.com/laravel/sail) the value is `./vendor/laravel/sail/runtimes/8.0`, we just change it to use our own Dockerfile instead.