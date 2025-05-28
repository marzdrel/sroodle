ARG RUBY_VERSION=3.4.4
FROM ruby:$RUBY_VERSION-bookworm AS sroodle-dev-base

# Install Node.js, Git and other essential packages for development
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    git \
    build-essential \
    curl \
    libjemalloc2 \
    libvips \
    libyaml-dev \
    pkg-config \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install global npm packages for Claude Code
RUN npm install -g @anthropic-ai/claude-code
RUN npm install -g @openai/codex

# Set development environment
ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle"

# Install Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Install Node.js dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy application code
COPY . .

# Create necessary directories and set permissions
RUN mkdir -p tmp/pids log storage && \
    chmod -R 755 tmp log storage

# Expose ports for each service
EXPOSE 3000 3001 3036

# Default command (can be overridden in docker-compose)
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
