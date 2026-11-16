# Base image
FROM node:22-alpine3.22 AS base

WORKDIR /app

# Dependencies
FROM base AS deps

COPY package.json package-lock.json ./

RUN npm ci

# Build
FROM base AS build

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

# Production dependencies
FROM base AS prod-deps

COPY package.json package-lock.json ./

RUN npm ci --omit=dev

# Production runtime
FROM node:22-alpine3.22 AS runtime

WORKDIR /app

ENV NODE_ENV=production

# Create non-root user
RUN addgroup -S nexora && \
    adduser -S nexora -G nexora

# Copy only what is required at runtime
COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/dist ./dist

# Give application user ownership
RUN chown -R nexora:nexora /app

USER nexora

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --spider --quiet "http://127.0.0.1:${PORT:-8080}/health" || exit 1

CMD ["node", "dist/main"]