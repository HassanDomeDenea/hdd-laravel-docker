ARG PHP_VERSION=latest
FROM dunglas/frankenphp:php${PHP_VERSION}-bookworm

RUN install-php-extensions \
	pdo_mysql \
	sockets \
	gd \
	intl \
	pcntl \
 	zip \
	redis \
	gmp \
	bcmath \
	exif


SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        cron \
        curl \
        mariadb-client \
        net-tools \
        nano \
        git \
        openssh-client \
        sqlite3 \
        unzip \
        libicu-dev \
        libpng-dev \
        libzip-dev \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (LTS) from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Add bun to PATH
ENV BUN_INSTALL=/root/.bun
ENV PATH="${BUN_INSTALL}/bin:${PATH}"

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
