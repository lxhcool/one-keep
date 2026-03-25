# ─── Stage 1: Build ───────────────────────────────────────────────────────────
FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# Generate Prisma client before compiling
RUN npx prisma generate

RUN npm run build

# ─── Stage 2: Production ──────────────────────────────────────────────────────
FROM node:22-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

# Copy compiled output
COPY --from=builder /app/dist        ./dist
# Copy production node_modules (already installed in builder)
COPY --from=builder /app/node_modules ./node_modules
# Copy Prisma schema + generated client (needed at runtime)
COPY --from=builder /app/prisma      ./prisma
COPY package*.json ./

EXPOSE 3000

# Run migrations then start the server
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/main"]
