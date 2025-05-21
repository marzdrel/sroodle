# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Setup and Installation

```bash
# Install dependencies
bundle install
npm install

# Setup database
bin/rails db:setup
```

### Development

```bash
# Start development servers
bin/dev           # Uses Foreman to start all development processes

# Or start each process individually:
bin/rails server  # Start Rails server
bin/rails tailwindcss:watch  # Watch and compile Tailwind CSS
bin/vite dev      # Start Vite development server

# Using Docker
docker-compose up # Start the development environment in Docker
```

### Testing

```bash
# Run all tests
bin/rails test

# Run specific tests
bin/rails test test/controllers/polls_controller_test.rb
bin/rails test test/controllers/polls_controller_test.rb:10  # Run a specific test line

# Run system tests
bin/rails test:system
```

### Linting and Type Checking

```bash
# Ruby linting
bundle exec rubocop
bundle exec rubocop -a  # Auto-correct issues

# Security check
bundle exec brakeman

# TypeScript type checking
npm run check       # Full type checking (stricter, may show errors)
npm run check:ci    # CI-friendly type checking (less strict)

# JavaScript/TypeScript linting
npm run lint      # Check for linting issues
npm run lint:fix  # Fix linting issues automatically

# Frontend Testing
npm run test           # Run all tests once
npm run test:watch     # Run tests in watch mode (great for development)
npm run test:coverage  # Generate test coverage report
```

### Building and Deployment

```bash
# Assets precompilation
bin/rails assets:precompile

# Deployment (using Kamal)
bundle exec kamal deploy
```

## Architecture Overview

This is a Rails 8 application that uses:

1. **Rails 8** as the backend framework
2. **Inertia.js** for creating a SPA-like experience without building an API
3. **React** with TypeScript for frontend components
4. **Vite** for frontend bundling and HMR
5. **Tailwind CSS** for styling
6. **shadcn/ui** for UI components
7. **ESLint** for JavaScript/TypeScript code quality
8. **Vitest & Testing Library** for React component testing
9. **SQLite** for the database

### Key Components

1. **Inertia Integration**
   - Controllers render Inertia responses with `render inertia: Component, props: {}`
   - React components are loaded through Vite and Inertia
   - Pages are located in `app/javascript/pages/`

2. **Frontend Structure**
   - Frontend code is in `app/javascript/`
   - Pages are in `app/javascript/pages/`
   - Components are in `app/javascript/components/`
   - Entry points are in `app/javascript/entrypoints/`

3. **Main Application Flow**
   - Routes are defined in `config/routes.rb`
   - The root route points to `polls#new`
   - Controllers use Inertia to render React components
   - Layout component in `app/javascript/pages/Layout.tsx` provides the common UI structure

4. **Styling**
   - Uses Tailwind CSS with custom theme configuration
   - CSS is configured in `app/assets/tailwind/application.css`
   - shadcn/ui components are used for UI elements

5. **Database**
   - Uses SQLite for all environments
   - In production, uses separate databases for different concerns (main, cache, queue, cable)

6. **Docker Setup**
   - Development environment can be run in Docker using docker-compose
   - Configuration in `docker-compose.yml` and `.dockerdev` directory

When working with this codebase, follow the established patterns for:
1. Adding new Inertia pages in the appropriate directories
2. Using shadcn/ui components for UI elements
3. Following the Rails conventions for controllers and models
4. Using TypeScript for type safety in the frontend code
5. Make sure to remove all trailing spaces at the end of lines (ESLint will enforce this).
6. Always add a new line at the end of all files (ESLint will enforce this for JavaScript/TypeScript files).

### Testing Guidelines

1. **React Component Testing**
   - Place tests in the `app/javascript/__tests__` directory mirroring the component structure
   - Use the `renderWithInertia` utility for Inertia.js components
   - Test both success and error states
   - Follow the Testing Trophy approach: fewer unit tests, more integration tests
   - Use Testing Library queries that reflect how users interact with the UI

2. **Rails Testing**
   - Follow Rails conventions for controller and model tests
   - Use fixtures for test data
   - Favor integration and system tests over unit tests for greater confidence