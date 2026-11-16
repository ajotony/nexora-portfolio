# Base image
FROM node:22-alpine3.22 AS base

WORKDIR /app

# Dependencies
FROM base AS deps

COPY package.json package-lock.json ./

RUN npm ci

# Build
FROM base AS build
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

# Production runtime
FROM node:22-alpine3.22 AS runtime

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Create non-root user
RUN addgroup -S nexora && \
    adduser -S nexora -G nexora

# Copy only the Next.js standalone runtime
COPY --from=build --chown=nexora:nexora /app/.next/standalone ./

# Copy static assets
COPY --from=build --chown=nexora:nexora /app/.next/static ./.next/static

# Copy public assets
COPY --from=build --chown=nexora:nexora /app/public ./public

USER nexora

EXPOSE 3000

CMD ["node", "server.js"]