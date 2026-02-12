ARG PHP_VERSION=latest
FROM dunglas/frankenphp:php${PHP_VERSION}

RUN mv /usr/bin/xz /usr/bin/xz.orig && \
    echo '#!/bin/sh' > /usr/bin/xz && \
    echo 'exec /usr/bin/xz.orig --no-sandbox "$@"' >> /usr/bin/xz && \
    chmod +x /usr/bin/xz && \
    install-php-extensions \
	pdo_mysql \
	sockets \
	gd \
	intl \
	pcntl \
 	zip \
	redis \
	gmp \
	bcmath \
	exif && \
    mv /usr/bin/xz.orig /usr/bin/xz


SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        cron \
        curl \
        mariadb-client \
        net-tools \
        git \
        openssh-client \
        sqlite3 \
        unzip \
        libicu-dev \
        libpng-dev \
        libzip-dev \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /var/lib/apt/lists/*



# Configure SSH for git operations
RUN mkdir -p /root/.ssh \
    && chmod 700 /root/.ssh \
    && ssh-keyscan github.com >> /root/.ssh/known_hosts \
    && ssh-keyscan gitlab.com >> /root/.ssh/known_hosts \
    && ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts \
    && chmod 644 /root/.ssh/known_hosts

WORKDIR /var/www

COPY scripts /opt/scripts
RUN chmod +x /opt/scripts/*.sh
