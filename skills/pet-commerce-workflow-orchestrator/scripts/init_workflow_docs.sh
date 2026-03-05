#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "用法: $0 <workflow-id> [page-slug ...]" >&2
  echo "示例: $0 20260303-product-detail home product-detail cart" >&2
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

workflow_id="$1"
shift

if [[ ! "$workflow_id" =~ ^[a-z0-9-]+$ ]]; then
  echo "错误: workflow-id 必须匹配 ^[a-z0-9-]+$" >&2
  exit 1
fi

base_dir="docs/workflows/${workflow_id}"

if [[ -e "$base_dir" ]]; then
  echo "错误: ${base_dir} 已存在，请使用新的 workflow-id。" >&2
  exit 1
fi

mkdir -p \
  "${base_dir}/00-input" \
  "${base_dir}/98-stage-gates" \
  "${base_dir}/01-layout/pages" \
  "${base_dir}/02-requirements" \
  "${base_dir}/03-thinking" \
  "${base_dir}/04-architecture" \
  "${base_dir}/05-implementation" \
  "${base_dir}/06-review-test" \
  "${base_dir}/99-decisions"

create_file() {
  local file_path="$1"
  local content="$2"
  printf "%s\n" "$content" > "$file_path"
}

create_file "${base_dir}/README.md" "# 工作流 ${workflow_id}

## 概览

- 功能:
- 负责人:
- 日期:
- 页面范围:

## 阶段进度

- [ ] 1. 布局分析
- [ ] 2. 需求编写
- [ ] 3. 思考审查
- [ ] 4. DDD 架构设计
- [ ] 5. 业务实现
- [ ] 6. 代码审查与测试
"

create_file "${base_dir}/98-stage-gates/stage-approvals.md" "# 阶段确认记录

| 阶段 | 阶段名 | 执行状态 | 用户确认 | 确认时间 | 备注 |
| --- | --- | --- | --- | --- | --- |
| 1 | 布局分析 | 未开始 | 待确认 |  |  |
| 2 | 需求编写 | 未开始 | 待确认 |  |  |
| 3 | 思考审查 | 未开始 | 待确认 |  |  |
| 4 | DDD 架构设计 | 未开始 | 待确认 |  |  |
| 5 | 业务实现 | 未开始 | 待确认 |  |  |
| 6 | 代码审查与测试 | 未开始 | 待确认 |  |  |
"

create_file "${base_dir}/00-input/context.md" "# 输入上下文

## 业务目标

## 用户对象

## 约束条件

## 原始材料
"

create_file "${base_dir}/01-layout/component-inventory.md" "# 组件清单

| 组件 | 是否复用 | 覆盖页面 | 备注 |
| --- | --- | --- | --- |
"

create_file "${base_dir}/02-requirements/prd.md" "# PRD

## 目标

## 功能需求

## 验收标准
"

create_file "${base_dir}/02-requirements/interaction-spec.md" "# 交互规格

## 交互流程

## 状态变化

## 异常处理
"

create_file "${base_dir}/03-thinking/questions.md" "# 思考审查 - 疑问清单

| 级别 | 类别 | 问题描述 | 影响 | 需要谁确认 |
| --- | --- | --- | --- | --- |
"

create_file "${base_dir}/03-thinking/recommendations.md" "# 思考审查 - 建议清单

## 交互优化建议

## 需求补齐建议

## 优先级建议
"

create_file "${base_dir}/03-thinking/pre-architecture-checklist.md" "# 架构前确认清单

- [ ] 阻塞问题已闭环
- [ ] 高优先级建议已确认
- [ ] 关键业务规则已补齐
- [ ] 验收标准可测试
"

create_file "${base_dir}/04-architecture/ddd-overview.md" "# DDD 概览

## 限界上下文

## 聚合与不变式

## 三端职责
"

create_file "${base_dir}/04-architecture/page-architecture-mapping.md" "# 页面与架构映射

| 页面 | 限界上下文 | 服务端模块 | API/契约 | 后台模块 |
| --- | --- | --- | --- | --- |
"

create_file "${base_dir}/04-architecture/contracts.md" "# 契约定义

## API 契约

## 事件契约

## 版本策略说明
"

create_file "${base_dir}/05-implementation/implementation-plan.md" "# 实现计划

## 切片计划

## 依赖关系

## 回滚方案
"

create_file "${base_dir}/05-implementation/slice-log.md" "# 切片日志

| 切片 | 需求编号 | 变更模块 | 状态 | 备注 |
| --- | --- | --- | --- | --- |
"

create_file "${base_dir}/05-implementation/change-summary.md" "# 变更摘要

## 行为变化

## 兼容性说明

## 已知技术债
"

create_file "${base_dir}/06-review-test/review-report.md" "# 评审报告

## 按严重级别的问题

## 合并前必须修复
"

create_file "${base_dir}/06-review-test/test-strategy.md" "# 测试策略

## 风险矩阵

## 覆盖优先级
"

create_file "${base_dir}/06-review-test/test-cases.md" "# 测试用例

| 优先级 | 类型 | 场景 | 预期结果 |
| --- | --- | --- | --- |
"

create_file "${base_dir}/99-decisions/decision-log.md" "# 决策记录

| 日期 | 决策 | 原因 | 影响 |
| --- | --- | --- | --- |
"

create_file "${base_dir}/99-decisions/open-questions.md" "# 未决问题

| 日期 | 问题 | 负责人 | 状态 |
| --- | --- | --- | --- |
"

if [[ $# -eq 0 ]]; then
  create_file "${base_dir}/01-layout/pages/page-template.md" "# 页面布局分析: <page-slug>

## 输入信息

## 布局树

## 组件拆分

## 交互与状态

## 待确认问题与假设
"
else
  for page_slug in "$@"; do
    if [[ ! "$page_slug" =~ ^[a-z0-9-]+$ ]]; then
      echo "错误: 页面标识 '${page_slug}' 必须匹配 ^[a-z0-9-]+$" >&2
      exit 1
    fi
    create_file "${base_dir}/01-layout/pages/${page_slug}.md" "# 页面布局分析: ${page_slug}

## 输入信息

## 布局树

## 组件拆分

## 交互与状态

## 待确认问题与假设
"
  done
fi

echo "已初始化工作流文档目录: ${base_dir}"
