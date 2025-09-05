ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm-alpine

RUN apk update

# dépendances runtime
RUN apk --no-cache add nginx supervisor gmp gmp-dev icu-dev curl

# dépendances build nécessaires pour PECL
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS linux-headers

# extensions PHP de base
RUN docker-php-ext-install mysqli pdo pdo_mysql sysvsem gmp intl

# installer redis via PECL
RUN pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps

RUN apk upgrade

# installer composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# config nginx
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf

# config supervisord
COPY config/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# script de démarrage
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Fix open() nginx.pid
RUN mkdir -p /run/nginx/
