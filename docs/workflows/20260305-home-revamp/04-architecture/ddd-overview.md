# DDD 概览

## 限界上下文

- `Home Ledger Context`（首页记账上下文）
  - 负责首页展示、月份切换、日分组流水查询、空态/异常态处理。
- `Transaction Entry Context`（流水录入上下文）
  - 负责新增流水流程，完成后触发首页刷新。
- `Navigation Shell Context`（主导航壳上下文）
  - 负责底部导航状态与路由。
  - 中间“记账”为说明位，不属于可路由导航项。

## 聚合与不变式

- 聚合: `HomeSnapshot`
  - 字段: `month`, `summary(income,expense)`, `dayGroups[]`, `status`
  - 不变式:
    - `month` 唯一对应一份首页快照。
    - `summary` 与 `dayGroups` 数据口径一致（同月）。

- 聚合: `DayGroup`
  - 字段: `date`, `dayExpense`, `items[]`
  - 不变式:
    - `items` 仅包含同一自然日数据。
    - `dayExpense = sum(支出项金额绝对值)`（展示为负值时由前端格式化）。

- 聚合: `TransactionItem`
  - 字段: `id`, `category`, `amount`, `type(income|expense)`, `occurredAt`
  - 不变式:
    - `income` 展示为正数，`expense` 展示为负数。
    - `id` 全局唯一，支持详情跳转。

## 三端职责

- 客户端（C）
  - 管理 `selectedMonth`、`pageStatus`、`activeBottomTab`。
  - 实现分步返回渲染（先统计后列表）。
  - 保证中间“记账”说明位不可点击，`+` 按钮作为唯一新增入口。

- 服务端（S）
  - 提供首页查询接口（支持统计与列表分步/合并返回）。
  - 提供新增流水接口，写入后保证同月查询可读。
  - 统一错误码与可重试语义。

- 后台/配置端（B）
  - 维护分类图标、空态素材配置（当前可先占位）。
  - 维护文案配置（错误提示、空态引导）。
