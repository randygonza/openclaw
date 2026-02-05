FROM node:22-bookworm

# Install only essential system dependencies
RUN apt-get update && apt-get install -y socat && rm -rf /var/lib/apt/lists/*

# Set up application directory
WORKDIR /app

# Copy package files for dependency installation
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY ui/package.json ./ui/package.json
COPY scripts ./scripts

# Enable pnpm and install dependencies
RUN corepack enable
RUN pnpm install --frozen-lockfile

# Copy application source code
COPY . .

# Build the application
RUN pnpm build
RUN pnpm ui:install
RUN pnpm ui:build

# Set production environment
ENV NODE_ENV=production

# Start the application
CMD ["node","dist/index.js"]
