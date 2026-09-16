#!/bin/bash

set -e

echo "=== 1. Criando e Ativando 2GB de Memória SWAP ==="
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo "SWAP de 2GB ativado com sucesso!"
else
    echo "SWAP já existente, pulando etapa."
fi

echo "=== 2. Atualizando o sistema e instalando dependências básicas ==="
apt-get update && apt-get upgrade -y
apt-get install -y software-properties-common curl unzip git libaio-dev build-essential autoconf libtool systemd

echo "=== 3. Adicionando repositório e instalando PHP 8.5 ==="
add-apt-repository ppa:ondrej/php -y
apt-get update
apt-get install -y php8.5-cli php8.5-dev php8.5-xml php8.5-curl php8.5-zip php8.5-mbstring php8.5-intl php-pear

echo "=== 4. Instalando o Oracle Instant Client ==="
mkdir -p /opt/oracle
cd /opt/oracle
curl -o instantclient.zip https://download.oracle.com/otn_software/linux/instantclient/instantclient-basic-linuxx64.zip
curl -o instantclient-sdk.zip https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linuxx64.zip
unzip instantclient.zip
unzip -o instantclient-sdk.zip
rm instantclient.zip instantclient-sdk.zip

ORACLE_DIR=$(ls -d /opt/oracle/instantclient_*)

# Configura variáveis globais de ambiente no sistema para o Oracle
echo "export LD_LIBRARY_PATH=${ORACLE_DIR}" >> /etc/environment
echo "export ORACLE_HOME=${ORACLE_DIR}" >> /etc/environment
export LD_LIBRARY_PATH=${ORACLE_DIR}

echo "=== 5. Compilando o driver OCI8 para o PHP ==="
echo "instantclient,${ORACLE_DIR}" | pecl install oci8
echo "extension=oci8.so" > /etc/php/8.5/mods-available/oci8.ini
phpenmod oci8

echo "=== 6. Baixando o binário Standalone do FrankenPHP ==="
curl -L https://github.com -o /usr/local/bin/frankenphp
chmod +x /usr/local/bin/frankenphp

echo "=== 7. Instalando o Composer Globalmente ==="
curl -sS https://getcomposer.org | php -- --install-dir=/usr/local/bin --filename=composer

echo "=== 8. Criando o Serviço Systemd para o Laravel Octane ==="
cat << 'EOF' > /etc/systemd/system/laravel-octane.service
[Unit]
Description=Laravel Octane (FrankenPHP) Application
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/laravel
ExecStart=/usr/bin/php8.5 artisan octane:start --server=frankenphp --host=0.0.0.0 --port=8000 --admin-port=82
Restart=always
RestartSec=5
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=laravel-octane

[Install]
WantedBy=multi-user.target
EOF

# Recarrega os serviços e habilita o boot automático
systemctl daemon-reload
systemctl enable laravel-octane.service

echo "==============================================================="
echo " Configuração concluída com sucesso! "
echo " O SWAP está ativo e o Octane está pronto para o primeiro deploy. "
echo "==============================================================="
