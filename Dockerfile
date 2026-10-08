# Stage 1: Production Base
FROM node:20-alpine

# Set working directory inside container
WORKDIR /app

# Set environment variables
ENV NODE_ENV=production \
    PORT=3000 \
    APP_VERSION=1.0.0

# Install dependencies first (layer caching)
COPY package*.json ./
RUN npm ci --only=production --ignore-scripts

# Copy source code and static assets
COPY src/ ./src/
COPY public/ ./public/

# Create a non-root user for security
USER node

# Expose application port
EXPOSE 3000

# Health check configuration
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Start the application
CMD ["node", "src/server.js"]
