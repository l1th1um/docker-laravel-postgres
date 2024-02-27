FROM php:8.1.21-fpm-alpine3.18

RUN apk update \
    && apk add --no-cache supervisor zip libzip-dev libpq-dev pcre-dev $PHPIZE_DEPS \
    && pecl install redis \
    && docker-php-ext-enable redis.so \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip pdo pdo_pgsql

RUN mkdir -p "/etc/supervisor/logs"

COPY supervisord.conf /etc/supervisor/supervisord.conf
CMD ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisor/supervisord.conf"]