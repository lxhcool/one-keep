---
name: pet-commerce-workflow-orchestrator
description: 串联通用端到端交付流程，按固定顺序调用布局分析、需求编写、思考审查、客户端架构、服务端架构、后台架构、业务实现、代码审查与测试，并在每次执行中生成完整且可追踪的 Markdown 产物。用于用户要求整条工作流协同推进与文档沉淀时触发。
---

# 通用项目工作流编排

为任意项目的功能迭代建立一套可追踪、可复盘、可执行的文档化交付流程。

## 工作流契约

- 执行前先读取 `references/workflow-contract.md`，按统一输入/输出/编号/门禁规则执行。

### 1. 初始化一次运行目录

- 运行 `skills/pet-commerce-workflow-orchestrator/scripts/init_workflow_docs.sh <workflow-id> [page-slug ...]`。
- `workflow-id` 必须唯一，建议格式：`20260303-product-detail-revamp`。
- 所有产物写入 `docs/workflows/<workflow-id>/`。
- 此步骤不可跳过。

### 2. 固定技能链顺序

1. `$ui-layout-analyzer`
2. `$product-requirement-writer`
3. `$design-requirement-challenger`
4. `$ddd-client-architecture-designer`
5. `$ddd-server-architecture-designer`
6. `$ddd-admin-architecture-designer`
7. `$business-implementation-builder`
8. `$code-review-test-auditor`

### 3. 阶段确认门禁（强制）

- 每个阶段完成后必须暂停，先等待用户确认，才能进入下一阶段。
- 询问格式固定为：`是否确认进入阶段 N：<阶段名>？`
- 未收到明确确认（例如“确认/继续/进入下一步”）时，禁止执行下一阶段。
- 每次确认结果必须落到：
- `98-stage-gates/stage-approvals.md`
- 阶段阻塞项与关闭状态需同步到：
- `98-stage-gates/stage-approvals.md`

## 输出规则（强制）

- 每个页面必须生成独立文档：`01-layout/pages/<page-slug>.md`。
- 思考阶段必须生成：
- `03-thinking/questions.md`
- `03-thinking/recommendations.md`
- `03-thinking/pre-architecture-checklist.md`
- 架构阶段必须生成：
- `04-architecture/client-architecture.md`
- `04-architecture/server-architecture.md`
- `04-architecture/admin-architecture.md`
- 需求编号在以下文档中保持一致：
- `02-requirements/*.md`
- `03-thinking/*.md`
- `04-architecture/*.md`
- `05-implementation/*.md`
- `06-review-test/*.md`
- 所有关键决策与未决问题必须追加到：
- `99-decisions/decision-log.md`
- `99-decisions/open-questions.md`

## 分阶段执行说明

### 阶段 1：布局分析

- 对每个页面输入执行 `$ui-layout-analyzer`。
- 结果写入 `01-layout/pages/<page-slug>.md`。
- 跨页面组件索引写入 `01-layout/component-inventory.md`。
- 阶段结束后等待用户确认，再进入阶段 2。

### 阶段 2：需求编写

- 使用阶段 1 产物执行 `$product-requirement-writer`。
- 输出写入 `02-requirements/prd.md` 与 `02-requirements/interaction-spec.md`。
- 阶段结束后等待用户确认，再进入阶段 3。

### 阶段 3：思考审查

- 使用阶段 1 和阶段 2 产物执行 `$design-requirement-challenger`。
- 输出写入：
- `03-thinking/questions.md`
- `03-thinking/recommendations.md`
- `03-thinking/pre-architecture-checklist.md`
- 阶段 3 的阻塞项未关闭前，不进入架构阶段。
- 阶段结束后等待用户确认，再进入阶段 4。

### 阶段 4：DDD 架构

- 使用 PRD、交互文档与思考审查结果，按顺序执行：
- `$ddd-client-architecture-designer`
- `$ddd-server-architecture-designer`
- `$ddd-admin-architecture-designer`
- 输出写入：
- `04-architecture/client-architecture.md`
- `04-architecture/server-architecture.md`
- `04-architecture/admin-architecture.md`
- 阶段结束后等待用户确认，再进入阶段 5。

### 阶段 5：业务实现

- 基于已确认架构执行 `$business-implementation-builder`。
- 输出写入：
- `05-implementation/implementation-plan.md`
- `05-implementation/slice-log.md`
- `05-implementation/change-summary.md`
- 阶段结束后等待用户确认，再进入阶段 6。

### 阶段 6：审查与测试

- 对变更代码与文档执行 `$code-review-test-auditor`。
- 输出写入：
- `06-review-test/review-report.md`
- `06-review-test/test-strategy.md`
- `06-review-test/test-cases.md`
- 阶段结束后等待用户确认，确认是否结束本次工作流或继续下一轮迭代。

## 必读参考

- 先读 `references/workflow-doc-structure.md`（目录规范）。
- 再读 `references/workflow-run-template.md`（运行摘要模板）。
- 再读 `references/workflow-contract.md`（统一契约）。
- 子技能模板引用：
- `skills/ui-layout-analyzer/references/output-template.md`
- `skills/product-requirement-writer/references/prd-template.md`
- `skills/design-requirement-challenger/references/thinking-template.md`
- `skills/ddd-client-architecture-designer/references/client-architecture-template.md`
- `skills/ddd-server-architecture-designer/references/server-architecture-template.md`
- `skills/ddd-admin-architecture-designer/references/admin-architecture-template.md`
- `skills/business-implementation-builder/references/implementation-checklist.md`
- `skills/code-review-test-auditor/references/review-test-template.md`

## 质量标准

- 阶段间增量演进，不从头重写文档。
- 全链路术语统一。
- 每个文档具备可执行性，能够直接指导下一步。
