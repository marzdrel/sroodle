ARG RUBY_VERSION=3.4.4
FROM node:23-alpine AS node-source
FROM ruby:$RUBY_VERSION-alpine AS sroodle-dev-base

# Install Node.js, Git and other essential packages for development
RUN apk add --no-cache \
    npm \
    git \
    fd \
    bash \
    the_silver_searcher \
    build-base \
    curl \
    jemalloc \
    vips \
    yaml-dev \
    pkgconfig \
    sqlite \
    sqlite-dev \
    postgresql-dev \
    tzdata

COPY --from=node-source /usr/local/bin/node /usr/local/bin/
COPY --from=node-source /usr/local/lib/node_modules /usr/local/lib/node_modules

WORKDIR /app

# Install global npm packages for Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Set development environment
ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle"

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
