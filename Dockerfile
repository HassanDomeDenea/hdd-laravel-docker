ARG PHP_VERSION=latest
FROM dunglas/frankenphp:${PHP_VERSION}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        cron \
        curl \
        git \
        sqlite3 \
        unzip \
        libicu-dev \
        libpng-dev \
        libzip-dev \
    && docker-php-ext-install \
        intl \
        pdo_mysql \
        zip \
        gd \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www

COPY scripts /opt/scripts
RUN chmod +x /opt/scripts/*.sh
