# 服务端实现

## 本轮目标

- 基于 FR-001 ~ FR-012 形成首页、统计页、账单页服务端落地方案。
- 明确推荐的数据模型、接口拆分顺序、校验规则和异常返回策略。
- 为后续真实开发提供可执行的模块划分与最小测试清单。

## 实现范围与顺序

1. 先完成首页聚合接口 /api/home/summary。
2. 再完成账单列表接口 /api/bills，确保首页最近交易与账单列表共用交易模型。
3. 之后完成统计接口 /api/stats/overview，统一趋势和分类排行口径。
4. 最后补 /api/transactions 的创建契约，为 FAB 主操作预留后续接入点。

## 推荐模块拆分

| 模块 | 职责 | 关联需求 | 备注 |
| --- | --- | --- | --- |
| auth-context | 提供当前用户上下文与鉴权能力 | FR-001, FR-003, FR-006 | 当前任务只消费现有登录态 |
| transaction-repository | 交易查询、过滤、排序、分页 | FR-002, FR-006, FR-007, FR-008 | 首页和账单页共同依赖 |
| summary-service | 计算月度结余、收入、支出和环比 | FR-001, FR-009 | 聚合逻辑集中在服务端 |
| stats-service | 生成总览、趋势序列、分类排行 | FR-003, FR-004, FR-005 | 避免客户端自行计算 |
| bills-query-service | 处理筛选、搜索、日期分组与 summary | FR-006, FR-007, FR-008 | 需支持 all/expense/income |
| transaction-command-service | 预留新增交易创建契约 | FR-012 | 本轮文档级定义即可 |

## 接口与数据改动

| 需求编号 | 接口/模块 | 改动内容 | 当前状态 | 备注 |
| --- | --- | --- | --- | --- |
| FR-001, FR-009 | /api/home/summary | 新增首页聚合接口，返回 user、balanceSummary、incomeSummary、expenseSummary、recentTransactions | 方案已定义 | 建议由 summary-service + transaction-repository 聚合输出 |
| FR-002, FR-006, FR-007, FR-008, FR-010, FR-011 | /api/bills | 新增账单列表接口，支持 filterType、query、month、cursor | 方案已定义 | groupedBills 需服务端完成分组与汇总 |
| FR-003, FR-004, FR-005, FR-010, FR-011 | /api/stats/overview | 新增统计接口，返回 totals、trendSeries、categoryRanks | 方案已定义 | metricType 支持 expense/income |
| FR-012 | /api/transactions | 预留新增交易接口契约 | 方案已定义 | 本轮不进入实现 |

## 推荐数据模型

| 对象 | 关键字段 | 说明 |
| --- | --- | --- |
| TransactionRecord | id, userId, title, categoryId, categoryName, iconKey, amount, direction, occurredAt, note | 首页 recentTransactions 与账单列表的统一底层模型 |
| MonthlySummary | month, incomeAmount, expenseAmount, balanceAmount, deltaRate | 首页总览卡依赖 |
| TrendPoint | label, value, metricType, order | 统计图的基础点位结构 |
| CategoryRank | categoryId, categoryName, iconKey, amount, progressBase, progressRatio? | 分类排行数据结构 |
| GroupedBillSection | date, summary, items[] | 账单页日期分组结构 |

## 实现步骤建议

| 步骤 | 动作 | 产出 | 风险控制 |
| --- | --- | --- | --- |
| 1 | 定义交易、聚合、排行 DTO 与错误码 | DTO、错误码枚举 | 先统一字段语义，避免接口反复改动 |
| 2 | 打通 /api/home/summary | 首页可返回真实 summary 与 recentTransactions | 可先限制 recentTransactions 返回条数 |
| 3 | 打通 /api/bills | 支持月份 + 筛选 + 搜索 | 搜索与筛选叠加规则需与产品确认一致 |
| 4 | 打通 /api/stats/overview | 趋势与排行口径统一 | progressBase 计算规则必须写死在服务端 |
| 5 | 预留 /api/transactions 契约 | 文档和接口骨架 | 不提前实现复杂录入逻辑 |

## 测试与验证

| 类型 | 场景 | 结果 | 备注 |
| --- | --- | --- | --- |
| 接口自测 | /api/home/summary 在合法 month 下返回完整结构 | 待执行 | 开发后校验金额口径与字段齐备性 |
| 接口自测 | /api/bills 在 all/expense/income 三种筛选下返回正确分组 | 待执行 | 需覆盖空结果 |
| 接口自测 | /api/bills 在 query 条件下搜索结果仍叠加 filterType | 待执行 | 对应 AC-010 |
| 接口自测 | /api/stats/overview 在 metricType 切换时返回不同趋势 | 待执行 | 需确认排行是否联动 |
| 异常验证 | month 非法、filterType 非法、未授权 | 待执行 | 返回 400/401 |
| 兼容验证 | recentTransactions 与 groupedBills.items 字段语义一致 | 待执行 | 防止客户端出现双模型分叉 |

## 未完成项与后续依赖

| 项目 | 说明 | 后续动作 |
| --- | --- | --- |
| 统计口径确认 | 分类排行 progressBase 与趋势口径仍待确认 | 开发前冻结服务端计算规则 |
| 详情页与新增记账闭环 | /api/transactions 仅完成契约级定义 | 在新增记账任务中继续展开 |
| 搜索规则确认 | 标题、分类、备注搜索范围已建议但未被产品最终确认 | 进入编码前完成确认 |
| 真实实现未开始 | 当前文档是服务端实施方案，不是代码变更 | 后续按 implementation-plan 执行 |
