#!/bin/bash

# Criar pasta para binários se não existir
mkdir -p ./bin
export PATH=$PATH:$(pwd)/bin

# 1. Baixar o ttyd se não existir (Versão 1.7.3 estável)
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
# Usamos CLAUDE_CODE_API_BASE_URL para redirecionar todo o tráfego do CLI
export CLAUDE_CODE_API_BASE_URL="https://protagrouter.squareweb.app/api/v1"
# A chave virá da variável de ambiente configurada no dashboard da SquareCloud
export ANTHROPIC_API_KEY="$CLAUDE_CODE_API_KEY"

echo "Iniciando Claude-Cloud conectado ao 9router Web..."
echo "Acesse via: https://claude-cloud-ryan.squareweb.app"

# 4. Iniciar o ttyd servindo o Claude Code
# -p $PORT: Porta da SquareCloud
# -W: Escrever no terminal (ttyd 1.7.3 usa -W)
./bin/ttyd -p $PORT -W ./node_modules/.bin/claude --dangerously-skip-permissions
