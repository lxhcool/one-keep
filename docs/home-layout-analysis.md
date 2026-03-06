# 首页布局分析（home）

## 1. 输入信息

- 来源：设计稿截图（`ui/home.jpg`）
- 分析页面：首页（记账明细页）
- 设备假设：移动端 Android，设计稿视觉宽度约 360dp（等比观察）
- 已知约束：当前仅提供单张静态设计稿，未提供交互动效与标注尺寸

## 2. 页面结构

| 区域 | 目标 | 布局类型 | 备注 |
| --- | --- | --- | --- |
| 页头 | 展示品牌与月度收支概览 | 单列 + 三分栏统计 | 黄底，含标题、月份、收入、支出 |
| 主内容 | 提供快捷入口与账单明细浏览 | 单列（入口条 + 分组列表） | 功能入口 5 列；账单按日期分组 |
| 侧边栏 | 无 | 无 | 移动端单栏页面 |
| 页脚 | 一级导航与主操作入口 | 底部导航 + 中央凸起按钮 | 中央“+”为核心记账操作 |

## 3. 布局树

```text
HomePage
  SafeArea
    HeaderSummarySection
      TopStatusRow (avatar / title)
      MonthlySummaryRow
        MonthSelector
        IncomeMetric
        ExpenseMetric
    QuickActionTabs
      QuickActionItem x5
    TransactionGroupList
      DateGroupHeader
      TransactionItem xN
      DateGroupHeader
      TransactionItem xN
  BottomMainNav
    NavItem(明细)
    NavItem(图表)
    CenterRecordButton(+)
    NavItem(发现)
    NavItem(我的)
```

## 4. 组件清单

| 组件名 | 可复用 | 参数/配置 | 状态 | 备注 |
| --- | --- | --- | --- | --- |
| HeaderSummarySection | 是 | month, incomeAmount, expenseAmount, appTitle | default/loading/error | 首页顶部核心模块 |
| SummaryMetricItem | 是 | label, value, align, hasDivider | default | 用于收入/支出/月份单元 |
| QuickActionTabs | 是 | items[] | default | 5 宫格入口容器 |
| QuickActionItem | 是 | icon, title, badge, onTap | default/pressed/disabled | 可用于其它页面入口宫格 |
| TransactionGroupList | 是 | groups[] | default/empty/loading/error | 支持按日期分组 |
| DateGroupHeader | 是 | dateLabel, dayTotal | default | 分组头展示日期与当日总额 |
| TransactionItem | 是 | categoryIcon, categoryName, amount, note | default/pressed | 明细行组件 |
| BottomMainNav | 是 | selectedTab, onTabChange | default | 全局底部导航 |
| CenterRecordButton | 是 | onTap, hasShadow | default/pressed | 全局主操作按钮 |

## 5. 交互与状态说明

- 导航行为：
  - 底部导航点击切换一级页面；当前页为“明细”。
  - 功能入口点击跳转对应业务页（账单/预算/资产管家/购物返现/更多）。
- 弹层/模态行为：
  - 点击“月份”触发月份选择器（推断：底部弹出或日历选择）。
  - 点击中央“+”触发记账类型选择（推断：支出/收入快捷入口）。
- 表单/校验行为：
  - 本页主要为浏览与导航入口，无直接表单输入。
- 空态/加载态/错误态：
  - 空态：当月无明细时展示引导“去记一笔”。
  - 加载态：顶部统计和列表使用骨架屏占位。
  - 错误态：显示失败提示并提供重试。

## 6. 响应式与可访问性说明

- 断点假设：
  - `<=390dp`：维持 5 个入口等分，文字可缩短或降一号字。
  - `391dp~480dp`：按设计稿比例放大间距与字号。
  - `>480dp`：建议限制内容最大宽度并居中，避免过度拉伸。
- 键盘与焦点预期：
  - 触屏优先；可访问性场景下，焦点顺序应为：顶部摘要 → 快捷入口 → 明细列表 → 底部导航。
  - 所有可点击控件需提供语义标签（如“新增记账”“切换到图表”）。
- 对比度/可读性风险：
  - 黄色背景上的灰色小字对比度可能偏低，需要在实现时校验。
  - 金额字号较大且字重偏细，低端屏可能出现可读性波动。

## 7. 待确认问题与假设

- 待确认问题：
  - 顶部品牌区是否固定吸顶，还是随列表滚动。
  - 功能入口图标是否使用设计资源（SVG/PNG）而非系统图标。
  - 金额格式规则（是否强制两位小数、千分位、负号样式）。
  - 列表是否支持滑动操作（删除、编辑、置顶）。
- 假设：
  - 当前页面默认展示“本月”明细。
  - 列表数据按日期倒序、组内按时间倒序。
  - 底部导航为全局共享组件，中心按钮优先级高于普通导航项。

## 观察结论 vs 推断结论

- 观察结论：页面分为顶部摘要、入口条、分组明细、底部导航四块；中央“+”按钮凸起且强调。
- 推断结论：月份选择与新增记账均为弹层交互；列表需要空/加载/错误三类状态以支持真实数据。
