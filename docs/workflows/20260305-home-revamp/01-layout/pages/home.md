# 页面布局分析: home

## 输入信息

- 设计稿: `ui/home.jpg`
- 页面类型: 记账首页（移动端）
- 当前视觉主题: 顶部大面积黄色品牌区 + 白色内容区

## 布局树

1. Root（整页容器，纵向布局）
2. HeaderSummary（顶部品牌与统计区）
3. HeaderSummary.Title（品牌标题“One Keep”）
4. HeaderSummary.MonthFilter（年月选择，如“2025年 07月”）
5. HeaderSummary.Metrics（收入/支出两列统计）
6. DayGroupList（按日期分组的流水列表，可滚动）
7. DayGroup（日期 + 当日支出汇总）
8. DayGroup.RecordItem（分类图标、分类名称、金额）
9. BottomNav（底部导航栏）
10. BottomNav.Item*5（明细、图表、记账说明位、发现、我的）
11. FloatingRecordButton（底部中间悬浮“+”主操作按钮）

## 组件拆分

- `HomePageContainer`
  - 负责整页布局、背景色分层、滚动区域高度计算
- `HomeHeaderSummary`
  - 包含标题、月份筛选、收入/支出统计
- `SummaryMetricCard`（可复用）
  - 单个指标展示（标题 + 金额）
- `TransactionDaySection`
  - 日期头 + 当日汇总 + 列表项容器
- `TransactionItemRow`（高复用）
  - 分类图标、分类名、金额、点击详情
- `BottomTabBar`
  - 底部五项导航和选中态
- `CenterAddButton`
  - 悬浮主按钮，触发记账主流程

## 交互与状态

- 月份切换:
  - 点击月份区域后选择目标月份，刷新当月统计和流水列表
- 流水列表:
  - 支持纵向滚动
  - 点击流水项进入明细页（推测）
- 底部导航:
  - 仅 `明细/图表/发现/我的` 可点击并参与高亮
  - 中间“记账”为说明位，不可点击、不参与高亮
- 悬浮记账按钮:
  - 点击进入“新增流水”流程（核心主动作）
- 关键状态字段（建议）:
  - `selectedMonth`
  - `monthlyIncome`
  - `monthlyExpense`
  - `dayGroups[]`
  - `activeBottomTab`（仅四个可点击导航项）
  - `isLoading` / `isError`

## 待确认问题与假设

- 假设: 首页默认展示“当前月”数据，且金额单位为人民币。
- 待确认: 月份选择交互是下拉、日历弹层还是独立页面。
- 待确认: 流水项点击后的目标是“详情页”还是“编辑弹层”。
- 已确认: 底部中间“记账”用于说明入口，不可点击且不高亮。
