#!/bin/bash

# Configurações para o 9router
# Você deve configurar a sua API_KEY no dashboard da SquareCloud
export CLAUDE_CODE_API_BASE_URL="https://protagrouter.squareweb.app/v1"

echo "Iniciando Claude-Cloud com ttyd na porta 80..."
echo "Acesse via: https://claude-cloud-ryan.squareweb.app"

# Iniciar o ttyd servindo o Claude Code
# -p 80: Porta padrão para SquareCloud
# -W: Permite escrita no terminal
# claude: O comando que inicia o Claude Code
ttyd -p 80 -W claude
