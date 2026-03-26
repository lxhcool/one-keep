# 组件清单

| 组件 | 项目内是否已有可匹配组件 | 匹配组件路径 | 匹配结论（可匹配/需开发） | 处理方式 | 需开发原因 | 覆盖页面 | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| AppBottomNavBar | 否 | 无 | 需开发 | 新开发 | 当前仓库没有底部导航体系 | stats | 与首页、账单页共享框架 |
| PrimaryActionFab | 否 | 无 | 需开发 | 新开发 | 当前仓库没有主操作 FAB | stats | 新增记账统一入口 |
| MonthPickerButton | 否 | 无 | 需开发 | 新开发 | 无月份选择入口组件 | stats | 需确认选择器形式 |
| FinanceOverviewCard | 否 | 无 | 需开发 | 新开发 | 当前仓库无统一摘要金额卡 | stats | 可与首页共建通用摘要卡 |
| MetricSegmentToggle | 否 | 无 | 需开发 | 新开发 | 无分段切换组件 | stats | 支出/收入切换 |
| WeeklyBarChartCard | 否 | 无 | 需开发 | 新开发 | 无统计图表组件 | stats | 需确认是否引入图表库 |
| WeeklyBarItem | 否 | 无 | 需开发 | 新开发 | 无柱状图条目组件 | stats | 可自绘 |
| CategoryRankingCard | 否 | 无 | 需开发 | 新开发 | 无分类排行卡片 | stats | 包含查看更多入口 |
| CategoryRankItem | 否 | 无 | 需开发 | 新开发 | 无分类排行条目组件 | stats | 含图标、金额、进度条 |

## 汇总结论

- 当前仓库没有任何可直接匹配的统计页业务 UI 组件，全部为需开发项。
- 优先建议统一抽象的统计组件族：
	- AppBottomNavBar + PrimaryActionFab
	- FinanceOverviewCard
	- WeeklyBarChartCard + WeeklyBarItem
	- CategoryRankingCard + CategoryRankItem
- 主题策略建议：统计页深浅版共用一套组件结构，仅切换颜色、边框、阴影、surface 和 emphasis token。

