ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-fpm-alpine

RUN apk update

#RUN apk --no-cache add php8 php8-fpm php8-json php8-openssl php8-curl php8-iconv php8-pdo_mysql \
#    php8-zlib php8-xml php8-phar php8-intl php8-dom php8-xmlreader php8-ctype php8-session \
#    php8-mbstring php8-gd php8-simplexml php8-xmlwriter php8-tokenizer nginx supervisor curl

RUN apk --no-cache add nginx supervisor

# Add php extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql sysvsem gmp

RUN apk upgrade

#RUN apk --no-cache add php8-pecl-amqp php-zip

# Configure nginx
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf

# PHP8 symbolic link
#RUN ln -s /usr/bin/php8 /usr/bin/php

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Configure PHP-FPM
#COPY config/php/fpm-pool.conf /usr/local/etc/php/php-fpm.d/zzz_custom.conf
#COPY config/php/php.ini /usr/local/etc/php/conf.d/zzz_custom.ini

# Copy run script
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure supervisord
COPY config/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Fix open() nginx.pid
RUN mkdir -p /run/nginx/
