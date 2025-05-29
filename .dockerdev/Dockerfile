ARG RUBY_VERSION=3.4.4
FROM node:23-bookworm AS node-source
FROM ruby:$RUBY_VERSION-bookworm AS sroodle-dev-base

# Install Node.js, Git and other essential packages for development
RUN apt-get update && apt-get install -y \
    npm \
    git \
    fd-find \
    silversearcher-ag \
    build-essential \
    curl \
    libjemalloc2 \
    libvips \
    libyaml-dev \
    pkg-config \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=node-source /usr/local/bin/node /usr/local/bin/
COPY --from=node-source /usr/local/lib/node_modules /usr/local/lib/node_modules

WORKDIR /app

# Install global npm packages for Claude Code
RUN npm install -g @anthropic-ai/claude-code
# RUN npm install -g @openai/codex

# Set development environment
ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle"

# Install Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Install Node.js dependencies
COPY package.json package-lock.json ./
RUN npm install --force

# Copy application code
COPY . .

# Create necessary directories and set permissions
RUN mkdir -p tmp/pids log storage && \
    chmod -R 755 tmp log storage
