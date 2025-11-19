# syntax=docker/dockerfile:1.6

FROM php:8.2-cli AS build

ENV APP_ENV=prod \
    APP_DEBUG=0

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    libicu-dev \
    libpq-dev \
    libzip-dev \
    unzip \
 && docker-php-ext-configure intl \
 && docker-php-ext-install intl opcache pdo_pgsql zip \
 && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY composer.json composer.lock symfony.lock ./
RUN composer install --no-dev --no-scripts --no-progress --no-interaction --prefer-dist

COPY . .
RUN composer install --no-dev --optimize-autoloader --no-progress --no-interaction --prefer-dist

FROM php:8.2-apache AS runtime

ENV APP_ENV=prod \
    APP_DEBUG=0 \
    APACHE_DOCUMENT_ROOT=/var/www/html/public

RUN apt-get update && apt-get install -y --no-install-recommends \
    libicu-dev \
    libpq-dev \
    libzip-dev \
 && docker-php-ext-configure intl \
 && docker-php-ext-install intl opcache pdo_pgsql zip \
 && a2enmod rewrite \
 && rm -rf /var/lib/apt/lists/*

RUN sed -ri "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/000-default.conf /etc/apache2/apache2.conf

COPY --from=build /app /var/www/html

WORKDIR /var/www/html
RUN mkdir -p var/cache var/log && chown -R www-data:www-data var

COPY docker/entrypoint.sh /usr/local/bin/backend-entrypoint
RUN chmod +x /usr/local/bin/backend-entrypoint

EXPOSE 8080

ENTRYPOINT ["backend-entrypoint"]

