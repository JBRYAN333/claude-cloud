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

# 3. Configuração Espelhada do OpenClaw Web (conforme openclaw.json)
# Usamos as mesmas variáveis que funcionam no seu PC, mas apontando para o site.
export ANTHROPIC_BASE_URL="https://protagrouter.squareweb.app/api/v1"
export ANTHROPIC_API_KEY="clawsec_ninja_2026"

# Forçamos o Claude Code a não usar o modo de conta Pro, usando o provedor direto.
export CLAUDE_CODE_USE_KEY_AUTH=true

echo "Iniciando Claude-Cloud (Meu_Claude_PRO) via 9router Web..."
echo "Configuração: https://protagrouter.squareweb.app/api/v1"

# 4. Iniciar o ttyd servindo o Claude Code
# -W: Permite escrever (ttyd 1.7.3)
./bin/ttyd -p $PORT -W ./node_modules/.bin/claude --dangerously-skip-permissions
