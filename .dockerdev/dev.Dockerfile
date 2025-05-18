FROM node:20-bookworm AS sroodle-base
WORKDIR /app

FROM sroodle-base AS sroodle-development

RUN npm install -g @anthropic-ai/claude-code
