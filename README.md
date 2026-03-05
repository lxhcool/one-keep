# OneKeep

OneKeep 是一个记账 App 项目，当前已包含 Flutter 客户端与 Fastify 服务端基础脚手架。

记账 App 的产品与技术规划见：

- `docs/accounting-app-plan.md`

## 项目结构

```text
.
├── client/      # Flutter 客户端
├── server/      # Fastify + Prisma 服务端
├── infra/       # 基础设施配置（Postgres docker-compose）
├── docs/        # 规划文档
├── skills/      # 各类工作流技能定义
├── README.md
└── package.json
```

## 开发命令

```bash
# 客户端
npm run dev:client
npm run analyze:client
npm run test:client

# 服务端
npm run dev:server
npm run prisma:generate
npm run prisma:migrate
```

## 说明

- 当前未创建后台管理端，按规划在后续阶段按需新增（Vue3 或 React）。
- 服务端方案已按 `Fastify + Prisma + PostgreSQL` 先行落地。
