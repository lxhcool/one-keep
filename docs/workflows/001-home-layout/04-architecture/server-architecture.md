# 服务端架构设计 — OneKeep 财务App

## 1. 领域概览

| 属性 | 值 |
|------|------|
| 技术栈 | NestJS + Fastify + Prisma + PostgreSQL + JWT |
| 部署方式 | Docker Compose + Nginx（自建服务器） |
| 关联客户端架构 | [client-architecture.md](client-architecture.md) |
| 关联 PRD | [prd.md](../02-requirements/prd.md) |

### 核心域

**记账域（Accounting）**：账单记录的创建、查询、统计，是核心业务价值所在。

### 支撑域

- **用户域（Identity）**：用户注册、登录、Profile 管理，支撑记账域的用户归属。
- **统计域（Statistics）**：月度收支汇总、分类统计，由记账域数据聚合得出（不存储，计算得出）。

### 统一术语

| 术语 | 定义 |
|------|------|
| Transaction（账单） | 一次收入或支出记录，金额以整数分（cent）存储 |
| Category（分类） | 账单所属分类（餐饮/出行/购物/工资/其他） |
| MonthlyBalance（月结余） | 某月 totalIncome - totalExpense，实时计算 |
| MonthSummary（月汇总） | 某月的 income 合计 + expense 合计 |
| UserProfile（用户信息） | 用户 ID + 展示名，v1.0 单账户模型 |

---

## 2. 限界上下文地图

| 上下文 | 责任 | 上游 | 下游 | 关系类型 |
|--------|------|------|------|----------|
| **Identity（用户）** | 注册/登录/JWT 签发/Profile | — | Accounting | 开放主机（OHS），暴露 userId |
| **Accounting（记账）** | 账单 CRUD、月度查询、分页列表 | Identity（userId） | Statistics | 核心域 |
| **Statistics（统计）** | 按月/按分类汇总，实时聚合 | Accounting（只读） | — | 防腐层（数据库视图/聚合查询） |

> v1.0 三个上下文共享单体数据库，但代码层保持模块隔离，未来可拆分。

---

## 3. 聚合与领域模型

### Identity 上下文

| 聚合根 | 不变式 | 领域事件 |
|--------|--------|---------|
| `User` | email 唯一；密码必须 bcrypt 散列存储；refreshToken 不存入 DB（只存 hash） | `UserRegistered` |

```
User {
  id: UUID (PK)
  email: string (unique)
  passwordHash: string
  displayName: string (max 20)
  createdAt: DateTime
  updatedAt: DateTime
}
```

### Accounting 上下文

| 聚合根 | 不变式 | 领域事件 |
|--------|--------|---------|
| `Transaction` | amount > 0（分，整数）；type ∈ {income, expense}；category 必须为枚举值；occurredAt 不能超过当前时间 | `TransactionCreated`、`TransactionDeleted` |

```
Transaction {
  id: UUID (PK)
  userId: UUID (FK)
  type: enum TransactionType { income, expense }
  categoryId: string (枚举值)
  amountCents: Int  // 始终正整数
  title: string (max 50)
  note: string? (max 200)
  occurredAt: DateTime
  createdAt: DateTime
  updatedAt: DateTime
}
```

### 值对象

| 值对象 | 校验规则 |
|--------|---------|
| `Money` | amountCents > 0，整数 |
| `DateRange` | start ≤ end，同月校验 |
| `TransactionCategory` | 枚举：food / transport / shopping / salary / other |

---

## 4. 应用服务与仓储接口

### Identity 模块

| 用例 | 应用服务方法 | 仓储接口 |
|------|------------|---------|
| 用户注册 | `AuthService.register(email, password, displayName)` | `UserRepository.findByEmail`, `save` |
| 用户登录 | `AuthService.login(email, password)` → `{accessToken, refreshToken}` | `UserRepository.findByEmail` |
| 刷新 Token | `AuthService.refresh(refreshToken)` | JWT 验证（无 DB 查询） |
| 获取 Profile | `UserService.getProfile(userId)` | `UserRepository.findById` |

### Accounting 模块

| 用例 | 应用服务方法 | 仓储接口 |
|------|------------|---------|
| 创建账单 | `TransactionService.create(userId, dto)` | `TransactionRepository.save` |
| 删除账单 | `TransactionService.delete(userId, id)` | `TransactionRepository.findById`, `delete`（需校验归属） |
| 分页账单列表 | `TransactionService.list(userId, year, month, filter, page)` | `TransactionRepository.findMany` |
| 近期账单（首页） | `TransactionService.recent(userId, limit)` | `TransactionRepository.findRecent` |
| 月度汇总 | `TransactionService.monthlySummary(userId, year, month)` | `TransactionRepository.aggregateByMonth` |
| 月结余 | `TransactionService.monthlyBalance(userId, year, month)` | 同上（income - expense） |
| 分类统计 | `TransactionService.categoryStats(userId, year, month)` | `TransactionRepository.aggregateByCategory` |

---

## 5. API 契约

### 认证相关

```
POST /api/auth/register
Body: { email, password, displayName }
Response: { accessToken, refreshToken, user: { id, email, displayName } }

POST /api/auth/login
Body: { email, password }
Response: { accessToken, refreshToken, user: { id, email, displayName } }

POST /api/auth/refresh
Body: { refreshToken }
Response: { accessToken, refreshToken }

POST /api/auth/logout
Header: Authorization: Bearer <accessToken>
Response: 204 No Content
```

### 用户

```
GET /api/users/me
Header: Authorization: Bearer <accessToken>
Response: { id, email, displayName, createdAt }
```

### 账单

```
POST /api/transactions
Body: { type, categoryId, amountCents, title, note?, occurredAt }
Response: Transaction

GET /api/transactions?year=2026&month=3&filter=all|income|expense&page=1&limit=20
Response: { data: Transaction[], total, page, limit }

GET /api/transactions/recent?limit=5
Response: Transaction[]

DELETE /api/transactions/:id
Response: 204 No Content
```

### 统计

```
GET /api/statistics/summary?year=2026&month=3
Response: { year, month, totalIncome, totalExpense, balance, changePercent }

GET /api/statistics/categories?year=2026&month=3&type=expense|income
Response: CategoryStat[]
```

### 响应数据结构

```typescript
// Transaction
{
  id: string;
  type: 'income' | 'expense';
  categoryId: string;
  amountCents: number;       // 正整数，单位：分
  title: string;
  note: string | null;
  occurredAt: string;        // ISO 8601
  createdAt: string;
}

// MonthlySummary
{
  year: number;
  month: number;
  totalIncome: number;       // 分
  totalExpense: number;      // 分
  balance: number;           // totalIncome - totalExpense（可负）
  changePercent: number | null;  // 与上月 balance 环比，null 表示无数据
}

// CategoryStat
{
  categoryId: string;
  total: number;             // 分
  count: number;
  percentage: number;        // 0.0 ~ 1.0
}
```

### 版本策略

- v1.0 无版本前缀，待需要时用 `/api/v2/` 前缀隔离。

### 幂等策略

- 创建账单：客户端传 `occurredAt`，服务端不做幂等（允许同时间同金额的多笔）。
- 删除账单：`DELETE` 天然幂等，404 不视为错误。

### 错误格式

```json
{
  "statusCode": 400,
  "error": "Bad Request",
  "message": "amountCents must be a positive integer",
  "timestamp": "2026-03-25T10:00:00.000Z"
}
```

---

## 6. 一致性与事务

| 用例 | 一致性 | 事务边界 | 补偿策略 |
|------|--------|---------|---------|
| 用户注册 | 强一致 | 单 DB 事务 | 注册失败直接返回 409 |
| 创建账单 | 强一致 | 单 DB 写入 | 无，客户端重试时会产生新记录 |
| 删除账单 | 强一致 | 单 DB 删除 | 404 静默处理 |
| 月度统计 | 最终一致（实时计算） | 无写入事务 | 数据库 GROUP BY 聚合，无需补偿 |

> v1.0 全部为单体 PostgreSQL，无分布式事务问题。

---

## 7. 治理与可观测性

### 认证授权

- **JWT** 双 Token 策略：`accessToken`（15min）+ `refreshToken`（30d）
- `accessToken` 存于客户端内存；`refreshToken` 存本地安全存储（Flutter SecureStorage）
- 所有 `/api/` 接口除 `auth/register`、`auth/login`、`auth/refresh` 外均需 Bearer token
- NestJS `JwtAuthGuard` 全局注册，白名单路由用 `@Public()` 装饰器跳过

### 数据安全

- 密码使用 `bcrypt`（cost=12）散列，不可逆
- SQL 注入：Prisma ORM 参数化查询，完全防护
- 跨用户访问：所有查询附带 `userId` 条件，防止越权

### 审计

- 每次请求记录：`method`、`path`、`userId`、`duration`、`statusCode`
- NestJS LoggingInterceptor 统一处理

### 监控告警

- 健康检查：`GET /api/health` → `{ status: 'ok', db: 'connected' }`
- Docker 容器 healthcheck 配置
- 后续可接 Prometheus + Grafana（当前阶段简单日志）

---

## 8. 项目结构

```
server/
├── src/
│   ├── main.ts                        # Fastify 启动入口
│   ├── app.module.ts                  # 根模块
│   ├── common/
│   │   ├── decorators/
│   │   │   ├── public.decorator.ts    # @Public() 跳过 JWT
│   │   │   └── current-user.decorator.ts
│   │   ├── filters/
│   │   │   └── http-exception.filter.ts
│   │   ├── guards/
│   │   │   └── jwt-auth.guard.ts
│   │   └── interceptors/
│   │       └── logging.interceptor.ts
│   ├── auth/
│   │   ├── auth.module.ts
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── strategies/
│   │   │   └── jwt.strategy.ts
│   │   └── dto/
│   │       ├── register.dto.ts
│   │       ├── login.dto.ts
│   │       └── refresh.dto.ts
│   ├── users/
│   │   ├── users.module.ts
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   └── users.repository.ts
│   ├── transactions/
│   │   ├── transactions.module.ts
│   │   ├── transactions.controller.ts
│   │   ├── transactions.service.ts
│   │   ├── transactions.repository.ts
│   │   ├── domain/
│   │   │   ├── transaction.entity.ts  # 纯 TS 类，不含 ORM
│   │   │   └── transaction-type.enum.ts
│   │   └── dto/
│   │       ├── create-transaction.dto.ts
│   │       └── list-transactions.dto.ts
│   ├── statistics/
│   │   ├── statistics.module.ts
│   │   ├── statistics.controller.ts
│   │   └── statistics.service.ts
│   └── prisma/
│       ├── prisma.module.ts
│       └── prisma.service.ts
├── prisma/
│   ├── schema.prisma
│   └── migrations/
├── Dockerfile
├── docker-compose.yml
├── nginx/
│   └── nginx.conf
├── .env.example
├── package.json
└── tsconfig.json
```

---

## 9. 部署架构

```
[ 公网 ]
    │
    ▼
[ Nginx :80/:443 ]  ──  SSL 终止（Let's Encrypt）
    │
    ▼
[ Docker Network ]
    ├── one-keep-api    :3000  (NestJS + Fastify)
    ├── one-keep-db     :5432  (PostgreSQL 16)
    └── one-keep-redis  :6379  (Redis，可选，用于会话黑名单)
```

## 10. 风险与待确认

| 风险 | 影响 | 对策 |
|------|------|------|
| 单用户 v1.0 无多租户隔离设计 | 未来扩展改造成本 | 所有查询均附带 userId，数据层已隔离 |
| refreshToken 被盗用 | 账户被劫持 | 后续加 Redis 实现 token 黑名单（logout 撤销） |
| 无速率限制 | 暴力破解登录接口 | v1.1 加 @nestjs/throttler 限速 |
| PostgreSQL 单点 | 数据丢失风险 | 配置 pg_dump 定期备份，存对象存储 |
