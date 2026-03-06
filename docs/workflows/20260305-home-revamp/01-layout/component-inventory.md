# 组件清单

| 组件 | 是否复用 | 覆盖页面 | 备注 |
| --- | --- | --- | --- |
| HomePageContainer | 否 | home | 首页专用容器，负责分区布局与滚动承载 |
| HomeHeaderSummary | 否 | home | 顶部品牌与收入/支出统计区 |
| SummaryMetricCard | 是 | home/其他统计页(候选) | 统计值展示卡片，可在多处复用 |
| TransactionDaySection | 是 | home/账单页(候选) | 日期分组容器，含分组汇总 |
| TransactionItemRow | 是 | home/账单页/搜索结果(候选) | 流水行，金额正负样式可配置 |
| BottomTabBar | 是 | 全站主框架页 | 一级导航容器 |
| BottomNavItem | 是 | 全站主框架页 | 导航项（默认/激活/红点） |
| CenterAddButton | 是 | 全站主框架页 | 记账主动作按钮，位于底部中心 |
