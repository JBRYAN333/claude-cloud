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

# 3. Configuração de Roteamento para o 9router Web
# Deixamos o modelo livre para o 9router resolver qual entregar
export ANTHROPIC_BASE_URL="https://protagrouter.squareweb.app/api/v1"
export ANTHROPIC_API_KEY="clawsec_ninja_2026"

echo "Iniciando Claude-Cloud conectado ao 9router Web..."
echo "Acesse via: https://claude-cloud-ryan.squareweb.app"

# 4. Iniciar o ttyd servindo o Claude Code
./bin/ttyd -p $PORT --writable ./node_modules/.bin/claude --dangerously-skip-permissions
