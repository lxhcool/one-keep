---
name: design-requirement-challenger
description: 在页面布局分析与需求文档完成后，进行结构化“思考审查”，提出关键疑问、交互优化建议、需求补齐建议与风险提示。用于用户要求对设计和需求进行质疑、补充和改进时触发。
---

# 设计与需求思考审查

在进入架构设计前，对“页面分析 + 需求文档”进行一次结构化挑战，减少后续返工。

## 工作流

### 1. 收集输入

- 输入至少包含：
- `01-layout/pages/*.md`
- `02-requirements/prd.md`
- `02-requirements/interaction-spec.md`
- 缺失信息先记录为“待确认问题”。

### 2. 识别疑问与冲突

- 检查页面结构与需求是否冲突。
- 检查交互流程是否闭环（含异常流、空态、权限失败）。
- 检查目标与验收标准是否可衡量。

### 3. 产出优化建议

- 交互建议：操作路径、反馈时机、状态表达、容错策略。
- 需求补齐：缺失字段、规则边界、角色权限、非功能约束。
- 业务建议：优先级重排、范围裁剪、分阶段上线策略。

### 4. 分级与决策建议

- 将问题按严重程度分级：阻塞、高、中、低。
- 对每条建议给出影响范围与处理优先级。
- 标记“架构前必须确认项”。

### 5. 输出文档

- 使用 `references/thinking-template.md`。
- 输出必须包含：
- 疑问清单
- 交互建议
- 需求补齐建议
- 架构前确认清单

## 质量标准

- 建议必须可执行，避免空泛结论。
- 明确“观察事实”与“改进建议”的边界。
- 每个高优先级问题都要给出潜在影响。

## 工作流输出路径

- 提供工作流目录时，输出写入：
- `docs/workflows/<workflow-id>/03-thinking/questions.md`
- `docs/workflows/<workflow-id>/03-thinking/recommendations.md`
- `docs/workflows/<workflow-id>/03-thinking/pre-architecture-checklist.md`
