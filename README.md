# OneKeep

OneKeep 是一个记账 App 项目，当前保留 Flutter 客户端基础脚手架。

记账 App 的产品与技术规划见：

- `docs/accounting-app-plan.md`

## 项目结构

```text
.
├── client/      # Flutter 客户端
├── docs/        # 规划文档
├── skills/      # 各类工作流技能定义
├── README.md
└── package.json
```

## 开发命令

```bash
# 客户端
npm run dev:client
npm run dev:client:android-local
npm run dev:client:web-local
npm run analyze:client
npm run test:client

# 服务端
npm run dev:server
npm run dev:server:3001
npm run build:server
npm run start:server
npm run deploy:server
```

## 本地联调

当前服务端是 `TypeScript + Node.js + Fastify + Prisma`，生产运行方式是先编译到 `dist/`，再用 Node 启动。

本地联调统一使用 `3001` 端口：

- Android 模拟器默认访问宿主机 `http://10.0.2.2:3001`
- Web/Chrome 默认访问 `http://127.0.0.1:3001`

推荐启动方式：

```bash
# 1. 启动本地服务端
cd server
PORT=3001 HOST=0.0.0.0 npm start

# 2. Android 模拟器运行客户端
cd ..
npm run dev:client:android-local

# 3. Chrome 运行客户端
npm run dev:client:web-local
```

健康检查：

```bash
curl http://127.0.0.1:3001/api/health
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

当前数据库配置默认是 `SQLite`，数据库文件通常在：

```text
server/prisma/dev.db
```

如果你准备把旧版本整个删掉重新部署，但还想保留原来的数据，先备份这个文件。

### 最方便的部署方式：宝塔 Docker 管理器

如果你要尽量少手工敲命令，当前项目最省事的方式不是 `pm2`，而是直接用宝塔的 Docker/Compose。

项目里已经补好了这些文件：

- `server/Dockerfile`
- `server/docker-compose.yml`
- `server/.env.docker.example`

操作顺序如下：

#### 1. 安装宝塔 Docker 管理器

在宝塔软件商店里安装 Docker 相关组件，确保服务器已经能运行容器。

#### 2. 拉代码

```bash
cd /www/wwwroot
git clone <你的仓库地址> one-keep
cd /www/wwwroot/one-keep/server
```

#### 3. 创建 Docker 环境变量

```bash
cp .env.docker.example .env.docker
```

然后改成你自己的值：

```env
DATABASE_URL="file:/app/data/dev.db"
JWT_SECRET="换成你自己的随机字符串"
PORT=3002
HOST="0.0.0.0"
```

说明：

- `./data` 会映射到容器内 `/app/data`
- SQLite 数据会保存在宿主机 `server/data/` 目录
- 以后重建容器，数据不会丢

#### 4. 用 Docker Compose 启动

如果你在命令行操作：

```bash
cd /www/wwwroot/one-keep/server
docker compose up -d --build
```

如果你在宝塔 Docker 管理器操作：

1. 进入 Docker/Compose
2. 导入 `server/docker-compose.yml`
3. 确认工作目录是 `/www/wwwroot/one-keep/server`
4. 启动编排

首次启动时容器会自动：

- 安装依赖
- 生成 Prisma Client
- 构建 TypeScript
- 执行 `prisma db push`
- 启动服务

#### 5. 验证服务

```bash
curl http://127.0.0.1:3002/api/health
```

正常返回：

```json
{"status":"ok"}
```

#### 6. 宝塔里配反向代理和 HTTPS

再按下面“反向代理”和“HTTPS”步骤，把域名转发到：

```text
http://127.0.0.1:3002
```

#### 7. 后续更新

以后更新只要两步：

```bash
cd /www/wwwroot/one-keep
git pull

cd server
docker compose up -d --build
```

### 从零重新部署到宝塔

下面这套流程适用于：

- 你已经有服务器和宝塔面板
- 你可以删掉旧版本重新部署
- 你要重新绑定域名并走 HTTPS

#### 1. 准备域名

先在域名服务商控制台里添加解析，把接口域名指向你的服务器公网 IP。

例如你想把接口部署到：

```text
api.example.com
```

就添加一条 `A` 记录：

- 主机记录：`api`
- 记录类型：`A`
- 记录值：你的服务器公网 IP

如果你已经有旧解析，确认它也指向当前这台服务器。

#### 2. 备份旧版本

如果旧服务已经跑过，并且你要保留历史数据，先备份：

```bash
cd /旧项目路径/server
cp prisma/dev.db prisma/dev.db.backup
```

如果你不需要旧数据，这一步可以跳过。

#### 3. 删除旧项目

确认备份完成后，再删除旧版本目录。

示例：

```bash
cd /www/wwwroot
rm -rf one-keep
```

如果你打算保留旧目录作为回滚副本，不要删，直接改成别的目录名即可。

#### 4. 安装运行环境

在宝塔服务器里确认这些环境已经安装：

- `Node.js`
- `npm`
- `pm2`
- `Git`

推荐检查：

```bash
node -v
npm -v
pm2 -v
git --version
```

如果没有 `pm2`：

```bash
npm install -g pm2
```

#### 5. 拉取项目代码

选择一个新的部署目录，例如：

```bash
cd /www/wwwroot
git clone <你的仓库地址> one-keep
cd one-keep
```

如果是私有仓库，先确保服务器已经配置好 Git 凭证或 SSH Key。

#### 6. 配置服务端环境变量

进入服务端目录，确认 `.env` 存在：

```bash
cd /www/wwwroot/one-keep/server
ls -la
```

如果没有 `.env`，按下面方式创建：

```bash
cp .env.example .env
```

然后检查 `.env`，至少确认这些值：

```env
DATABASE_URL="file:./dev.db"
JWT_SECRET="换成你自己的随机字符串"
PORT=3002
HOST="0.0.0.0"
```

说明：

- `PORT=3002` 对应当前 `pm2 + Nginx` 配置最省事
- `HOST=0.0.0.0` 才能让反向代理正常访问
- `JWT_SECRET` 不要继续用默认测试值

#### 7. 首次部署服务端

执行：

```bash
cd /www/wwwroot/one-keep/server
npm run deploy
```

这个命令会自动执行：

- `npm ci`
- `npm run db:generate`
- `npm run db:push`
- `npm run build`
- `pm2 startOrReload ecosystem.config.json --update-env`

如果成功，服务会以 `one-keep-server` 进程名跑起来。

#### 8. 验证服务端是否正常

先检查 PM2：

```bash
pm2 list
pm2 logs one-keep-server
```

再做本机健康检查：

```bash
curl http://127.0.0.1:3002/api/health
```

正常返回：

```json
{"status":"ok"}
```

如果这一步不通，不要先配域名，先把本机服务跑通。

#### 9. 在宝塔创建站点

打开宝塔面板：

1. 进入“网站”
2. 添加站点
3. 域名填你的接口域名，例如 `api.example.com`
4. PHP 版本选“纯静态”或不启用 PHP
5. 站点目录可以随便指定一个空目录，例如 `/www/wwwroot/api.example.com`

这个站点的作用不是跑 PHP，而是让宝塔帮你管域名、反向代理和 SSL。

#### 10. 配置反向代理

进入刚创建的网站设置，添加反向代理，把域名转发到本地 Node 服务：

- 代理名称：`one-keep-api`
- 目标 URL：`http://127.0.0.1:3002`
- 发送域名：`$host`

如果你手动写 Nginx，示例配置如下：

```nginx
location / {
    proxy_pass http://127.0.0.1:3002;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

#### 11. 配置 HTTPS

进入宝塔站点的 SSL 页面：

1. 申请 Let's Encrypt 证书
2. 勾选强制 HTTPS
3. 保存配置

做完后，你的接口地址应该改成：

```text
https://api.example.com
```

#### 12. 客户端切换线上接口

如果你的 Flutter 客户端要指向新的线上地址，把客户端默认线上地址改成你的真实域名，或在打包时通过 `--dart-define=API_BASE_URL=` 指定。

当前项目支持这种方式：

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

#### 13. 最终验收

按下面顺序检查：

1. 浏览器打开 `https://你的域名/api/health`
2. 返回 `{"status":"ok"}`
3. 客户端可以正常登录
4. 首页、账单、分类接口都能正常返回

### 后续更新服务端

以后不需要重新部署整套环境，只需要更新代码：

```bash
cd /www/wwwroot/one-keep
git pull

cd server
npm run deploy
```

### 常用排查命令

```bash
# 查看 PM2 进程
pm2 list

# 查看服务日志
pm2 logs one-keep-server

# 查看端口监听
lsof -i :3002

# 本机健康检查
curl http://127.0.0.1:3002/api/health

# 域名健康检查
curl https://你的域名/api/health
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
cd /www/wwwroot/one-keep/server
npm run deploy
```

不要只执行 `pm2 restart`，否则可能还是旧构建产物。

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
