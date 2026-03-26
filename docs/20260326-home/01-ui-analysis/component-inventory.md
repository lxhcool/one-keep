# 组件清单

| 组件 | 项目内是否已有可匹配组件 | 匹配组件路径 | 匹配结论（可匹配/需开发） | 处理方式 | 需开发原因 | 覆盖页面 | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| AppBottomNavBar | 否 | 无 | 需开发 | 新开发 | 当前仓库没有底部导航体系 | home | 首页仍需依赖全局导航框架 |
| PrimaryActionFab | 否 | 无 | 需开发 | 新开发 | 当前仓库没有主操作 FAB | home | 首页保留新增记账入口 |
| RoundIconButton | 否 | 无 | 需开发 | 新开发 | 无通用圆角图标按钮 | home | 可承载通知与金额显隐按钮 |
| HomeHeader | 否 | 无 | 需开发 | 新开发 | 无头像、问候、通知入口组合组件 | home | 仅首页使用 |
| BalanceSummaryCard | 否 | 无 | 需开发 | 新开发 | 无余额卡片、金额显隐逻辑 | home | 首页核心模块 |
| FinanceMetricCard | 否 | 无 | 需开发 | 新开发 | 当前仓库无统一摘要金额卡 | home | 首页收入/支出卡片 |
| SectionHeaderAction | 否 | 无 | 需开发 | 新开发 | 无列表分区头组件 | home | 最近记账标题区 |
| TransactionItemCard | 否 | 无 | 需开发 | 新开发 | 仓库无交易项卡片 | home | 后续可与 bills 统一建模 |
| TransactionList | 否 | 无 | 需开发 | 新开发 | 无最近交易列表容器 | home | 需支持加载/空/错误态 |

## 汇总结论

- 当前仓库没有任何可直接匹配的首页业务 UI 组件，首页所需组件均为需开发。
- 建议优先统一抽象的首页组件族：
  - AppBottomNavBar + PrimaryActionFab
  - FinanceMetricCard
  - TransactionItemCard + TransactionList
  - RoundIconButton
- 主题策略建议：首页深浅版共用一套组件结构，仅切换颜色、边框、阴影、surface 和 emphasis token。
