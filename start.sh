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

# 3. Replicar a configuração do seu PC para o Claude-Cloud
# Trocamos o localhost pelo seu 9router da Web
export ANTHROPIC_BASE_URL="https://protagrouter.squareweb.app/v1"
export ANTHROPIC_API_KEY="sk_9router"
export CLAUDE_CODE_MODEL="Meu_Claude_PRO"

echo "Iniciando Claude-Cloud (Meu_Claude_PRO) via 9router Web..."
echo "Acesse via: https://claude-cloud-ryan.squareweb.app"

# 4. Iniciar o ttyd servindo o Claude Code
# --writable: Permite digitar
# --dangerously-skip-permissions: Pula termos de uso para abrir direto
./bin/ttyd -p $PORT --writable ./node_modules/.bin/claude --dangerously-skip-permissions
