ARG RUBY_VERSION=3.4.4
FROM node:23-bookworm AS node-source
FROM ruby:$RUBY_VERSION-bookworm AS sroodle-dev-base

# Update package lists and install essential packages for development
RUN apt-get update --allow-releaseinfo-change && apt-get install -y \
    npm \
    git \
    fd-find \
    bash \
    silversearcher-ag \
    build-essential \
    curl \
    libjemalloc2 \
    libvips42 \
    libyaml-dev \
    pkg-config \
    sqlite3 \
    libsqlite3-dev \
    libpq-dev \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

COPY --from=node-source /usr/local/bin/node /usr/local/bin/
COPY --from=node-source /usr/local/lib/node_modules /usr/local/lib/node_modules

WORKDIR /app

# Install global npm packages for Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Set development environment
ENV BUNDLE_PATH="/usr/local/bundle"

# Install Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Install Node.js dependencies
COPY package.json package-lock.json ./
RUN npm install --force

# Install Tailwind CSS CLI
RUN npm install --force tailwindcss @tailwindcss/cli

# Copy application code
COPY . .

# Create necessary directories and set permissions
RUN mkdir -p tmp/pids log storage && \
    chmod -R 755 tmp log storage
