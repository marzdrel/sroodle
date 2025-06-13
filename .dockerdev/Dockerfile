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

# Create app user and group
RUN groupadd --system --gid 1000 app && \
    useradd app --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p /usr/local/bundle && \
    chown -R app:app /usr/local/bundle

WORKDIR /app

# Install global npm packages for Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Set development environment
ENV BUNDLE_PATH="/usr/local/bundle"

# Install Ruby dependencies as app user
COPY --chown=app:app Gemfile Gemfile.lock ./
USER app
RUN bundle install
USER root

# Install Node.js dependencies
COPY --chown=app:app package.json package-lock.json ./
RUN mkdir -p /app/node_modules && chown -R app:app /app/node_modules
USER app
RUN npm install --force

# Install Tailwind CSS CLI
RUN npm install --force tailwindcss @tailwindcss/cli
USER root

# Copy application code
COPY --chown=app:app . .

# Create necessary directories and set permissions
RUN mkdir -p tmp/pids log storage db && \
    chown -R app:app tmp log storage db /app

# Switch to app user
USER app
