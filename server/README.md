# OneKeep Server

Fastify + Prisma 的记账服务端骨架。

## 快速开始

1. 安装依赖：

```bash
npm install --prefix server
```

2. 准备环境变量：

```bash
cp server/.env.example server/.env
```

3. 启动本地 Postgres（自行准备，或用 Docker）。

4. 生成 Prisma Client 并迁移：

```bash
npm run prisma:generate --prefix server
npm run prisma:migrate --prefix server
```

5. 启动开发服务：

```bash
npm run dev --prefix server
```

## API

- `GET /health`
- `GET /transactions`
- `POST /transactions`
