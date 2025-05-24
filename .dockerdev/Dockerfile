FROM ruby:3.4.4-bookworm AS sroodle-dev-base

# Install Node.js, Git and other essential packages
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install global npm packages
RUN npm install -g @anthropic-ai/claude-code
RUN npm install -g @openai/codex
