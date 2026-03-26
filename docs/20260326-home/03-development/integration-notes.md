# 联调记录

## 联调范围

| 服务端接口/模块 | 客户端页面/组件 | 联调状态 | 备注 |
| --- | --- | --- | --- |
| /api/home/summary | HomePage / BalanceSummaryCard / TransactionList | 未开始 | 首页会是第一条联调主链路 |
| /api/bills | BillsPage / FilterChipGroup / DateGroupedBillSection | 未开始 | 需覆盖筛选、搜索和空态 |
| /api/stats/overview | StatsPage / WeeklyBarChartCard / CategoryRankingCard | 未开始 | 需覆盖切月和指标切换 |
| /api/transactions | PrimaryActionFab / AddTransactionFlow 占位 | 未开始 | 当前仅保留契约，不进入本任务实做 |

## 问题与阻塞

| 问题 | 影响 | 当前处理 | 下一步 |
| --- | --- | --- | --- |
| 搜索形态未确定 | 影响账单页入口与结果页联调 | 文档中先按“可独立页或展开态”保留 | 开发前由产品拍板 |
| 统计排行基准未确认 | 影响图表与排行一致性校验 | 要求服务端显式返回 progressBase/progressRatio | 开发前冻结统计口径 |
| FAB 流程未定义 | 影响主操作联调闭环 | 当前只联调入口和不可用态 | 后续在新增记账任务继续扩展 |
| 当前无代码改动 | 无法执行真实接口联调 | 已补齐联调脚本级清单 | 代码启动后按清单执行 |

## 若尚未联调

| 原因 | 缺失前置条件 | 预计后续动作 |
| --- | --- | --- |
| 当前补齐的是开发文档，不是实现代码 | 服务端接口、客户端页面和路由均未落地 | 开发阶段先完成首页链路，再扩到账单和统计 |

## 推荐联调顺序

1. 首页：先验证 summary、金额方向、recentTransactions 映射。
2. 账单页：验证 filterType、query、groupedBills 与空结果。
3. 统计页：验证 month、metricType、trendSeries、categoryRanks。
4. 主导航与 FAB：验证跨页跳转、入口占位与不可用态。

## 联调最小检查清单

| 检查项 | 预期 |
| --- | --- |
| 首页金额和方向 | 所有金额颜色、符号、文案与 direction 一致 |
| 首页到账单页跳转 | 点击“查看全部”后定位到账单页默认态 |
| 账单筛选叠加搜索 | 搜索结果保留当前筛选口径 |
| 统计切月 | 切月失败时保留旧数据，不闪空 |
| 统计切指标 | 收入/支出切换后图表数据与选中态同步 |
| 空态与错误态 | 接口空结果和接口失败能被用户区分 |
