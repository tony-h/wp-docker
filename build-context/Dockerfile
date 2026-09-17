FROM wordpress:6-php8.3-apache

ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        sudo less nano git unzip openssl; \
    pecl install redis; \
    docker-php-ext-enable redis; \
    curl -fSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp; \
    chmod +x /usr/local/bin/wp; \
    apt-get autoremove -y; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Enable Apache modules and generate SSL
RUN a2enmod rewrite expires ssl headers && \
    mkdir -p /etc/apache2/certs && \
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
    -keyout /etc/apache2/certs/ssl-cert.key \
    -out /etc/apache2/certs/ssl-cert.pem \
    -subj "/C=GB/ST=London/L=London/O=IT/CN=localhost"

# Copy configurations and the custom parser into the image
COPY apache/site.conf /etc/apache2/sites-available/000-default.conf
COPY apache/php-overrides.ini /usr/local/etc/php/conf.d/php-overrides.ini
COPY wp-env-parser.php /usr/local/etc/wp-env-parser.php
