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

# 3. Configuração de Roteamento EXATA da Local (Espelhada)
export ANTHROPIC_BASE_URL="http://localhost:20128/v1"
export ANTHROPIC_API_KEY="sk_9router"

# Resetar qualquer trava de modelo para deixar o roteador decidir
unset CLAUDE_CODE_MODEL
unset ANTHROPIC_MODEL

echo "Iniciando Claude-Cloud com a configuração IDÊNTICA ao PC Local..."
echo "Conectado a: http://localhost:20128 (Requer túnel para o PC Local)"

# 4. Iniciar o ttyd servindo o Claude Code sem forçar modelo via flag
./bin/ttyd -p $PORT -W ./node_modules/.bin/claude --dangerously-skip-permissions
