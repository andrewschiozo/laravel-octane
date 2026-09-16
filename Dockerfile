FROM dunglas/frankenphp:1-php8.5-alpine

# dependências
RUN apk add --no-cache \
    curl \
    unzip \
    git \
    libaio \
    libaio-dev \
    build-base \
    autoconf \
    libtool \
    ca-certificates \
    gcompat \
    libc6-compat

RUN ln -s /lib/libc.so.6 /usr/lib/libresolv.so.2

# Oracle Instant Client
RUN mkdir -p /opt/oracle && cd /opt/oracle

WORKDIR /opt/oracle

RUN curl -o instantclient.zip https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linuxx64.zip

RUN curl -o instantclient-sdk.zip https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linuxx64.zip

RUN unzip instantclient.zip

RUN unzip -o instantclient-sdk.zip

RUN rm instantclient.zip instantclient-sdk.zip

RUN ln -s /opt/oracle/instantclient_* /opt/oracle/instantclient

# variáveis de ambiente para o driver da Oracle
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient
ENV TNS_ADMIN=/opt/oracle/instantclient/network/admin
ENV ORACLE_HOME=/opt/oracle/instantclient/

# extensão oci8 - php
RUN echo "instantclient,/opt/oracle/instantclient" | pecl install oci8

RUN docker-php-ext-enable oci8

RUN docker-php-ext-install pcntl

# composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY composer.json composer.json

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
