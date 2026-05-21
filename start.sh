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

# 3. Configuração de Roteamento (Espelhada do PC Local)
export ANTHROPIC_BASE_URL="http://localhost:20128/v1"
export ANTHROPIC_API_KEY="sk_9router"

# Forçar o modelo que o roteador web retornou na lista
# e que o Claude Code aceita (usando o ID oficial do Opus 4)
export CLAUDE_CODE_MODEL="claude-3-opus-20240229"
export ANTHROPIC_MODEL="claude-3-opus-20240229"

echo "Iniciando Claude-Cloud com configuração LOCAL..."
echo "Se estiver na nuvem, este endereço (localhost) precisa estar acessível!"

# 4. Iniciar o ttyd (comando limpo)
./bin/ttyd -p $PORT ./node_modules/.bin/claude --model claude-3-opus-20240229 --dangerously-skip-permissions
