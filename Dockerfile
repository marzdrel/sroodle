# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t sroodle .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name sroodle sroodle

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.4
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 libyaml-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Stage for building gems - cached separately
FROM base AS gems

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems (cached when Gemfile doesn't change)
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Stage for building Node.js dependencies - cached separately
FROM base AS node_modules

# Install Node.js and npm
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y nodejs npm && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install npm dependencies (cached when package.json doesn't change)
COPY package.json package-lock.json* ./
RUN npm install --force

# Main build stage combining all dependencies
FROM base AS build

# Install packages needed for building
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git pkg-config nodejs npm && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built gems from gems stage
COPY --from=gems "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=gems /rails/Gemfile /rails/Gemfile.lock ./

# Copy built node_modules from node_modules stage
COPY --from=node_modules /rails/node_modules ./node_modules
COPY --from=node_modules /rails/package.json /rails/package-lock.json* ./

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 app && \
    useradd app --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R app:app db log storage tmp
USER 1000:1000

# Enable jemalloc for reduced memory usage and latency
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
