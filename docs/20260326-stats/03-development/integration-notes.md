# 联调记录

## 联调范围

| 服务端接口/模块 | 客户端页面/组件 | 联调状态 | 备注 |
| --- | --- | --- | --- |
| /api/stats/overview | StatsPage / WeeklyBarChartCard / CategoryRankingCard | 未开始 | 需覆盖切月和指标切换 |

## 问题与阻塞

| 问题 | 影响 | 当前处理 | 下一步 |
| --- | --- | --- | --- |
| 月份选择器形式未确认 | 影响交互联调细节 | 文档先按占位处理 | 开发前拍板 |
| 统计口径未冻结 | 影响图表与排行一致性 | 要求服务端显式返回 progressBase | 开发前冻结口径 |

## 若尚未联调

| 原因 | 缺失前置条件 | 预计后续动作 |
| --- | --- | --- |
| 当前补的是开发文档，不是实现代码 | 统计接口和页面还未落地 | 先完成 stats-service 与 StatsPage |

## 推荐联调顺序

1. 验证 totals 渲染。
2. 验证 metricType 切换后的 trendSeries。
3. 验证 categoryRanks 与 progressBase 的展示。

