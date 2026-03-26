# 客户端实现

## 本轮目标

- 基于 CR-001 ~ CR-012 形成 home/stats/bills 三页客户端实施方案。
- 规划共享组件、状态管理、接口接入方式和页面开发顺序。
- 明确深浅版同构约束下的组件层次，避免进入开发时重复搭建。

## 页面开发顺序

1. 先搭建主应用壳层：路由、底部导航、FAB 占位。
2. 实现首页：最快验证 summary + recentTransactions 主链路。
3. 实现账单页：承接查看全部、筛选、搜索占位。
4. 实现统计页：接入 totals、趋势、排行三类展示。
5. 最后补空态、错误态、骨架、主题 token 细化。

## 推荐客户端结构

| 层级 | 模块/组件 | 职责 | 备注 |
| --- | --- | --- | --- |
| app shell | MainScaffold, AppBottomNavBar, PrimaryActionFab | 承接三个主页面与统一底部导航 | 先以占位页面替换当前单文本首页 |
| feature home | HomePage, HomeHeader, BalanceSummaryCard, TransactionList | 首页概览和最近交易展示 | 首页先完成可以最快看到业务 UI |
| feature bills | BillsPage, FilterChipGroup, DateGroupedBillSection, BillItemCard | 账单浏览、筛选、搜索入口 | 与首页 recentTransactions 共用交易项模型 |
| feature stats | StatsPage, MonthPickerButton, MetricSegmentToggle, WeeklyBarChartCard, CategoryRankingCard | 统计洞察展示 | 趋势图组件可能引入第三方库 |
| shared | AsyncStateView, SectionHeaderAction, RoundIconButton | 通用状态与交互组件 | 所有页面共用 |
| data | HomeRepository, BillsRepository, StatsRepository | 请求接口并做 DTO 转换 | 只负责传输层适配 |

## 页面与交互改动

| 需求编号 | 页面/组件 | 改动内容 | 数据来源（真实接口/mock/静态） | 当前状态 | 备注 |
| --- | --- | --- | --- | --- | --- |
| CR-004, CR-008, CR-012 | MainScaffold / AppBottomNavBar / PrimaryActionFab | 搭建三页主容器、底部导航和 FAB 占位动作 | 静态 -> 真实接口 | 方案已定义 | 当前 client/lib/app.dart 仅为占位，需要重构 |
| CR-001, CR-002, CR-003 | HomePage / BalanceSummaryCard / TransactionList | 首页展示 summary、余额显隐、查看全部跳账单 | mock -> /api/home/summary | 方案已定义 | 建议先用 mock 驱动布局 |
| CR-008, CR-009, CR-010, CR-011 | BillsPage / FilterChipGroup / DateGroupedBillSection | 账单页展示筛选、搜索入口、日期分组列表 | mock -> /api/bills | 方案已定义 | 搜索页可先占位 |
| CR-005, CR-006, CR-007 | StatsPage / MonthPickerButton / MetricSegmentToggle / WeeklyBarChartCard / CategoryRankingCard | 统计页展示切月、切指标、趋势和排行 | mock -> /api/stats/overview | 方案已定义 | 图表库选型待开发时确认 |
| CRR-001 ~ CRR-006 | 主题与共享组件 | 深浅版同构、方向驱动展示、错误/骨架策略 | 静态 + 接口 | 方案已定义 | 优先抽象 token 和共享交易模型 |

## 状态管理建议

| 领域 | 推荐状态 | 说明 |
| --- | --- | --- |
| 导航 | currentTab, fabEnabled | MainScaffold 统一管理 |
| 首页 | homeData, loading, error, amountVisible | 金额显隐作为本地 UI 状态 |
| 账单 | currentFilter, currentQuery, groupedBills, loading, error | 搜索与筛选需组合驱动请求 |
| 统计 | month, metricType, statsData, loading, error | 切月时保留旧数据，局部 loading |
| 主题 | themeMode / tokens | 视觉稿深浅版仅影响 token |

## 开发阶段的最小交付顺序

| 里程碑 | 交付内容 | 验证方式 |
| --- | --- | --- |
| M1 | MainScaffold + HomePage 静态布局 | 本地运行可看到首页组件结构 |
| M2 | HomePage 接真实接口 | 首页 summary 与 recentTransactions 正确渲染 |
| M3 | BillsPage 接真实接口 | 筛选和列表分组正确刷新 |
| M4 | StatsPage 接真实接口 | 切月、切指标、图表和排行正确联动 |
| M5 | 骨架/空态/错误态补齐 | 手动制造错误和空数据进行验证 |

## 测试与验证

| 类型 | 场景 | 结果 | 备注 |
| --- | --- | --- | --- |
| 手动验证 | 首页首屏加载、重试、余额显隐 | 待执行 | 对应 AC-001, AC-007 |
| 手动验证 | 首页“查看全部”进入账单页 | 待执行 | 对应 AC-003 |
| 手动验证 | 账单页切换筛选与空态展示 | 待执行 | 对应 AC-005, AC-008 |
| 手动验证 | 账单页搜索叠加筛选 | 待执行 | 对应 AC-010 |
| 手动验证 | 统计页切月和收入/支出切换 | 待执行 | 对应 AC-003, AC-004 |
| 组件测试 | 金额显隐与 direction 显示规则 | 待执行 | 避免视觉与数据语义错位 |

## 未完成项与后续依赖

| 项目 | 说明 | 后续动作 |
| --- | --- | --- |
| 客户端工程重构 | 当前 app.dart 仅有占位页，不具备 feature 分层 | 进入编码前先拆出 app shell |
| 图表方案 | 趋势图是自绘还是引库尚未确定 | 开发开始时做一次选型决策 |
| 搜索形态 | 搜索是页内展开还是独立页仍待确认 | 先保留占位接口与路由 |
| 真实实现未开始 | 当前仅补齐开发文档 | 后续按里程碑逐步落地 |
