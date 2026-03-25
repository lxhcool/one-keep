# 组件清单 — 001-home-layout

> 本文件汇总首页分析中识别的所有候选组件，标注跨页面复用情况。

## 组件列表

| 组件名 | 所在页面 | 跨页面复用 | 优先级 | 路径规划 |
| --- | --- | --- | --- | --- |
| `Avatar` | 首页、我的页面 | 是 | 高 | `lib/shared/widgets/avatar.dart` |
| `HeaderIconButton` | 首页 | 是 | 中 | `lib/shared/widgets/header_icon_button.dart` |
| `BalanceCard` | 首页 | 否 | 高 | `lib/features/home/widgets/balance_card.dart` |
| `SummaryCard` | 首页 | 是（统计页可能复用） | 高 | `lib/shared/widgets/summary_card.dart` |
| `TransactionItem` | 首页、账单页面 | 是 | 高 | `lib/shared/widgets/transaction_item.dart` |
| `SectionHeader` | 首页 | 是（多页面） | 中 | `lib/shared/widgets/section_header.dart` |
| `DateLabel` | 首页、账单页面 | 是 | 低 | `lib/shared/widgets/date_label.dart` |
| `BottomTabBar` | 全局 | 是 | 高 | `lib/shared/widgets/bottom_tab_bar.dart` |
| `TabItem` | 全局（BottomTabBar子组件） | 是 | 高 | `lib/shared/widgets/tab_item.dart` |
| `PrimaryFAB` | 全局 | 是 | 高 | `lib/shared/widgets/primary_fab.dart` |

## 共享组件（`lib/shared/`）

跨页面使用，统一放置于 `shared/widgets/`：

- `Avatar`
- `HeaderIconButton`
- `SummaryCard`
- `TransactionItem`
- `SectionHeader`
- `DateLabel`
- `BottomTabBar`
- `TabItem`
- `PrimaryFAB`

## 页面私有组件（`lib/features/home/`）

仅首页使用，不提升至 shared：

- `BalanceCard`（首页专属大卡片）
- `UserGreeting`（首页专属用户问候区）

## 来源页面

| 页面 | 分析文档 |
| --- | --- |
| 财务App首页 | [pages/home.md](pages/home.md) |
