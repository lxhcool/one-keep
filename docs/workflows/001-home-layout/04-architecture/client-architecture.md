# 客户端架构设计 — OneKeep 财务App 首页

## 1. 输入与范围

| 属性 | 值 |
| --- | --- |
| 输入文档 | `01-layout/pages/home.md`、`02-requirements/prd.md`、`02-requirements/interaction-spec.md` |
| 页面范围 | 财务App首页（含全局导航 TabBar + FAB） |
| 需求编号 | FR-001 ~ FR-018、IR-001 ~ IR-008、NFR-001 ~ NFR-009 |
| 技术栈 | Flutter (Dart)，状态管理待定（推荐 Riverpod / flutter_bloc） |

---

## 2. 客户端分层设计

```
┌─────────────────────────────────────────────────────┐
│               展示层（Presentation）                  │
│   Pages / Widgets — 仅持有 UI 状态，调用用例          │
├─────────────────────────────────────────────────────┤
│            应用编排层（Application）                  │
│   UseCases / Notifiers — 编排流程，不含 UI           │
├─────────────────────────────────────────────────────┤
│            领域表示层（Domain）                       │
│   Entities / ValueObjects / Repository interfaces   │
├─────────────────────────────────────────────────────┤
│            基础设施层（Infrastructure）               │
│   API Client / DTO / Local Cache / Mappers          │
└─────────────────────────────────────────────────────┘
依赖方向：展示层 → 应用编排层 → 领域表示层 ← 基础设施层
```

| 层级 | 模块 | 责任 | 禁止 |
| --- | --- | --- | --- |
| **展示层** | `HomePage`、`BalanceCard`、`SummaryCard`、`TransactionItem`、`BottomTabBar`、`PrimaryFAB` | 渲染 ViewModel、响应用户手势、驱动动效 | 内聚业务规则；直接调用 API；处理 DTO |
| **应用编排层** | `HomeNotifier`/`HomeCubit`、`QuickRecordUseCase`、`FetchHomeDataUseCase` | 编排多个 Repository 调用；管理 Loading/Success/Error 状态；防抖/重试逻辑 | 依赖 Flutter Widget；操作 UI |
| **领域表示层** | `MonthlyBalance`、`Transaction`、`TransactionCategory`、`MonthSummary`、`UserProfile`、`HomeRepository`（接口） | 定义业务实体与值对象；声明仓储接口；问候语计算规则 | 依赖任何框架或具体实现 |
| **基础设施层** | `HomeApiClient`、`HomeLocalCache`、`MonthlyBalanceDto`、`TransactionDto`、`HomeDtoMapper` | 实现 Repository 接口；HTTP 请求；本地持久化（SharedPreferences/Hive）；DTO↔Entity 映射 | 直接被展示层调用 |

---

## 3. 页面到模块映射

| 页面 / 组件 | 应用用例 / Notifier | 状态容器 | 数据源 |
| --- | --- | --- | --- |
| `HomePage` | `FetchHomeDataUseCase` | `HomeState` (Loading/Success/Error) | `HomeRepository` |
| `BalanceCard` | — | `HomeState.balance` (MonthlyBalance?) | HomeNotifier 驱动 |
| `SummaryCard` (收入/支出) | — | `HomeState.summary` (MonthSummary?) | HomeNotifier 驱动 |
| `TransactionItem` × N | — | `HomeState.recentTransactions` (List\<Transaction\>) | HomeNotifier 驱动 |
| `PrimaryFAB` (首页) | `QuickRecordUseCase` | 弹窗状态由 Modal 持有（局部状态） | — |
| `BottomTabBar` | — | `AppNavigationState.currentTab` (全局) | 全局路由状态容器 |
| 下拉刷新 | `FetchHomeDataUseCase` (force refresh) | 复用 HomeState | HomeRepository（跳过缓存） |
| 快速记账弹窗 | `QuickRecordUseCase` | `QuickRecordState` (独立局部 Notifier) | `TransactionRepository` |

### 状态容器定义

```dart
// 首页聚合状态
sealed class HomeState {
  const HomeState();
}
class HomeLoading extends HomeState {}
class HomeSuccess extends HomeState {
  final MonthlyBalance balance;
  final MonthSummary summary;
  final List<Transaction> recentTransactions;
  const HomeSuccess({
    required this.balance,
    required this.summary,
    required this.recentTransactions,
  });
}
class HomeError extends HomeState {
  final String message;
  final Object? cause;
  const HomeError(this.message, {this.cause});
}

// 快速记账弹窗状态
sealed class QuickRecordState {
  const QuickRecordState();
}
class QuickRecordIdle extends QuickRecordState {}
class QuickRecordSubmitting extends QuickRecordState {}
class QuickRecordSuccess extends QuickRecordState {
  final Transaction saved;
  const QuickRecordSuccess(this.saved);
}
class QuickRecordError extends QuickRecordState {
  final String message;
  const QuickRecordError(this.message);
}
```

---

## 4. 领域实体与值对象

```dart
// 本月汇总余额
class MonthlyBalance {
  final Money amount;          // 结余金额（可负）
  final double? changePercent; // 环比百分比，null = 数据缺失
  final bool isIncrease;       // 是否为增长方向

  String get formattedAmount => amount.format();  // '¥8,240.50' / '¥-1,230.00'
  String? get formattedChange => changePercent == null
      ? null
      : '${isIncrease ? '+' : '-'}${changePercent!.abs().toStringAsFixed(0)}%';
}

// 月度收支汇总
class MonthSummary {
  final Money totalIncome;
  final Money totalExpense;
}

// 账单条目
class Transaction {
  final String id;
  final TransactionType type; // income | expense
  final TransactionCategory category;
  final Money amount;         // 始终为正数，展示时由 type 决定符号
  final String title;
  final DateTime occurredAt;
}

// 分类
class TransactionCategory {
  final String id;
  final String name;
  final String iconName;   // lucide icon name
  final Color iconColor;
  final Color iconBgColor;
}

// 货币值对象
class Money {
  final int amountCents; // 以分为单位存储，避免浮点精度问题
  final String currency; // 'CNY'
  String format() { /* ¥#,###.## */ }
}

// 用户资料
class UserProfile {
  final String id;
  final String displayName;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return '早上好，';
    if (hour >= 12 && hour < 18) return '下午好，';
    return '晚上好，';
  }
}

// 仓储接口（领域层声明，基础设施层实现）
abstract interface class HomeRepository {
  Future<MonthlyBalance> fetchMonthlyBalance({bool forceRefresh = false});
  Future<MonthSummary> fetchMonthSummary({bool forceRefresh = false});
  Future<List<Transaction>> fetchRecentTransactions({int limit = 5, bool forceRefresh = false});
}

abstract interface class TransactionRepository {
  Future<Transaction> save(TransactionDraft draft);
}

abstract interface class UserRepository {
  Future<UserProfile> fetchProfile();
}
```

---

## 5. 应用服务与用例

### FetchHomeDataUseCase

```
触发：进入首页 / 下拉刷新 / 记账成功后回调
步骤：
  1. emit HomeLoading
  2. 并行调用 HomeRepository.fetchMonthlyBalance / fetchMonthSummary / fetchRecentTransactions
  3. 全部成功 → emit HomeSuccess
  4. 任一失败 → emit HomeError（保留上次缓存数据用于展示）
  5. 防抖：500ms 内重复调用合并为一次
```

### QuickRecordUseCase

```
触发：FAB 点击后弹窗内"保存"按钮
步骤：
  1. emit QuickRecordSubmitting
  2. 调用 TransactionRepository.save(draft)
  3. 成功 → emit QuickRecordSuccess(saved)
         → 通知 HomeNotifier 静默刷新账单列表
  4. 失败 → emit QuickRecordError(message)
  幂等保证：请求携带客户端生成的 idempotency_key（UUID）
```

---

## 6. 状态流与异常路径

### 首页主状态机

```
                    [进入首页 / App 冷启动]
                           ↓
                      [HomeLoading]
                    ↙            ↘
           [HomeSuccess]      [HomeError]
           ↙    ↑    ↘           ↓
  [渲染数据] [下拉刷新] [记账保存    [点击重试]
                        成功回调]
                           ↓
                      [HomeLoading]（静默，保留上次数据）
                           ↓
                      [HomeSuccess]（更新交易列表）
```

### 状态切换规则

| 当前状态 | 触发事件 | 下一状态 | 说明 |
| --- | --- | --- | --- |
| — | 进入首页 | HomeLoading | 首次进入 |
| HomeLoading | 数据全部成功 | HomeSuccess | 正常路径 |
| HomeLoading | 任一请求失败 | HomeError | 降级展示缓存 |
| HomeSuccess | 下拉刷新 | HomeLoading | 展示骨架屏 |
| HomeSuccess | 记账成功回调 | HomeSuccess（更新列表） | 静默刷新，不显示骨架屏 |
| HomeError | 点击重试 | HomeLoading | 重新发起请求 |

### 异常处理策略

| 异常类型 | 客户端处理 | 用户反馈 |
| --- | --- | --- |
| 网络超时（>5s） | 中断请求 → HomeError | "网络超时，请重试" + 重试按钮 |
| HTTP 4xx（401） | 清除登录态 → 跳转登录页 | 无（透明跳转） |
| HTTP 4xx（非401） | HomeError | "数据加载失败" + 重试 |
| HTTP 5xx | HomeError，保留缓存 | "服务繁忙，请稍后重试" + 重试 |
| 解析异常 | HomeError，上报埋点 | "数据异常" + 重试 |
| 记账提交失败 | QuickRecordError | Toast "保存失败，请重试"，弹窗保持打开 |

### 本地缓存策略

| 数据 | 缓存层 | TTL | 失效场景 |
| --- | --- | --- | --- |
| MonthlyBalance | 内存 + Hive | 5 分钟 | 下拉刷新；记账保存成功 |
| MonthSummary | 内存 + Hive | 5 分钟 | 同上 |
| RecentTransactions | 内存 + Hive | 5 分钟 | 同上 |
| UserProfile | 内存 + SharedPreferences | 登录态有效期 | 退出登录 |

---

## 7. 数据与契约适配

### DTO → Entity 映射

#### 首页聚合接口响应（推断）

```json
// GET /api/v1/home/summary
{
  "balance": {
    "amount_cents": 824050,
    "currency": "CNY",
    "change_percent": 12.3,      // null = 新用户无历史
    "is_increase": true
  },
  "income_cents": 1245000,
  "expense_cents": 420900,
  "recent_transactions": [
    {
      "id": "txn_001",
      "type": "expense",
      "category_id": "food",
      "category_name": "餐饮",
      "icon_name": "utensils",
      "icon_color": "#F97316",
      "icon_bg_color": "#FFF7ED",
      "amount_cents": 3250,
      "title": "全家便利店",
      "occurred_at": "2026-03-25T10:30:00Z"
    }
  ]
}
```

#### Mapper 规则

| DTO 字段 | Entity 字段 | 转换规则 |
| --- | --- | --- |
| `amount_cents` | `Money.amountCents` | 直接映射，int |
| `change_percent` | `MonthlyBalance.changePercent` | null 安全，double? |
| `is_increase` | `MonthlyBalance.isIncrease` | bool |
| `occurred_at` | `Transaction.occurredAt` | ISO8601 → DateTime.parse().toLocal() |
| `type` | `TransactionType` | `"income"` → `TransactionType.income` |
| `amount_cents` (transaction) | `Money.amountCents` | 始终正数 |

### 错误码 → 用户反馈映射

| HTTP 状态 / 错误码 | 用户可见文案 | 操作 |
| --- | --- | --- |
| 401 | （无提示，静默跳转登录页） | 清除 Token，push 登录页 |
| 403 | "权限不足" | Toast |
| 404 | "数据不存在" | Toast |
| 408 / 网络超时 | "网络超时，请重试" | 重试按钮 |
| 5xx | "服务繁忙，请稍后重试" | 重试按钮 |
| 解析失败 | "数据异常，请重试" | 重试 + 上报 |

### 字段兼容策略

- 所有 DTO 字段使用 `null-safe` 解析，新增字段默认忽略（宽松 JSON 反序列化）
- `category_id` 未匹配本地枚举时，降级为默认图标（`wallet` + 灰色底）
- `change_percent` 为 null 时，客户端隐藏环比行，不报错

---

## 8. 目录结构

```
client/lib/
├── main.dart
├── app.dart                        # App 根组件，配置路由、主题、DI
│
├── core/                           # 跨模块基础设施（不含业务）
│   ├── network/
│   │   └── api_client.dart         # Dio 配置、拦截器
│   ├── cache/
│   │   └── hive_cache.dart
│   ├── error/
│   │   ├── app_exception.dart      # 统一异常类型
│   │   └── error_handler.dart      # HTTP → AppException 转换
│   ├── money/
│   │   └── money.dart              # Money 值对象（全局复用）
│   └── theme/
│       └── app_theme.dart          # Design Token 映射
│
├── features/
│   ├── home/                       # 首页特性模块
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── monthly_balance.dart
│   │   │   │   ├── month_summary.dart
│   │   │   │   └── user_profile.dart
│   │   │   └── repositories/
│   │   │       └── home_repository.dart        # 抽象接口
│   │   ├── application/
│   │   │   ├── home_state.dart                 # sealed class
│   │   │   ├── home_notifier.dart              # StateNotifier / Cubit
│   │   │   └── fetch_home_data_use_case.dart
│   │   ├── infrastructure/
│   │   │   ├── dtos/
│   │   │   │   └── home_response_dto.dart
│   │   │   ├── mappers/
│   │   │   │   └── home_dto_mapper.dart
│   │   │   └── home_repository_impl.dart       # 实现 HomeRepository
│   │   └── presentation/
│   │       ├── home_page.dart
│   │       └── widgets/
│   │           ├── balance_card.dart
│   │           ├── summary_card.dart
│   │           └── user_greeting.dart
│   │
│   ├── transaction/                # 账单特性模块（跨页面共享）
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── transaction.dart
│   │   │   │   └── transaction_category.dart
│   │   │   └── repositories/
│   │   │       └── transaction_repository.dart  # 抽象接口
│   │   ├── application/
│   │   │   ├── quick_record_state.dart
│   │   │   └── quick_record_use_case.dart
│   │   ├── infrastructure/
│   │   │   ├── dtos/
│   │   │   │   └── transaction_dto.dart
│   │   │   ├── mappers/
│   │   │   │   └── transaction_dto_mapper.dart
│   │   │   └── transaction_repository_impl.dart
│   │   └── presentation/
│   │       └── widgets/
│   │           └── transaction_item.dart        # 首页/账单页共用
│   │
│   └── auth/                       # 认证模块（独立）
│       └── ...
│
└── shared/                         # 纯展示共享组件（无业务逻辑）
    └── widgets/
        ├── avatar.dart
        ├── header_icon_button.dart
        ├── section_header.dart
        ├── date_label.dart
        ├── bottom_tab_bar.dart
        ├── tab_item.dart
        ├── primary_fab.dart
        └── states/
            ├── loading_shimmer.dart
            ├── empty_state.dart
            └── error_state.dart
```

---

## 9. 实施建议

### 依赖注入

推荐使用 `Riverpod`，在 `ProviderScope` 中注册：

```dart
// infrastructure 实现注册
final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    cache: ref.watch(hiveCacheProvider),
    mapper: const HomeDtoMapper(),
  ),
);

// 应用层用例
final homeNotifierProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(
    useCase: FetchHomeDataUseCase(ref.watch(homeRepositoryProvider)),
  ),
);
```

### 迭代落地顺序

| 迭代 | 任务 | 验收 |
| --- | --- | --- |
| Sprint 1 | `core/` 基础设施（网络、缓存、异常、Money） | 单元测试通过 |
| Sprint 1 | `shared/widgets/` 所有纯展示组件 | Widget Test 通过，与设计稿像素对齐 |
| Sprint 2 | `home/domain/` 实体与仓储接口 | 单元测试通过 |
| Sprint 2 | `home/application/` 状态机与用例 | 单元测试（Mock Repository） |
| Sprint 2 | `home/infrastructure/` DTO + Mapper + Repo 实现 | 集成测试 |
| Sprint 3 | `home/presentation/` 首页 + 状态绑定 | E2E 验收，对照 AC-001~AC-012 |
| Sprint 3 | `transaction/` 快速记账用例（弹窗） | 对照 AC-006~AC-007 |

### 风险与待确认项

| # | 风险/问题 | 影响 | 建议 |
| --- | --- | --- | --- |
| R-01 | 后端是否提供首页聚合接口，还是需要多次请求 | 影响并行加载策略与加载态设计 | 与后端确认是否有 `/home/summary` 聚合接口 |
| R-02 | 状态管理库选型（Riverpod vs Bloc）未确定 | 影响 Notifier 实现方式 | 团队尽早对齐；架构设计对两者均兼容 |
| R-03 | `TransactionCategory` 是否本地枚举或服务端下发 | 影响 fallback 图标策略 | 与产品/后端确认分类枚举的管理方 |
| R-04 | 离线缓存数据过期后展示问题 | 用户可能看到旧数据 | 缓存数据展示时需带有"上次更新时间"或 UI 灰化提示（待产品确认） |
| R-05 | Money 精度：服务端若返回浮点金额 | 精度丢失风险 | 强烈建议服务端统一返回 `amount_cents`（整数分） |
