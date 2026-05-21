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

# 3. Configuração de Roteamento (Padrão 9router Cloud)
export ANTHROPIC_BASE_URL="https://protagrouter.squareweb.app/api/v1"
export ANTHROPIC_API_KEY="clawsec_ninja_2026"

# Limpar variáveis de modelo para deixar o Claude pedir o padrão (Opus)
# O 9router deve estar configurado para mapear 'claude-3-opus-20240229' ou similar
# para o seu combo protagnix.
unset CLAUDE_CODE_MODEL
unset ANTHROPIC_MODEL

echo "Iniciando Claude-Cloud com chave oficial e modelo padrão..."
echo "Conectado a: https://protagrouter.squareweb.app"

# 4. Iniciar o ttyd sem forçar modelo via flag
./bin/ttyd -p $PORT ./node_modules/.bin/claude --dangerously-skip-permissions
