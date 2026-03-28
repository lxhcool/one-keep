# 配色方案优化建议

## 优化目标

1. 提升品牌识别度
2. 增强视觉层次感
3. 改善色彩情感表达
4. 提高可访问性（对比度）

## 新配色方案

### 主色调优化

**方案 A：温暖渐变系**
```dart
// 主色：从 Teal 调整为更温暖的青绿色
static const primary = Color(0xFF06B6D4); // Cyan 500
static const primaryLight = Color(0xFF22D3EE); // Cyan 400
static const primaryDark = Color(0xFF0891B2); // Cyan 600

// 辅助色：使用橙色增加温暖感
static const secondary = Color(0xFFF97316); // Orange 500
static const secondaryLight = Color(0xFFFB923C); // Orange 400

// 强调色：保留紫色但调整饱和度
static const accent = Color(0xFF A855F7); // Purple 500
```

**方案 B：现代蓝紫系**
```dart
// 主色：使用更现代的蓝色
static const primary = Color(0xFF3B82F6); // Blue 500
static const primaryLight = Color(0xFF60A5FA); // Blue 400
static const primaryDark = Color(0xFF2563EB); // Blue 600

// 辅助色：紫色作为辅助
static const secondary = Color(0xFF8B5CF6); // Violet 500
static const secondaryLight = Color(0xFFA78BFA); // Violet 400

// 强调色：青色点缀
static const accent = Color(0xFF14B8A6); // Teal 500
```

**方案 C：优雅绿金系（推荐）**
```dart
// 主色：优雅的祖母绿
static const primary = Color(0xFF059669); // Emerald 600
static const primaryLight = Color(0xFF10B981); // Emerald 500
static const primaryDark = Color(0xFF047857); // Emerald 700

// 辅助色：温暖的琥珀金
static const secondary = Color(0xFFF59E0B); // Amber 500
static const secondaryLight = Color(0xFFFBBF24); // Amber 400

// 强调色：优雅的靛蓝
static const accent = Color(0xFF6366F1); // Indigo 500
```

### 功能色优化

```dart
// 支出：使用更柔和的红色
static const expense = Color(0xFFEF4444); // Red 500（当前 #F43F5E 太刺眼）
static const expenseLight = Color(0xFFFCA5A5); // Red 300
static const expenseBg = Color(0xFFFEE2E2); // Red 100

// 收入：使用更鲜明的绿色
static const income = Color(0xFF22C55E); // Green 500（当前 #10B981 偏暗）
static const incomeLight = Color(0xFF86EFAC); // Green 300
static const incomeBg = Color(0xFFDCFCE7); // Green 100

// 警告色：更温暖
static const warning = Color(0xFFF59E0B); // Amber 500
static const warningLight = Color(0xFFFDE68A); // Amber 200

// 成功色：清新绿
static const success = Color(0xFF10B981); // Emerald 500
static const successLight = Color(0xFFD1FAE5); // Emerald 100
```

### 中性色优化

#### 深色模式
```dart
// 背景层次更丰富
static const darkBg = Color(0xFF0A0A0B); // 更深的黑色
static const darkBgSecondary = Color(0xFF121214); // 次级背景
static const darkSurface = Color(0xFF1C1C1F); // 表面色
static const darkElevated = Color(0xFF2C2C30); // 抬升色
static const darkCard = Color(0xFF27272A); // 卡片色

// 文字对比度提升
static const darkTextPrimary = Color(0xFFFAFAFA); // 保持
static const darkTextSecondary = Color(0xFFB4B4B8); // 提升对比度（原 #A1A1AA）
static const darkTextTertiary = Color(0xFF85858A); // 提升对比度（原 #71717A）
```

#### 浅色模式
```dart
// 背景更柔和
static const lightBg = Color(0xFFFAFAFA); // 更柔和的灰白（原 #F4F4F5）
static const lightBgSecondary = Color(0xFFF5F5F5); // 次级背景
static const lightSurface = Color(0xFFFFFFFF); // 保持
static const lightElevated = Color(0xFFFAFAFA); // 抬升色
static const lightCard = Color(0xFFFFFFFF); // 卡片色

// 文字对比度优化
static const lightTextPrimary = Color(0xFF18181B); // 提升对比度（原 #09090B）
static const lightTextSecondary = Color(0xFF52525B); // 保持
static const lightTextTertiary = Color(0xFF71717A); // 保持
```

### 渐变色优化

```dart
// 主渐变：更有活力
static const primaryGradient = [
  Color(0xFF059669), // Emerald 600
  Color(0xFF0891B2), // Cyan 600
];

// 卡片渐变：深色模式
static const cardGradientDark = [
  Color(0xFF1C1C1F),
  Color(0xFF0A0A0B),
];

// 卡片渐变：浅色模式
static const cardGradientLight = [
  Color(0xFFFFFFFF),
  Color(0xFFFAFAFA),
];

// 余额卡片渐变（深色）
static const balanceGradientDark = [
  Color(0xFF1E293B), // Slate 800
  Color(0xFF0F172A), // Slate 900
];

// 余额卡片渐变（浅色）
static const balanceGradientLight = [
  Color(0xFF059669), // Emerald 600
  Color(0xFF0891B2), // Cyan 600
];
```

## 色彩应用建议

### 1. 首页余额卡片
- 深色模式：使用深蓝灰渐变 + 微妙的绿色光晕
- 浅色模式：使用绿青渐变 + 白色文字

### 2. 收入/支出指示
- 支出：红色系（#EF4444）
- 收入：绿色系（#22C55E）
- 使用更柔和的背景色提升可读性

### 3. 按钮和交互元素
- 主按钮：使用主色渐变
- 次要按钮：使用中性色 + 边框
- 危险按钮：使用支出色

### 4. 图表和数据可视化
- 使用主色系的多个色阶
- 避免使用过于鲜艳的颜色
- 确保色盲友好

## 可访问性检查

所有文字颜色组合需满足 WCAG 2.1 AA 标准：
- 正常文字：对比度 ≥ 4.5:1
- 大文字（18pt+）：对比度 ≥ 3:1
- UI 组件：对比度 ≥ 3:1
