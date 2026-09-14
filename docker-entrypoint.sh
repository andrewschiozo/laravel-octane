#!/bin/sh
set -e

# Se a pasta vendor não existir, instala as dependências automaticamente no primeiro boot
if [ ! -d "vendor" ]; then
    echo "=== Pasta vendor não encontrada. Instalando dependências do Composer... ==="
    composer install --no-interaction --prefer-dist --optimize-autoloader
fi

# Executa o comando principal que foi passado no CMD do Dockerfile (php artisan octane:start)
exec "$@"
