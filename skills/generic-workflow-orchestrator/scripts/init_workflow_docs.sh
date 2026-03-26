#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "用法: $0 <task-id> [page-slug ...]" >&2
  echo "示例: $0 20260326-billing-home home bill-detail" >&2
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

task_id="$1"
shift

if [[ ! "$task_id" =~ ^[a-z0-9-]+$ ]]; then
  echo "错误: task-id 必须匹配 ^[a-z0-9-]+$" >&2
  exit 1
fi

base_dir="docs/${task_id}"

if [[ -e "$base_dir" ]]; then
  echo "错误: ${base_dir} 已存在，请使用新的 task-id。" >&2
  exit 1
fi

mkdir -p \
  "${base_dir}/00-input" \
  "${base_dir}/01-ui-analysis/pages" \
  "${base_dir}/02-requirements" \
  "${base_dir}/03-development" \
  "${base_dir}/97-workflow" \
  "${base_dir}/99-decisions"

create_file() {
  local file_path="$1"
  local content="$2"
  printf "%s\n" "$content" > "$file_path"
}

create_file "${base_dir}/README.md" "# 任务 ${task_id}

## 概览

- 功能:
- 负责人:
- 日期:
- 页面范围:

## 阶段进度

- [ ] 1. UI 分析与组件拆分
- [ ] 2. 需求文档生成
- [ ] 3. 服务端优先的实现与联调
"

create_file "${base_dir}/00-input/context.md" "# 输入上下文

## 业务目标

## 用户对象

## 约束条件

## 原始材料
"

create_file "${base_dir}/01-ui-analysis/component-inventory.md" "# 组件清单

| 组件 | 项目内是否已有可匹配组件 | 匹配组件路径 | 匹配结论（可匹配/需开发） | 处理方式 | 需开发原因 | 覆盖页面 | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- |
"

create_file "${base_dir}/02-requirements/requirements.md" "# 需求文档

## 服务端需求

## 客户端需求

## 验收标准
"

create_file "${base_dir}/02-requirements/interaction-spec.md" "# 交互规格

## 主流程

## 分支与异常流程

## 状态变化
"

create_file "${base_dir}/03-development/implementation-plan.md" "# 实现计划

## 服务端计划

## 客户端计划

## 联调计划
"

create_file "${base_dir}/03-development/change-summary.md" "# 变更摘要

## 服务端改动

## 客户端改动

## 风险与后续事项
"

create_file "${base_dir}/03-development/test-notes.md" "# 测试记录

## 已执行验证

## 联调结果

## 未解决问题
"

create_file "${base_dir}/97-workflow/run-summary.md" "# 运行摘要

## 本轮目标

## 阶段结论

## 下一步
"

create_file "${base_dir}/97-workflow/stage-status.md" "# 阶段状态

| 阶段 | 阶段名 | 执行状态 | 用户确认 | 备注 |
| --- | --- | --- | --- | --- |
| 1 | UI 分析与组件拆分 | 未开始 | 待确认 |  |
| 2 | 需求文档生成 | 未开始 | 待确认 |  |
| 3 | 服务端优先的实现与联调 | 未开始 | 待确认 |  |
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
  create_file "${base_dir}/01-ui-analysis/pages/page-template.md" "# 页面分析: <page-slug>

## 输入信息

| 项目 | 内容 |
| --- | --- |
| 来源 | 截图 / Figma 导出 / MasterGo 地址 / Pencli 地址 / 页面链接 |
| 分析页面 |  |
| 目标设备 |  |
| 已知约束 |  |
| 假设前提 |  |

## 页面结构说明

| 区域 | 目标 | 布局类型 | 关键元素 | 备注 |
| --- | --- | --- | --- | --- |

## 功能点清单

| 功能点 | 用户动作 | 页面反馈 | 优先级 | 备注 |
| --- | --- | --- | --- | --- |

## 布局树

## 组件拆分

| 组件名 | 类型（页面/共享） | 所在区域 | 参数/配置 | 状态 | 备注 |
| --- | --- | --- | --- | --- | --- |

## 组件匹配检查表

| 候选组件 | 是否已有可匹配组件 | 匹配组件路径 | 匹配结论（可匹配/需开发） | 处理方式 | 需开发原因 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |

## 交互与状态表

| 场景 | 触发条件 | 页面反馈 | 依赖组件 | 备注 |
| --- | --- | --- | --- | --- |

## 待确认问题与假设表

| 类型 | 内容 | 影响范围 | 处理建议 |
| --- | --- | --- | --- |
"
else
  for page_slug in "$@"; do
    if [[ ! "$page_slug" =~ ^[a-z0-9-]+$ ]]; then
      echo "错误: 页面标识 '${page_slug}' 必须匹配 ^[a-z0-9-]+$" >&2
      exit 1
    fi
    create_file "${base_dir}/01-ui-analysis/pages/${page_slug}.md" "# 页面分析: ${page_slug}

  ## 输入信息

  | 项目 | 内容 |
  | --- | --- |
  | 来源 | 截图 / Figma 导出 / MasterGo 地址 / Pencli 地址 / 页面链接 |
  | 分析页面 |  |
  | 目标设备 |  |
  | 已知约束 |  |
  | 假设前提 |  |

  ## 页面结构说明

  | 区域 | 目标 | 布局类型 | 关键元素 | 备注 |
  | --- | --- | --- | --- | --- |

  ## 功能点清单

  | 功能点 | 用户动作 | 页面反馈 | 优先级 | 备注 |
  | --- | --- | --- | --- | --- |

  ## 布局树

  ## 组件拆分

  | 组件名 | 类型（页面/共享） | 所在区域 | 参数/配置 | 状态 | 备注 |
  | --- | --- | --- | --- | --- | --- |

  ## 组件匹配检查表

  | 候选组件 | 是否已有可匹配组件 | 匹配组件路径 | 匹配结论（可匹配/需开发） | 处理方式 | 需开发原因 | 备注 |
  | --- | --- | --- | --- | --- | --- | --- |

  ## 交互与状态表

  | 场景 | 触发条件 | 页面反馈 | 依赖组件 | 备注 |
  | --- | --- | --- | --- | --- |

  ## 待确认问题与假设表

  | 类型 | 内容 | 影响范围 | 处理建议 |
  | --- | --- | --- | --- |
"
  done
fi

echo "已初始化工作流文档目录: ${base_dir}"