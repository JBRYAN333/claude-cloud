FROM node:20-slim

# Instalar ttyd e dependências de rede
RUN apt-get update && apt-get install -y \
    ttyd \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instalar Claude Code globalmente
RUN npm install -g @anthropic-ai/claude-code

COPY . .

EXPOSE 80

CMD ["bash", "start.sh"]
