# 工作流文档目录规范

每次工作流运行都必须将文档写入：

`docs/<task-id>/`

## 必需目录结构

```text
docs/<task-id>/
  README.md
  00-input/
    context.md
  01-ui-analysis/
    component-inventory.md
    pages/
      <page-slug>.md
  02-requirements/
    requirements.md
    interaction-spec.md
  03-development/
    implementation-plan.md
    change-summary.md
    test-notes.md
  97-workflow/
    run-summary.md
    stage-status.md
  99-decisions/
    decision-log.md
    open-questions.md
```

## 命名规则

- `task-id` 与 `page-slug` 使用小写 kebab-case。
- `01-ui-analysis/pages/` 下每个页面一个文件。
- 需求编号在需求文档与开发记录中保持一致。
- 阶段状态统一记录在 `97-workflow/stage-status.md`。

## 跨文档追踪关系

- `01-ui-analysis/pages/*.md` 定义页面结构、功能点和组件拆分。
- `01-ui-analysis/component-inventory.md` 记录组件复用决策。
- `02-requirements/requirements.md` 定义服务端与客户端需求。
- `02-requirements/interaction-spec.md` 记录详细交互与状态说明。
- `03-development/implementation-plan.md` 定义开发顺序与任务拆分。
- `03-development/change-summary.md` 记录服务端与客户端的实际改动。
- `03-development/test-notes.md` 记录最小测试与联调结果。
- `97-workflow/stage-status.md` 记录每阶段状态与确认结果。