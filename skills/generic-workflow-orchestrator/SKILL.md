---
name: generic-workflow-orchestrator
description: 串联通用端到端交付流程，按固定顺序执行 UI 分析、需求文档生成、服务端优先开发与联调，并将每个阶段的结果写入 docs。各阶段也允许单独执行。
---

# 通用工作流编排

为任意项目建立一套可单独运行、可串联执行、可落盘到 docs 的通用交付流程。

## 工作流契约

- 执行前先读取 `references/workflow-contract.md`。
- 初始化目录后，所有阶段都写入同一个 `docs/<task-id>/` 目录。
- 编排器本身不替代子技能，只负责准备目录、校验输入、串联阶段和汇总结果。

## 固定阶段顺序

1. `$ui-layout-analyzer`
2. `$product-requirement-writer`
3. `$business-implementation-builder`

## 阶段规则

### 1. 初始化运行目录

- 运行 `skills/generic-workflow-orchestrator/scripts/init_workflow_docs.sh <task-id> [page-slug ...]`。
- `task-id` 必须唯一，建议格式：`20260326-feature-name`。
- 此步骤不可跳过。

### 2. 支持单独执行

- 若用户只要求其中一个阶段，则只执行对应技能。
- 单独执行时也必须初始化或复用 `docs/<task-id>/` 目录。
- 单独执行的输出路径与串联执行保持一致。

### 3. 支持串联执行

- 串联执行时必须按固定顺序推进。
- 阶段 1 输出是阶段 2 的输入。
- 阶段 2 输出是阶段 3 的输入。
- 若上阶段存在阻塞项，必须先记录，再决定是否继续。

### 4. 阶段确认

- 每个阶段结束后都要给出阶段总结、阻塞项、下一步建议。
- 若编排器被用于完整流程，应询问用户是否进入下一阶段。
- 阶段确认结果记录到 `97-workflow/stage-status.md`。

## 输出规则

- 页面分析写入：
- `docs/<task-id>/01-ui-analysis/pages/<page-slug>.md`
- `docs/<task-id>/01-ui-analysis/component-inventory.md`
- 需求文档写入：
- `docs/<task-id>/02-requirements/requirements.md`
- `docs/<task-id>/02-requirements/interaction-spec.md`
- 开发阶段写入：
- `docs/<task-id>/03-development/implementation-plan.md`
- `docs/<task-id>/03-development/change-summary.md`
- `docs/<task-id>/03-development/test-notes.md`
- 运行摘要与决策写入：
- `docs/<task-id>/97-workflow/run-summary.md`
- `docs/<task-id>/97-workflow/stage-status.md`
- `docs/<task-id>/99-decisions/decision-log.md`
- `docs/<task-id>/99-decisions/open-questions.md`

## 必读参考

- 先读 `references/workflow-doc-structure.md`。
- 再读 `references/workflow-run-template.md`。
- 再读 `references/workflow-contract.md`。

## 质量标准

- 流程不绑定具体技术栈或业务领域。
- 每个阶段都能独立运行，也能被完整流程消费。
- 文档结构稳定，便于追踪同一任务的分析、需求与实现结果。