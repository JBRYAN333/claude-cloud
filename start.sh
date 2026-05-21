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

# 3. Configuração de Roteamento para o Combo PROTAGNIX
export ANTHROPIC_BASE_URL="https://protagrouter.squareweb.app/api/v1"
export ANTHROPIC_API_KEY="clawsec_ninja_2026"

# Enganar o Claude Code para ele aceitar o modelo, mas o 9router vai processar.
# Usamos um ID que o Claude Code reconhece internamente.
export CLAUDE_CODE_MODEL="claude-3-5-sonnet-20241022"
export ANTHROPIC_MODEL="claude-3-5-sonnet-20241022"

echo "Iniciando Claude-Cloud usando máscara de Sonnet para o 9router..."
echo "Conectado a: https://protagrouter.squareweb.app"

# 4. Iniciar o ttyd servindo o Claude Code
./bin/ttyd -p $PORT -W ./node_modules/.bin/claude --model claude-3-5-sonnet-20241022 --dangerously-skip-permissions
