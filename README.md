# OneKeep

OneKeep 是一个个人记账 App 项目，包含 Flutter 客户端、Node.js/Fastify 服务端、Web 官网入口和部署脚本。项目当前以“厘清”应用形态交付，支持本地开发、Web/Android 调试和生产环境部署。

## 功能说明

- 个人收支记账与分类管理。
- Flutter 多端客户端，支持 Android 与 Web 调试运行。
- 服务端 API，基于 Fastify、Prisma 和 SQLite。
- 官网首页、隐私政策和应用静态资源。
- 本地联调、生产构建和服务器部署脚本。

## 项目结构

```text
.
├── source/       # 源代码规范入口与现有源码目录映射说明
├── docs/         # 项目文档
├── assets/       # 数字原始资产归档入口
├── client/       # Flutter 客户端
├── server/       # 服务端 (Fastify + Prisma + SQLite)
├── scripts/      # 构建、部署和文档生成脚本
├── README.md     # 项目介绍、功能、部署和使用说明
└── package.json  # 根项目命令入口
```

当前为了保持既有构建和部署脚本稳定，客户端、服务端源码仍分别位于 `client/` 和 `server/`。规范目录职责见 `docs/project-structure.md`。

## 环境要求

- Node.js 20+
- npm
- Flutter SDK
- Android Studio 或 Chrome，用于客户端调试
- 生产部署需要 SSH、PM2、Nginx/宝塔面板和可用服务器

## 线上环境

| 项目 | 信息 |
|---|---|
| **服务器** | 通过本地环境变量 `SERVER_HOST` 配置，建议使用 SSH 密钥登录 |
| **域名** | `https://liqing.eatdesk.net` |
| **官网目录** | `/www/wwwroot/liqing.eatdesk.net/client/` |
| **服务端目录** | `/www/wwwroot/liqing.eatdesk.net/server/` |
| **服务端进程** | PM2：`one-keep-server` |
| **服务端端口** | 3002 |
| **数据库** | SQLite |
| **SSL** | 宝塔面板管理 (Let's Encrypt) |
| **Nginx** | 宝塔面板管理，反向代理到 `http://127.0.0.1:3002` |

### 官网代码位置

- 官网首页：`client/web/index.html`
- 隐私政策：`client/web/privacy.html`
- Flutter Web/App 主代码：`client/lib/`

## 开发命令

在项目根目录执行：

```bash
# 客户端
npm run dev:client
npm run dev:client:android-local
npm run dev:client:web-local
npm run analyze:client
npm run test:client

# 服务端
npm run dev:server
npm run dev:server:3002
npm run build:server
npm run start:server
npm run deploy:server
```

## 使用方法

### 启动客户端

```bash
npm run dev:client
```

### 运行客户端测试

```bash
npm run test:client
```

### 启动服务端

```bash
npm run dev:server
```

### 构建服务端

```bash
npm run build:server
```

## 本地联调

当前服务端是 `TypeScript + Node.js + Fastify + Prisma`，生产运行方式是先编译到 `dist/`，再用 Node 启动。

本地联调统一使用 `3002` 端口：

- Android 模拟器默认访问宿主机 `http://10.0.2.2:3002`
- Web/Chrome 默认访问 `http://127.0.0.1:3002`

推荐启动方式：

```bash
# 1. 启动本地服务端
cd server
PORT=3002 HOST=0.0.0.0 npm start

# 2. Android 模拟器运行客户端
cd ..
npm run dev:client:android-local

# 3. Chrome 运行客户端
npm run dev:client:web-local
```

健康检查：

```bash
curl http://127.0.0.1:3002/api/health
```

正常返回：

```json
{"status":"ok"}
```

## 服务端部署

当前服务端是 `TypeScript + Node.js + Fastify + Prisma`，生产运行方式是：

1. 用 `npm run build` 编译到 `server/dist/`
2. 用 `node dist/server.js` 启动
3. 用 `pm2` 托管进程
4. 用宝塔网站/Nginx 做域名和 HTTPS

### 一键更新

本项目提供两个本地脚本：

```bash
# 前端：本地打包并上传 web 静态文件
npm run deploy:client:prod

# 后端：同步 server/，在服务器上 npm ci、build、pm2 restart
npm run deploy:server:prod
```

如果服务器还没配 SSH key，可以临时带密码执行：

```bash
SERVER_PASSWORD='你的服务器密码' npm run deploy:client:prod
SERVER_PASSWORD='你的服务器密码' npm run deploy:server:prod
```

如果后端改了 Prisma schema，需要把 `db push` 一起执行：

```bash
DB_PUSH=1 SERVER_PASSWORD='你的服务器密码' npm run deploy:server:prod
```

脚本默认使用这些环境变量，必要时可以覆盖：

```bash
SERVER_USER=root
SERVER_HOST=<your-server-host>
API_BASE_URL=https://liqing.eatdesk.net
SERVER_PATH=/www/wwwroot/liqing.eatdesk.net/client/
PM2_APP_NAME=one-keep-server
```

后端脚本默认同步到：

```text
/www/wwwroot/liqing.eatdesk.net/server/
```

部署后建议检查：

```bash
curl https://liqing.eatdesk.net/api/health
```

注意：当前这台 CentOS 7 服务器上默认 `node` 可能有兼容问题，脚本已经强制使用 `/usr/local/nodejs20/bin`，不要手工依赖系统默认 `node`。

### 常用排查命令

```bash
# 域名健康检查
curl https://liqing.eatdesk.net/api/health

# 查看 PM2 进程
ssh root@$SERVER_HOST "pm2 list"

# 查看服务日志
ssh root@$SERVER_HOST "pm2 logs one-keep-server --lines 50"

# 查看端口监听
ssh root@$SERVER_HOST "lsof -i :3002"

# 服务器本机健康检查
ssh root@$SERVER_HOST "curl http://127.0.0.1:3002/api/health"
```

### 常见问题

#### 1. 域名可以打开，但接口 502

通常是下面几种情况：

- Node 服务没启动
- PM2 进程挂了
- 反向代理目标端口写错了
- 服务没监听在 `0.0.0.0`

优先检查：

```bash
pm2 list
pm2 logs one-keep-server
curl http://127.0.0.1:3002/api/health
```

#### 2. 登录失败，但健康检查正常

优先检查：

- `.env` 是否正确
- `JWT_SECRET` 是否改过
- 数据库文件是否还在
- `server/prisma/dev.db` 是否被删掉了

#### 3. 更新后接口字段不一致

执行一次完整部署：

```bash
cd /www/wwwroot/liqing.eatdesk.net/server
npm run deploy
```

不要只执行 `pm2 restart`，否则可能还是旧构建产物。

## 版本管理规范

- 提交信息应准确描述本次修改内容，建议使用规范化提交格式，例如 `feat: 新增记账分类管理`、`fix: 修复登录接口异常`、`docs: 更新项目说明文档`。
- 依赖目录、缓存、构建产物、临时文件、本地环境变量和敏感信息必须通过 `.gitignore` 过滤。
- 项目文档放入 `docs/`，数字原始资产放入 `assets/`，运行时资源保留在对应工程目录。

## Skills 作用

`skills/` 目录是工作流技能库，用来把“页面分析 → 需求文档 → 开发实现”这条链路标准化。

所有 skill 都支持两种使用方式：

- **独立使用**：按当前任务只调用某一个 skill（例如仅做 PRD、仅做代码审查）。
- **串联使用**：按阶段把多个 skill 连起来，做完整端到端交付。

- `$ui-layout-analyzer`：分析截图、设计稿、MasterGo 地址、Pencli 地址或页面链接，输出页面结构、功能点、组件拆分和组件匹配检查。
- `$product-requirement-writer`：根据页面分析生成详细需求文档，按“服务端需求在前、客户端需求在后”组织。
- `$business-implementation-builder`：根据需求文档执行开发，可只做服务端、只做客户端，或补联调记录。
- `$generic-workflow-orchestrator`：编排完整三阶段流程，并统一把结果写入 `docs/<task-id>/`。

## Skills 使用说明

### 1. 初始化任务目录

开始一轮实验前，先初始化文档目录：

```bash
./skills/generic-workflow-orchestrator/scripts/init_workflow_docs.sh 20260326-home home
```

生成后的目录结构如下：

```text
docs/<task-id>/
	01-ui-analysis/
	02-requirements/
	03-development/
	97-workflow/
	99-decisions/
```

### 2. 第一阶段常用输入方式

第一阶段使用 `$ui-layout-analyzer`，当前支持以下输入：

- 本地截图
- Figma 导出图
- MasterGo 设计稿地址
- Pencli 设计稿地址
- 页面链接

常用提示词模板如下。

#### 2.1 截图输入

```text
使用 $ui-layout-analyzer 分析 ui/home.png，输出页面结构、功能点、组件拆分、组件匹配检查表、交互状态和待确认问题，并写入 docs/20260326-home/01-ui-analysis/pages/home.md。
```

#### 2.2 MasterGo 链接输入

```text
使用 $ui-layout-analyzer 分析这个 MasterGo 设计稿地址，输出页面结构、功能点、组件拆分、组件匹配检查表、交互状态和待确认问题，并写入 docs/20260326-home/01-ui-analysis/pages/home.md。如果在线内容不足以完整判断页面细节，请明确缺失项。
```

#### 2.3 Pencli 链接输入

```text
使用 $ui-layout-analyzer 分析这个 Pencli 设计稿地址，输出页面结构、功能点、组件拆分、组件匹配检查表、交互状态和待确认问题，并写入 docs/20260326-home/01-ui-analysis/pages/home.md。如果在线内容不足以完整判断页面细节，请明确缺失项。
```

### 3. 第二阶段：生成需求文档

适合在页面分析完成后，整理正式需求文档。输出会写入：

- `docs/<task-id>/02-requirements/requirements.md`
- `docs/<task-id>/02-requirements/interaction-spec.md`

```text
使用 $product-requirement-writer 基于 docs/20260326-home/01-ui-analysis 的分析结果生成详细需求文档，先写服务端需求，再写客户端需求，并输出到 docs/20260326-home/02-requirements。
```

### 4. 第三阶段：开发实现

开发阶段支持三种模式：

- 只做服务端
- 只做客户端
- 双端联调

输出会写入：

- `docs/<task-id>/03-development/server-implementation.md`
- `docs/<task-id>/03-development/client-implementation.md`
- `docs/<task-id>/03-development/integration-notes.md`

#### 4.1 只做服务端

```text
使用 $business-implementation-builder 基于 docs/20260326-home/02-requirements 的需求，只执行服务端开发方案，并输出到 docs/20260326-home/03-development/server-implementation.md，同时在联调记录里写明客户端暂不开发的原因和后续条件。
```

#### 4.2 只做客户端

```text
使用 $business-implementation-builder 基于 docs/20260326-home/02-requirements 的需求，只执行客户端开发方案，若服务端尚未完成，请明确当前使用 mock 数据或契约文档，并输出到 docs/20260326-home/03-development/client-implementation.md。
```

#### 4.3 双端联调

```text
使用 $business-implementation-builder 基于 docs/20260326-home/02-requirements 的需求，完成服务端实现、客户端实现和联调记录，并输出到 docs/20260326-home/03-development。
```

### 5. 串联使用（完整流程）

适合“从页面到实现再到测试”的完整交付。

```text
使用 $generic-workflow-orchestrator 执行完整流程，task-id=20260326-home，page-slug=home，第一阶段输入是 MasterGo 设计稿地址。
```

说明：

- 编排器会按阶段串联多个 skill。
- 每个阶段结束会等待你确认，再进入下一阶段。
- 阶段 1 会执行组件匹配检查：优先复用现有组件，不能复用的组件明确标记为“需开发”。
- 阶段 3 可按依赖关系选择只做服务端、只做客户端，或同时联调。

### 6. 每个 skill 的建议输入材料

下面这份清单可作为开工前的准备项（最少输入 + 推荐补充）：

| Skill | 最少输入（必备） | 推荐补充（可选） |
| --- | --- | --- |
| `$ui-layout-analyzer` | 页面截图、MasterGo 地址、Pencli 地址、导出图或页面链接 | 目标设备、设计约束、已有组件规范 |
| `$product-requirement-writer` | 页面分析结果（`01-ui-analysis/pages/*.md`） | 业务目标、用户角色、成功指标、范围边界 |
| `$business-implementation-builder` | 已确认需求文档、实现目标 | 代码仓库现状、是否只做服务端/客户端、mock 方案、接口依赖 |
| `$generic-workflow-orchestrator` | `task-id`、`page-slug`、本轮目标、页面输入材料 | 参与人分工、阶段确认规则、里程碑日期 |

使用建议：

- 输入不全时可先跑，但要把假设落到文档中。
- 同一个迭代里，需求编号建议固定不变，便于跨阶段追踪。
- 如果只做某一阶段，优先使用对应单 skill；全流程再用 orchestrator。
- 若第一阶段输入是在线设计稿链接，但无法直接看到完整视觉内容，补一张关键页面截图即可继续。

### 7. 当前推荐实验顺序

如果你第一次试这套流程，建议按下面顺序走：

1. 初始化任务目录。
2. 用 `$ui-layout-analyzer` 跑一个页面。
3. 用 `$product-requirement-writer` 生成需求文档。
4. 根据场景选择只做服务端、只做客户端，或继续双端联调。

## 说明

- 当前保留的是 Flutter 客户端基础脚手架。
- 当前 `skills/` 已收敛为通用三阶段流程，不再包含旧的 DDD、后台和审查类独立技能。
