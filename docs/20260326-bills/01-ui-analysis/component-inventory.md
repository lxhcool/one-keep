# 组件清单

| 组件 | 项目内是否已有可匹配组件 | 匹配组件路径 | 匹配结论（可匹配/需开发） | 处理方式 | 需开发原因 | 覆盖页面 | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| AppBottomNavBar | 否 | 无 | 需开发 | 新开发 | 当前仓库没有底部导航体系 | bills | 与首页、统计页共享框架 |
| PrimaryActionFab | 否 | 无 | 需开发 | 新开发 | 当前仓库没有主操作 FAB | bills | 新增记账统一入口 |
| SearchIconButton | 否 | 无 | 需开发 | 新开发 | 无通用搜索图标按钮 | bills | 可沉淀为基础组件 |
| FilterChipGroup | 否 | 无 | 需开发 | 新开发 | 无胶囊筛选组件 | bills | 全部/支出/收入筛选 |
| DateGroupedBillSection | 否 | 无 | 需开发 | 新开发 | 无日期分组列表结构 | bills | 支持日期头与分组汇总 |
| BillItemCard | 否 | 无 | 需开发 | 新开发 | 仓库无交易项卡片 | bills | 可与首页交易卡统一建模 |

## 汇总结论

- 当前仓库没有任何可直接匹配的账单页业务 UI 组件，全部为需开发项。
- 优先建议统一抽象的账单组件族：
	- AppBottomNavBar + PrimaryActionFab
	- SearchIconButton + FilterChipGroup
	- DateGroupedBillSection + BillItemCard
- 主题策略建议：账单页深浅版共用一套组件结构，仅切换颜色、边框、阴影、surface 和 emphasis token。

