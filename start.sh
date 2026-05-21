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

# 3. Configuração de Roteamento EXATA da Local com Túnel Interno
export ANTHROPIC_BASE_URL="http://localhost:20128/v1"
export ANTHROPIC_API_KEY="sk_9router"

# TRUQUE DE MESTRE: Redirecionar localhost:20128 para o 9router Web
# Isso engana o Claude Code fazendo-o pensar que está no PC local.
# Instalamos o socat se necessário (via apt no Docker ou manual)
if command -v socat > /dev/null; then
    socat TCP4-LISTEN:20128,fork,reuseaddr TCP4:protagrouter.squareweb.app:443 &
else
    echo "Socat não encontrado, tentando baixar versão estática..."
    # Se não tiver socat, a gente usa a URL direta como fallback seguro para não quebrar
    export ANTHROPIC_BASE_URL="https://protagrouter.squareweb.app/api/v1"
fi

unset CLAUDE_CODE_MODEL
unset ANTHROPIC_MODEL

echo "Iniciando Claude-Cloud com Mimetismo Local..."
echo "Simulando localhost:20128 -> protagrouter.squareweb.app"

# 4. Iniciar o ttyd servindo o Claude Code (corrigido flag -W para permissão de escrita)
./bin/ttyd -p $PORT -W ./node_modules/.bin/claude --dangerously-skip-permissions
