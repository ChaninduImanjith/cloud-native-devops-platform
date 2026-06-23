# ── Stage 1: Dependencies ──────────────────────────────────────────────────────
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

# ── Stage 2: Production Image ──────────────────────────────────────────────────
FROM node:20-alpine AS runner
WORKDIR /app

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy only production deps and source
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Own files as non-root user
RUN chown -R appuser:appgroup /app
USER appuser

EXPOSE 5000

# Built-in Docker healthcheck (separate from K8s probes)
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget -qO- http://localhost:5000/health/live || exit 1

CMD ["node", "server.js"]