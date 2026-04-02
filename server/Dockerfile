FROM node:20-bookworm-slim

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY tsconfig.json ./
COPY prisma ./prisma
COPY src ./src
COPY scripts ./scripts
COPY docker-entrypoint.sh ./docker-entrypoint.sh

RUN npm run db:generate
RUN npm run build
RUN chmod +x /app/docker-entrypoint.sh

EXPOSE 3002

ENTRYPOINT ["/app/docker-entrypoint.sh"]
