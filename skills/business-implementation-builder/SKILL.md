---
name: business-implementation-builder
description: 按 DDD 架构与需求实现具体业务能力，支持客户端/服务端/后台的可追踪增量交付。用于用户要求实现某个功能、接口、业务流程或端到端能力时触发。
---

# 业务实现构建

按“可追踪、可验证、可回滚”的方式实现业务纵向切片。

## 工作流

### 1. 建立追踪基线

- 将功能范围映射到需求编号与架构模块。
- 确定客户端、服务端、后台受影响点。
- 开发前先冻结非目标范围。

### 2. 规划增量交付

- 将工作拆为可测试的薄切片。
- 每个切片明确数据、领域、接口、UI、后台操作顺序。
- 设计可回滚检查点。

### 3. 实现服务端切片

- 优先完成领域与应用层变更。
- 实现 API 契约与输入校验。
- 实施持久化变更与迁移保护。

### 4. 实现客户端与后台切片

- 客户端按需求场景实现界面与状态流。
- 后台实现运营操作、权限控制、审计能力。
- 保持三端契约同步。

### 5. 验证切片完整性

- 对照验收标准检查行为。
- 增补单测/集成测/关键路径验证。
- 技术债需显式记录，不隐藏。

### 6. 产出交付文档

- 使用 `references/implementation-checklist.md`。
- 输出变更文件、行为影响、风险、后续事项。
- 每项变更需关联需求编号。

## 质量标准

- 每次提交逻辑内聚、可评审。
- 业务不变式优先在服务端保证。
- API 与 UI 的异常路径处理保持一致。

## 工作流输出路径

- 提供工作流目录时，输出写入：
- `docs/workflows/<workflow-id>/05-implementation/implementation-plan.md`
- `docs/workflows/<workflow-id>/05-implementation/slice-log.md`
- `docs/workflows/<workflow-id>/05-implementation/change-summary.md`
