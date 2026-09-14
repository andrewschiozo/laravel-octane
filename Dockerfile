FROM php:8.5-cli-alpine

# dependências
RUN apk add --no-cache \
    curl \
    unzip \
    git \
    libaio \
    libaio-dev \
    build-base \
    autoconf \
    libtool

# Oracle Instant Client
RUN mkdir -p /opt/oracle && cd /opt/oracle && \
    curl -o instantclient.zip https://oracle.com && \
    curl -o instantclient-sdk.zip https://oracle.com && \
    unzip instantclient.zip && unzip instantclient-sdk.zip && \
    rm instantclient.zip instantclient-sdk.zip && \
    ln -s /opt/oracle/instantclient_* /opt/oracle/instantclient

# variáveis de ambiente para o driver da Oracle
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient
ENV TNS_ADMIN=/opt/oracle/instantclient/network/admin

# extensão oci8 - php
RUN echo "instantclient,/opt/oracle/instantclient" | pecl install oci8 && \
    docker-php-ext-enable oci8

# composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/laravel

# tráfego
EXPOSE 8000
# admin
EXPOSE 82

# entrypoint p/ composer install
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

# start octane
CMD ["php", "artisan", "octane:start", "--server=frankenphp", "--host=0.0.0.0", "--port=8000", "--admin-port=82", "--watch"]
