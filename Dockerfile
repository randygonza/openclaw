FROM node:22-bookworm

# Install essential system dependencies
RUN apt-get update && apt-get install -y socat && rm -rf /var/lib/apt/lists/*

# Set up application directory
WORKDIR /app

# Copy package files for dependency installation
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY ui/package.json ./ui/package.json
COPY patches ./patches
COPY scripts ./scripts

# Enable pnpm and install dependencies
RUN corepack enable pnpm
RUN pnpm install --frozen-lockfile

# Copy application source code
COPY . .

# Build the application with A2UI skip flag
RUN OPENCLAW_A2UI_SKIP_MISSING=1 pnpm build

# Force pnpm for UI build (Bun may fail on ARM/Synology architectures)
ENV OPENCLAW_PREFER_PNPM=1
RUN pnpm ui:build

# Set production environment
ENV NODE_ENV=production

# Allow non-root user to write temp files during runtime
RUN chown -R node:node /app

# Security hardening: Run as non-root user
USER node

# Start the application
CMD ["node","dist/index.js"]
