# 财务App首页 — 布局分析

## 1. 输入信息

- **来源**：Pencil 设计稿 (`one_keep.pen`)，frame ID `kQI0n`
- **分析页面**：财务App首页
- **设备假设**：移动端（402 × 874，约 iPhone 14 尺寸）
- **已知约束**：Flutter 项目，当前代码库仅含空白 `main.dart`，无现有可复用组件

---

## 2. 页面结构

| 区域 | 目标 | 布局类型 | 备注 |
| --- | --- | --- | --- |
| StatusBar（状态栏） | 系统时间 + 信号/电量图标 | 水平 `space_between` | 系统级，Flutter 自动管理 |
| TopBar（顶部栏） | 用户头像 + 问候语/用户名 + 搜索/通知图标 | 水平 `space_between` | |
| BalanceCard（结余卡片） | 展示本月结余金额及环比变化 | 垂直 | 绿色渐变填充 + 外阴影 |
| IncomeExpenseRow（收支统计） | 收入卡片 + 支出卡片并排 | 水平 `gap` | 两卡片等宽 |
| RecentTransactions（近期账单） | 标题 + "查看全部" + 按日期分组的账单列表 | 垂直 | 列表项结构统一 |
| TabBar（底部导航） | 4 个 tab（首页/统计/账单/我的） | 水平 `space_between` | 底部固定，带顶部描边 |
| FAB（浮动按钮） | 中心快速记账入口 | 绝对定位叠层 | 悬浮于 TabBar 之上 |

---

## 3. 布局树

```
Page (frame, absolute layout, 402×874)
├── StatusBar (水平, space_between, h=62, padding 0/24)
│   ├── TimeText "9:41"
│   └── StatusIcons (信号/WiFi/电池)
├── ContentArea (垂直, gap=$spacing-section, padding 0/24, 可滚动区域, h=724)
│   ├── TopBar (水平, space_between)
│   │   ├── UserInfo (水平, gap=12)
│   │   │   ├── Avatar (48×48, 圆形, 橙色渐变)
│   │   │   │   └── Icon(user, white, 28×28)
│   │   │   └── UserText (垂直, gap=2)
│   │   │       ├── Greeting "晚上好，" (13px, $text-secondary)
│   │   │       └── UserName "Alex Johnson" (16px, 600, $text-primary)
│   │   └── HeaderIcons (水平, gap=16)
│   │       ├── Icon(search, 22×22, $text-tertiary)
│   │       └── Icon(bell, 22×22, $text-primary)
│   ├── BalanceCard (垂直, gap=20, padding=28/24, 圆角=$radius-large)
│   │   ├── [渐变] #22C55E → #16A34A, 135°
│   │   ├── [阴影] blur=24, color=#22C55E30, offset=(0,8)
│   │   ├── Label "本月结余" (13px, white, opacity=0.9)
│   │   ├── Amount "¥8,240.50" (40px, 800, white, Bricolage Grotesque)
│   │   └── BalanceChange (水平, gap=6)
│   │       ├── Icon(trending-up, white, 16×16)
│   │       └── Text "+12%" (14px, 600, white)
│   ├── IncomeExpenseRow (水平, gap=$spacing-card)
│   │   ├── IncomeCard (垂直, gap=12, padding=20, 圆角=$radius-large, fill=$bg-income)
│   │   │   ├── IncomeHeader (水平, gap=8)
│   │   │   │   ├── IconBadge(arrow-down-left, $accent-green, 32×32, 圆角16)
│   │   │   │   └── Label "收入" (13px, $text-secondary)
│   │   │   └── Amount "¥12,450" (20px, 700, $text-primary)
│   │   └── ExpenseCard (垂直, gap=12, padding=20, 圆角=$radius-large, fill=$bg-expense)
│   │       ├── ExpenseHeader (水平, gap=8)
│   │       │   ├── IconBadge(arrow-up-right, $accent-red, 32×32, 圆角16)
│   │       │   └── Label "支出" (13px, $text-secondary)
│   │       └── Amount "¥4,209" (20px, 700, $text-primary)
│   └── RecentTransactions (垂直, gap=16)
│       ├── TransactionHeader (水平, space_between)
│       │   ├── Title "近期账单" (18px, 700, $text-primary, Bricolage Grotesque)
│       │   └── ViewAllBtn (水平, gap=4)
│       │       ├── Text "查看全部" (13px, $text-tertiary)
│       │       └── Icon(chevron-right, 16×16, $text-tertiary)
│       └── TransactionList (垂直, gap=8)
│           ├── DateLabel "今天" (11px, 600, $text-tertiary, letter-spacing=0.5)
│           ├── TransactionItem(utensils, #F97316, #FFF7ED, "全家便利店", "支出", "-32.50")
│           ├── TransactionItem(car, #3B82F6, #EFF6FF, "滴滴出行", "支出", "-45.00")
│           ├── TransactionItem(wallet, $accent-green, #F0FDF4, "工资收入", "收入", "+12,450.00", amountColor=$accent-green)
│           ├── DateLabel "昨天"
│           └── TransactionItem(shopping-bag, #F59E0B, #FEF3C7, "优衣库", "支出", "-299.00")
├── TabBar (水平, space_between, h=88, padding=12/16/34/16, 底部固定)
│   ├── [背景] $bg-primary
│   ├── [描边] top, 1px, $border-subtle
│   ├── TabItem(house, "首页", active=true, color=$accent-green)
│   ├── TabItem(chart-bar, "统计", color=$text-tertiary)
│   ├── TabItem(receipt, "账单", color=$text-tertiary)
│   └── TabItem(user, "我的", color=$text-tertiary)
└── FAB (绝对定位, x=165, y=762, 叠于 TabBar 上方)
    └── FabButton (72×72, 圆角=36, 渐变 #22C55E→#16A34A, 阴影 blur=16)
        └── Icon(plus, white, 36×36)
```

---

## 4. 组件清单

| 组件名 | 可复用 | 参数/配置 | 状态 | 备注 |
| --- | --- | --- | --- | --- |
| `Avatar` | 是 | `size`, `iconName`, `gradientColors` | default | 圆形渐变背景 + 图标，"我的"页可复用 |
| `UserGreeting` | 否 | `greeting`, `userName` | default | 首页专属头部信息 |
| `HeaderIconButton` | 是 | `icon`, `color`, `onTap` | default / pressed | 顶栏搜索/通知通用 |
| `BalanceCard` | 否 | `label`, `amount`, `changePercent`, `changeIcon` | default | 绿色渐变大卡片，首页唯一 |
| `SummaryCard` | 是 | `icon`, `iconColor`, `iconBgColor`, `label`, `amount` | default | 收入/支出共用同一结构 |
| `TransactionItem` | 是 | `icon`, `iconColor`, `iconBgColor`, `title`, `subtitle`, `amount`, `amountColor` | default | 账单页面可高度复用 |
| `SectionHeader` | 是 | `title`, `actionText`, `onAction` | default | "近期账单 + 查看全部" 模式，多页可复用 |
| `DateLabel` | 是 | `text` | default | 账单日期分组标签，极简组件 |
| `BottomTabBar` | 是 | `tabs[]`, `activeIndex`, `onTap` | per-tab active/inactive | 全局导航支架 |
| `TabItem` | 是 | `icon`, `label`, `isActive` | active / inactive | 作为 BottomTabBar 子组件 |
| `PrimaryFAB` | 是 | `icon`, `gradientColors`, `onTap` | default / pressed | Flutter 内置 FAB 不支持渐变，需自定义 |

### 4.1 组件复用决策表

| 候选组件 | 是否已有 | 已有组件路径 | 决策 | 新增原因 | 备注 |
| --- | --- | --- | --- | --- | --- |
| `Avatar` | 否 | — | 新增 | 项目初始化，无现有组件 | "我的"页同样需要 |
| `HeaderIconButton` | 否 | — | 新增 | 无现有组件 | 全局通用 |
| `BalanceCard` | 否 | — | 新增 | 无现有组件 | 首页独有 |
| `SummaryCard` | 否 | — | 新增 | 无现有组件 | 收/支结构一致，共用一个组件 |
| `TransactionItem` | 否 | — | 新增 | 无现有组件 | 账单页面可高度复用 |
| `SectionHeader` | 否 | — | 新增 | 无现有组件 | 多页面可复用 |
| `DateLabel` | 否 | — | 新增 | 无现有组件 | 也可内联，优先级低 |
| `BottomTabBar` | 否 | — | 新增 | 无现有组件 | App 全局 |
| `TabItem` | 否 | — | 新增 | 无现有组件 | BottomTabBar 子组件 |
| `PrimaryFAB` | 否 | — | 新增 | Flutter 内置 FAB 不支持该渐变样式 | 跨页面共享 |

> 当前 `client/lib/` 仅含空白 `main.dart`，所有组件均需新增。

---

## 5. 交互与状态说明

| 交互入口 | 行为 | 目标页面/组件 |
| --- | --- | --- |
| FAB "+" 点击 | 弹出快速记账弹窗 | 快速记账弹窗（frame `b2q17`） |
| "查看全部" 点击 | 跳转账单列表 | 账单页面（frame `QhsjF`） |
| TabBar "统计" | 切换至统计页 | 统计页面（frame `GY0Di`） |
| TabBar "账单" | 切换至账单页 | 账单页面（frame `QhsjF`） |
| TabBar "我的" | 切换至个人中心 | 我的页面（frame `XBSrr`） |
| 搜索图标点击 | 打开搜索功能 | 待定（设计稿未体现） |
| 通知图标点击 | 打开通知列表 | 待定（设计稿未体现） |
| 账单项点击 | 查看账单详情 | 待定（设计稿无详情页） |

### 状态矩阵

| 区域 | 空态 | 加载态 | 错误态 | 成功态 |
| --- | --- | --- | --- | --- |
| 结余卡片 | — | 骨架屏 / shimmer | 网络异常提示 | 默认（已设计） |
| 收支统计 | — | 骨架屏 | 网络异常提示 | 默认（已设计） |
| 账单列表 | 无记录插图 + 文案 | 骨架屏列表 | 重试按钮 | 默认（已设计） |

> 观察结论：设计稿仅呈现成功态，其余状态需设计方补充。

---

## 6. 响应式与可访问性说明

- **断点假设**：纯移动端，宽 402px，暂无平板 / 桌面适配需求
- **键盘与焦点**：TabBar 各 Tab 及 FAB 需支持 Flutter `Focus` 可达；账单列表项需提供 `Semantics` 标签
- **对比度风险**：
  - 结余卡片白色文字在绿色渐变底上对比度良好（推断 ≥ 4.5:1）
  - `$text-secondary` / `$text-tertiary` 实际色值需确认满足 WCAG AA
  - 结余变化 "+12%" 白色 14px 字在渐变浅绿端需核查

---

## 7. 待确认问题与假设

### 待确认问题

1. 账单列表是否支持无限滚动或分页加载？
2. 问候语 "晚上好" 是否随当前时间动态变化？
3. "查看全部" 是否跳转至账单页，还是筛选后的账单页？
4. 搜索和通知功能的具体交互流程？
5. 账单详情页是否在本期规划内？
6. `$bg-income` / `$bg-expense` / `$text-secondary` 等 Design Token 的具体色值？

### 假设

- 问候语根据当前时间动态显示（早上好 / 下午好 / 晚上好）
- ContentArea 为可滚动区域，TabBar 和 FAB 采用 `Stack` + 固定定位
- 账单金额：支出为负数（默认文字色），收入为正数（`$accent-green`）
- StatusBar 由系统提供，Flutter 使用 `SystemChrome` 管理样式，无需自行绘制
