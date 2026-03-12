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
npm run analyze:client
npm run test:client
```

## Skills 作用

`skills/` 目录是工作流技能库，用来把“页面分析 → 需求 → 架构 → 实现 → 测试”这条链路标准化。

所有 skill 都支持两种使用方式：

- **独立使用**：按当前任务只调用某一个 skill（例如仅做 PRD、仅做代码审查）。
- **串联使用**：按阶段把多个 skill 连起来，做完整端到端交付。

- `$ui-layout-analyzer`：分析设计稿/截图，输出布局树、组件清单、交互状态。
- `$product-requirement-writer`：把页面分析整理成 PRD 与交互规格。
- `$design-requirement-challenger`：对需求做结构化质疑，补齐缺失规则与风险。
- `$ddd-client-architecture-designer`：设计客户端分层、状态流与接口适配策略。
- `$ddd-server-architecture-designer`：设计服务端限界上下文、聚合、不变式与契约。
- `$ddd-admin-architecture-designer`：设计后台模块边界、权限模型与审计治理。
- `$business-implementation-builder`：按切片落地实现并输出可追踪交付记录。
- `$code-review-test-auditor`：做代码审查、风险分级与测试策略/用例输出。
- `$pet-commerce-workflow-orchestrator`：编排完整六阶段流程（阶段 4 含三端架构子阶段）。

## Skills 使用说明

### 1) 独立使用（单个 skill）

适合“只做一个阶段任务”的场景。下面是全部 skill 的独立使用示例：

- `$ui-layout-analyzer`

```text
使用 $ui-layout-analyzer 分析 ui/home.jpg，输出布局树、组件清单、交互状态和待确认问题
```

- `$product-requirement-writer`

```text
使用 $product-requirement-writer 将首页布局分析整理为 PRD 和交互规格，补齐验收标准
```

- `$design-requirement-challenger`

```text
使用 $design-requirement-challenger 审查首页 PRD 和交互文档，输出疑问清单、优化建议和架构前确认项
```

- `$ddd-client-architecture-designer`

```text
使用 $ddd-client-architecture-designer 设计首页客户端架构，给出分层、状态流和接口适配方案
```

- `$ddd-server-architecture-designer`

```text
使用 $ddd-server-architecture-designer 设计首页相关服务端架构，输出上下文、聚合、不变式、契约与事务边界
```

- `$ddd-admin-architecture-designer`

```text
使用 $ddd-admin-architecture-designer 设计首页对应后台能力，输出模块边界、权限模型和审计策略
```

- `$business-implementation-builder`

```text
使用 $business-implementation-builder 按已确认架构实现首页能力，按切片输出 implementation-plan、slice-log、change-summary
```

- `$code-review-test-auditor`

```text
使用 $code-review-test-auditor 评审这组改动，输出分级问题、最小修复建议、测试策略和测试用例
```

- `$pet-commerce-workflow-orchestrator`

```text
使用 $pet-commerce-workflow-orchestrator 启动本轮工作流并生成完整文档框架，先执行阶段 1 布局分析
```

### 2) 串联使用（完整流程）

适合“从页面到实现再到测试”的完整交付。

```text
使用 $pet-commerce-workflow-orchestrator 实现首页，workflow-id=20260312-home, page-slug=home，设计图在 ui/home.jpg
```

说明：

- 编排器会按阶段串联多个 skill。
- 每个阶段结束会等待你确认，再进入下一阶段。
- 阶段 4 会拆成客户端/服务端/后台三个架构子阶段。
- 阶段 1 会执行组件复用检查：优先复用现有组件，新增组件必须写明原因，避免重复造轮子。

### 3) 每个 skill 的建议输入材料

下面这份清单可作为开工前的准备项（最少输入 + 推荐补充）：

| Skill | 最少输入（必备） | 推荐补充（可选） |
| --- | --- | --- |
| `$ui-layout-analyzer` | 页面截图/设计稿（本地路径或链接）、页面名 | 目标设备、设计约束、已有组件规范 |
| `$product-requirement-writer` | 布局分析结果（`01-layout/pages/*.md`） | 业务目标、用户角色、成功指标、范围边界 |
| `$design-requirement-challenger` | `prd.md` + `interaction-spec.md` + 页面分析文档 | 历史反馈、已知争议点、上线时间约束 |
| `$ddd-client-architecture-designer` | PRD、交互文档、页面结构 | 客户端技术栈、状态管理方案、缓存策略偏好 |
| `$ddd-server-architecture-designer` | PRD、核心业务规则、关键用例 | 数据库约束、接口风格、一致性要求、SLA |
| `$ddd-admin-architecture-designer` | PRD、后台角色与运营场景 | 权限模型草案、审计合规要求、高风险操作清单 |
| `$business-implementation-builder` | 已确认架构文档、需求编号、实现目标 | 代码仓库现状、迭代切片优先级、回滚要求 |
| `$code-review-test-auditor` | 变更代码/PR、需求与验收标准 | 历史缺陷、线上事故、测试环境限制 |
| `$pet-commerce-workflow-orchestrator` | `workflow-id`、`page-slug`、本轮目标、页面输入材料 | 参与人分工、阶段门禁标准、里程碑日期 |

使用建议：

- 输入不全时可先跑，但要把假设落到文档中。
- 同一个迭代里，需求编号建议固定不变，便于跨阶段追踪。
- 如果只做某一阶段，优先使用对应单 skill；全流程再用 orchestrator。

## 说明

- 当前未创建后台管理端，按规划在后续阶段按需新增（Vue3 或 React）。
