# 设计理念与风格定位

## 整体风格定位

### 当前风格分析
OneKeep 目前采用的是 **现代极简玻璃态（Glassmorphism）** 风格：
- 毛玻璃效果（BackdropFilter）
- 半透明卡片
- 柔和的阴影
- 简洁的图标

### 优化后的风格方向

**推荐：现代优雅 + 轻奢感**

核心特征：
1. **克制的玻璃效果**：减少过度使用，只在关键位置使用
2. **清晰的层次感**：通过阴影和边框建立明确的视觉层级
3. **温暖的色彩**：使用更有亲和力的配色
4. **流畅的动画**：添加微妙的过渡效果
5. **精致的细节**：注重圆角、间距、对齐等细节

---

## 深色模式 vs 浅色模式

### 设计原则

#### 深色模式（Dark Mode）
**目标**：舒适、专业、不刺眼

**特点**：
- 真黑背景（#0A0A0B）提供 OLED 省电效果
- 多层次的灰色系统（#0A0A0B → #1C1C1F → #27272A）
- 更明显的边框和阴影
- 柔和的色彩饱和度

#### 浅色模式（Light Mode）
**目标**：清爽、明亮、易读

**特点**：
- 柔和的灰白背景（#FAFAFA）避免纯白刺眼
- 清晰的卡片边界
- 更柔和的阴影
- 更高的色彩饱和度

### 具体对比

```
组件          深色模式                    浅色模式
─────────────────────────────────────────────────────
背景          #0A0A0B (真黑)             #FAFAFA (柔和灰白)
卡片          #1C1C1F (深灰)             #FFFFFF (纯白)
边框          rgba(255,255,255,0.16)    rgba(0,0,0,0.08)
文字主色      #FAFAFA (亮白)             #18181B (深灰)
文字次色      #B4B4B8 (中灰)             #52525B (灰)
阴影          rgba(0,0,0,0.4)           rgba(0,0,0,0.06)
```

### 余额卡片的模式差异

#### 深色模式
```dart
// 使用深色渐变 + 微妙光晕
decoration: BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B), // Slate 800 - 深蓝灰
      Color(0xFF0F172A), // Slate 900 - 更深
    ],
  ),
  borderRadius: BorderRadius.circular(24),
  border: Border.all(
    color: Color(0x1AFFFFFF), // 微妙的白色边框
    width: 1.0,
  ),
  boxShadow: [
    BoxShadow(
      color: Color(0x60000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ],
)
```

**视觉效果**：
- 深邃、专业、高级感
- 白色文字清晰可读
- 微妙的光晕增加层次

#### 浅色模式
```dart
// 使用彩色渐变
decoration: BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF059669), // Emerald 600 - 祖母绿
      Color(0xFF0891B2), // Cyan 600 - 青色
    ],
  ),
  borderRadius: BorderRadius.circular(24),
  boxShadow: [
    BoxShadow(
      color: Color(0x30059669), // 带色彩的阴影
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ],
)
```

**视觉效果**：
- 活力、清新、吸引眼球
- 白色文字在渐变上清晰
- 彩色阴影增加品牌感

---

## 布局设计理念

### 1. 呼吸感（Breathing Space）

**问题**：当前布局信息密集，缺乏留白

**解决方案**：
- 增加组件间距（14px → 16px/20px）
- 减少卡片内边距（28px → 24px）
- 统一使用 8pt 网格系统

**效果**：
- 视觉更舒适
- 信息层次更清晰
- 减少视觉疲劳

### 2. 视觉层次（Visual Hierarchy）

**三层结构**：

```
第一层：页面背景
├─ 深色模式：#0A0A0B
└─ 浅色模式：#FAFAFA

第二层：卡片/容器
├─ 深色模式：#1C1C1F + 边框 + 阴影
└─ 浅色模式：#FFFFFF + 边框 + 阴影

第三层：内容元素
├─ 图标容器：带色彩的背景
├─ 按钮：主色或中性色
└─ 文字：三级层次（primary/secondary/tertiary）
```

### 3. 对齐与网格（Alignment & Grid）

**8pt 网格系统**：
- 所有尺寸都是 8 的倍数
- 间距：8, 12, 16, 24, 32, 40, 48
- 圆角：8, 12, 16, 20, 24, 28

**对齐规则**：
- 页面左右边距：20px
- 卡片内边距：20px 或 24px
- 列表项内边距：16px
- 文字行高：1.4-1.6

### 4. 触摸目标（Touch Targets）

**最小尺寸**：44x44pt（iOS/Android 标准）

**应用**：
- 按钮最小高度：44px
- 图标按钮：44x44px
- 列表项最小高度：72px
- 筛选标签最小高度：32px（带足够的 padding）

---

## 页面布局详解

### 首页布局优化

#### 当前问题
1. 余额卡片占据过多空间
2. 收入/支出卡片间距过小
3. 列表项间距不统一

#### 优化方案

**顶部区域**（头像 + 问候）
```
高度：64px
间距：top 16px, bottom 20px
布局：[头像 48px] [间距 14px] [文字] [弹性空间] [通知按钮 42px]
```

**余额卡片**
```
高度：约 140px（减少 20px）
内边距：24px（减少 4px）
圆角：24px（减少 4px）
间距：bottom 20px
```

**收入/支出卡片**
```
高度：约 110px
间距：中间 16px（增加 2px）
间距：bottom 24px
```

**最近记账区域**
```
标题高度：24px
标题间距：bottom 16px
列表项间距：12px
列表项高度：72px
```

### 账单页布局优化

#### 顶部区域
```
标题 + 搜索：高度 44px
间距：top 16px, bottom 16px
筛选标签：高度 32px, 间距 12px
间距：bottom 20px
```

#### 日期分组
```
日期标题：高度 20px
间距：top 24px（分组间）, bottom 12px
列表项间距：12px
```

### 统计页布局优化

#### 顶部区域
```
标题 + 月份选择：高度 44px
间距：top 16px, bottom 20px
```

#### 汇总卡片
```
高度：约 100px
间距：中间 16px, bottom 20px
```

#### 图表卡片
```
图表高度：180px（增加 20px）
卡片内边距：20px
间距：bottom 20px
```

---

## 响应式设计

### 小屏幕（< 375px）
```dart
// 调整间距
pagePadding: 16px  // 原 20px
cardPadding: 16px  // 原 20px

// 调整字体
titleSize: 22px    // 原 24px
bodySize: 13px     // 原 14px
```

### 标准屏幕（375px - 428px）
```dart
// 使用标准值
pagePadding: 20px
cardPadding: 20px
```

### 大屏幕（> 428px）
```dart
// 限制最大宽度
maxContentWidth: 480px
// 居中显示
alignment: Alignment.center
```

### 平板（> 768px）
```dart
// 两栏布局
columns: 2
maxContentWidth: 720px
cardPadding: 24px
```

---

## 动画与过渡

### 页面切换
```dart
duration: 300ms
curve: Curves.easeOutCubic
effect: FadeTransition + ScaleTransition(0.95 → 1.0)
```

### 列表加载
```dart
duration: 200ms
curve: Curves.easeOut
effect: SlideTransition(0.1 → 0) + FadeTransition
stagger: 50ms（交错动画）
```

### 按钮反馈
```dart
duration: 150ms
curve: Curves.easeInOut
effect: ScaleTransition(1.0 → 0.95)
```

### 卡片展开
```dart
duration: 250ms
curve: Curves.easeOutCubic
effect: SizeTransition + FadeTransition
```

---

## 可访问性考虑

### 颜色对比度
- 所有文字符合 WCAG 2.1 AA 标准
- 正常文字：≥ 4.5:1
- 大文字：≥ 3:1

### 触摸目标
- 最小尺寸：44x44pt
- 间距充足，避免误触

### 动画
- 提供关闭选项
- 尊重系统的减少动画设置

### 字体大小
- 支持系统字体缩放
- 最小字体：12px
