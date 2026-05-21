#!/bin/bash

# Criar pasta para binários se não existir
mkdir -p ./bin
export PATH=$PATH:$(pwd)/bin

# 1. Baixar o ttyd se não existir
if [ ! -f "./bin/ttyd" ]; then
    echo "Baixando ttyd..."
    curl -L https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 -o ./bin/ttyd
    chmod +x ./bin/ttyd
fi

# 2. Instalar o Claude Code localmente se não existir
if [ ! -f "./node_modules/.bin/claude" ]; then
    echo "Instalando Claude Code..."
    npm install @anthropic-ai/claude-code
fi

# 3. Configurações para o 9router
export CLAUDE_CODE_API_BASE_URL="https://protagrouter.squareweb.app/v1"

echo "Iniciando Claude-Cloud com ttyd na porta $PORT..."
echo "Acesse via: https://claude-cloud-ryan.squareweb.app"

# 4. Iniciar o ttyd servindo o Claude Code
# Usamos o caminho direto para o binário do claude instalado via npm
./bin/ttyd -p $PORT -W ./node_modules/.bin/claude
