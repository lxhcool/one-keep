# 工作流文档目录规范

每次工作流运行都必须将文档写入：

`docs/workflows/<workflow-id>/`

## 必需目录结构

```text
docs/workflows/<workflow-id>/
  README.md
  00-input/
    context.md
  98-stage-gates/
    stage-approvals.md
  01-layout/
    component-inventory.md
    pages/
      <page-slug>.md
  02-requirements/
    prd.md
    interaction-spec.md
  03-thinking/
    questions.md
    recommendations.md
    pre-architecture-checklist.md
  04-architecture/
    client-architecture.md
    server-architecture.md
    admin-architecture.md
  05-implementation/
    implementation-plan.md
    slice-log.md
    change-summary.md
  06-review-test/
    review-report.md
    test-strategy.md
    test-cases.md
  99-decisions/
    decision-log.md
    open-questions.md
```

## 命名规则

- `workflow-id` 与 `page-slug` 使用小写 kebab-case。
- `01-layout/pages/` 下每个页面一个文件。
- 需求编号在全链路文档中保持一致。
- 每阶段都必须在 `98-stage-gates/stage-approvals.md` 记录“待确认/已确认”。

## 跨文档追踪关系

- `02-requirements/prd.md` 定义需求编号。
- `01-layout/component-inventory.md` 记录组件复用检查结果（复用/新增与新增原因）。
- `03-thinking/questions.md` 与 `03-thinking/recommendations.md` 记录疑问与建议。
- `04-architecture/client-architecture.md` 定义客户端分层、状态与适配策略。
- `04-architecture/server-architecture.md` 定义服务端上下文、聚合、契约与一致性策略。
- `04-architecture/admin-architecture.md` 定义后台模块边界、权限与审计策略。
- `05-implementation/slice-log.md` 建立切片与需求编号映射。
- `06-review-test/review-report.md` 建立问题与需求/切片映射。
- `98-stage-gates/stage-approvals.md` 记录每阶段用户确认结果与时间。
