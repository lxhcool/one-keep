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

如果你在宝塔上部署的是 Node 项目，推荐不要手动一条条执行安装、构建、重启命令，而是统一用项目自带的一键部署脚本：

```bash
cd /你的项目路径/server
npm run deploy
```

这个命令会自动执行：

- `npm ci`
- `npm run db:generate`
- `npm run db:push`
- `npm run build`
- `pm2 startOrReload ecosystem.config.json --update-env`

如果服务器上还没有 `pm2`，先安装一次：

```bash
npm install -g pm2
```

在宝塔里，后续更新服务端时只需要：

1. 拉取最新代码
2. 进入 `server/`
3. 执行 `npm run deploy`

如果你希望把这一步再简化，可以直接把宝塔的“项目启动命令”或“部署脚本”配置成：

```bash
cd /你的项目路径/server && npm run deploy
```

### 宝塔配置建议

#### 1. Node 项目启动命令

如果你在宝塔里用 PM2 管理这个服务，推荐使用下面的启动命令：

```bash
cd /你的项目路径/server && npm run deploy
```

如果你更倾向于把“部署”和“启动”拆开，也可以这样配置：

```bash
cd /你的项目路径/server
npm ci
npm run db:generate
npm run db:push
npm run build
pm2 startOrReload ecosystem.config.json --update-env
```

#### 2. 反向代理

推荐让宝塔网站或 Nginx 反向代理到 Node 服务端口，例如 `3000`。

示例：

```nginx
location / {
    proxy_pass http://127.0.0.1:3000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

如果你后续把服务改到别的端口，比如 `3001`，这里只需要同步改 `proxy_pass`。

#### 3. 更新流程

后续在宝塔上更新服务端，建议固定成下面这套流程：

1. 在项目目录执行 `git pull`
2. 进入 `server/`
3. 执行 `npm run deploy`
4. 用 `pm2 logs one-keep-server` 检查启动日志

#### 4. 常用排查命令

```bash
# 查看 PM2 进程
pm2 list

# 查看服务日志
pm2 logs one-keep-server

# 查看端口监听
lsof -i :3000

# 健康检查
curl http://127.0.0.1:3000/api/health
```

如果你的线上端口不是 `3000`，把上面的端口替换成实际值即可。

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
