# 实现计划 — OneKeep 首页客户端

## 关联文档

| 文档 | 路径 |
| --- | --- |
| 布局分析 | `01-layout/pages/home.md` |
| PRD | `02-requirements/prd.md` |
| 交互规格 | `02-requirements/interaction-spec.md` |
| 客户端架构 | `04-architecture/client-architecture.md` |

## 范围冻结（本期）

- **仅实现客户端首页**，不涉及服务端
- 数据层使用 Mock（`HomeRepositoryMock`）模拟 800ms 延迟
- TabBar 其他 3 个 tab 展示占位页面
- FAB 点击弹出占位弹窗（记账弹窗待后续 slice）
- 搜索/通知图标点击显示 Toast 占位

## 切片规划

| Slice | 内容 | 需求编号 |
| --- | --- | --- |
| S1 | pubspec.yaml + main.dart + app.dart + AppShell | FR-012 FR-013 FR-014 |
| S2 | core/theme + core/money | 全局基础 |
| S3 | 领域实体：MonthlyBalance / MonthSummary / UserProfile / Transaction / Category | FR-004~009 |
| S4 | 应用层：HomeState / HomeNotifier / HomeRepositoryMock | FR-004~009 FR-016~018 |
| S5 | 共享组件：Avatar / HeaderIconButton / SectionHeader / DateLabel / TabItem / BottomTabBar / PrimaryFAB / Shimmer / Empty / Error | 全局 |
| S6 | 首页组件：BalanceCard / SummaryCard / UserGreeting / TransactionItem | FR-004~009 |
| S7 | HomePage 组装（加载/成功/错误/空态） | FR-001~018 AC-001~012 |

## 技术选型

| 关注点 | 选型 |
| --- | --- |
| 状态管理 | flutter_riverpod ^3.0.0（AsyncNotifier） |
| 数据层 | Mock Repository（延迟 800ms 模拟网络） |
| 路由 | 暂无（IndexedStack + StateProvider） |
| 字体 | 系统默认（Google Fonts 后续引入） |
| 数字格式 | 纯 Dart 实现（无外部 intl 依赖） |

## 文件结构

```
client/lib/
├── main.dart                   ← 更新
├── app.dart                    ← 新增
├── core/
│   ├── theme/app_theme.dart    ← 新增
│   └── money/money.dart        ← 新增
├── features/
│   ├── home/
│   │   ├── domain/entities/    ← 新增 3 个实体
│   │   ├── domain/repositories/← 新增接口
│   │   ├── application/        ← 新增 Notifier + State
│   │   ├── infrastructure/     ← 新增 Mock
│   │   └── presentation/       ← 新增 HomePage + widgets
│   └── transaction/
│       ├── domain/entities/    ← 新增 2 个实体
│       └── presentation/widgets/← 新增 TransactionItem
└── shared/widgets/             ← 新增 10 个共享组件
```

## 验收检查（对照 AC）

- [ ] AC-001: 进入首页 3s 内显示数据（Mock 模拟 800ms）
- [ ] AC-002: 当前时间对应正确问候语
- [ ] AC-003: 环比图标方向正确
- [ ] AC-004: 账单列表按日期分组 ≤5 条
- [ ] AC-005: 无账单时显示空态
- [ ] AC-006: FAB 点击弹出弹窗
- [ ] AC-007: 记账保存后列表刷新（Mock 场景）
- [ ] AC-009: TabBar 切换高亮正确
- [ ] AC-010: 数据加载失败展示错误态
- [ ] AC-011: 点击重试重新加载
