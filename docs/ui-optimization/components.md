# 组件样式优化建议

## 1. 卡片组件优化

### 当前问题
- 玻璃效果在某些场景下不够清晰
- 阴影效果过于统一，缺乏层次
- 边框颜色对比度不足

### 优化方案

#### 标准卡片样式
```dart
// 浅色模式
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Color(0x14000000), // 提升对比度（原 0x1A）
      width: 1.0,
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0x08000000), // 更柔和的阴影
        blurRadius: 12,
        offset: Offset(0, 2),
      ),
      BoxShadow(
        color: Color(0x04000000), // 双层阴影增加深度
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ],
  ),
)

// 深色模式
Container(
  decoration: BoxDecoration(
    color: Color(0xFF1C1C1F),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Color(0x28FFFFFF), // 提升对比度（原 0x1A）
      width: 0.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0x40000000), // 更明显的阴影
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  ),
)
```

#### 突出卡片样式（余额卡片）
```dart
// 深色模式 - 使用渐变背景
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1E293B), // Slate 800
        Color(0xFF0F172A), // Slate 900
      ],
    ),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Color(0x1AFFFFFF),
      width: 1.0,
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0x60000000),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: Color(0x30000000),
        blurRadius: 48,
        offset: Offset(0, 16),
      ),
    ],
  ),
)

// 浅色模式 - 使用彩色渐变
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF059669), // Emerald 600
        Color(0xFF0891B2), // Cyan 600
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
  ),
)
```

## 2. 按钮组件优化

### 主按钮（Primary Button）
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF059669), // 主色
    foregroundColor: Colors.white,
    minimumSize: Size.fromHeight(48), // 增加高度（原 50）
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12), // 统一圆角
    ),
    // 添加按压效果
    overlayColor: Color(0x20FFFFFF),
  ),
)
```

### 次要按钮（Secondary Button）
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: Color(0xFF059669),
    backgroundColor: Colors.transparent,
    minimumSize: Size.fromHeight(48),
    side: BorderSide(
      color: Color(0xFF059669),
      width: 1.5, // 增加边框宽度
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

### 玻璃按钮（Glass Button）
```dart
Container(
  height: 44,
  decoration: BoxDecoration(
    color: isDark 
      ? Color(0x40FFFFFF) // 提升不透明度
      : Color(0x20000000),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: isDark 
        ? Color(0x40FFFFFF) 
        : Color(0x20000000),
      width: 1.0,
    ),
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Center(child: child),
    ),
  ),
)
```

## 3. 输入框组件优化

### 标准输入框
```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: isDark 
      ? Color(0xFF1C1C1F) 
      : Color(0xFFFAFAFA),
    contentPadding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDark 
          ? Color(0x28FFFFFF) 
          : Color(0x1A000000),
        width: 1.0,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDark 
          ? Color(0x28FFFFFF) 
          : Color(0x1A000000),
        width: 1.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Color(0xFF059669),
        width: 2.0, // 聚焦时加粗边框
      ),
    ),
  ),
)
```

## 4. 筛选标签组件优化

### 当前问题
- 未选中状态不够明显
- 选中状态对比度不足

### 优化方案
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    color: active
      ? Color(0xFF059669).withOpacity(0.15) // 提升不透明度
      : isDark 
        ? Color(0xFF27272A) 
        : Color(0xFFF5F5F5),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: active
        ? Color(0xFF059669)
        : Colors.transparent,
      width: 1.5,
    ),
  ),
  child: Text(
    label,
    style: TextStyle(
      color: active 
        ? Color(0xFF059669) 
        : textSecondary,
      fontSize: 13,
      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
    ),
  ),
)
```

## 5. 列表项组件优化

### 交易列表项
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: isDark ? Color(0xFF1C1C1F) : Colors.white,
    borderRadius: BorderRadius.circular(16), // 统一圆角（原 20）
    border: Border.all(
      color: isDark 
        ? Color(0x14FFFFFF) 
        : Color(0x0A000000),
      width: 1.0,
    ),
    boxShadow: [
      BoxShadow(
        color: isDark 
          ? Color(0x20000000) 
          : Color(0x06000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Row(
    children: [
      // 图标容器
      Container(
        width: 48, // 增加尺寸（原 44）
        height: 48,
        decoration: BoxDecoration(
          color: tone.withOpacity(0.12), // 提升不透明度
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 22, color: tone), // 增加图标尺寸
      ),
      SizedBox(width: 16),
      // 内容...
    ],
  ),
)
```

## 6. 底部弹窗组件优化

### 标准弹窗
```dart
Container(
  decoration: BoxDecoration(
    color: isDark ? Color(0xFF1C1C1F) : Colors.white,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(24), // 统一圆角（原 28）
      topRight: Radius.circular(24),
    ),
    border: Border(
      top: BorderSide(
        color: isDark 
          ? Color(0x28FFFFFF) 
          : Color(0x14000000),
        width: 1.0,
      ),
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0x40000000),
        blurRadius: 32,
        offset: Offset(0, -8),
      ),
    ],
  ),
  child: SafeArea(
    top: false,
    child: Column(
      children: [
        // 拖动指示器
        Container(
          margin: EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: isDark 
              ? Color(0x40FFFFFF) 
              : Color(0x20000000),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // 内容...
      ],
    ),
  ),
)
```

## 7. 图标容器优化

### 分类图标容器
```dart
Container(
  width: 48,
  height: 48,
  decoration: BoxDecoration(
    // 使用渐变背景增加视觉吸引力
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        tone.withOpacity(0.15),
        tone.withOpacity(0.08),
      ],
    ),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: tone.withOpacity(0.2),
      width: 1.0,
    ),
  ),
  child: Icon(icon, size: 22, color: tone),
)
```

## 8. 加载状态优化

### 骨架屏
```dart
// 使用 Shimmer 效果
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment(-1.0, 0.0),
      end: Alignment(1.0, 0.0),
      colors: [
        isDark ? Color(0xFF27272A) : Color(0xFFF5F5F5),
        isDark ? Color(0xFF3F3F46) : Color(0xFFE5E5E5),
        isDark ? Color(0xFF27272A) : Color(0xFFF5F5F5),
      ],
    ),
    borderRadius: BorderRadius.circular(8),
  ),
)
```

### 加载指示器
```dart
CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation<Color>(
    Color(0xFF059669), // 使用主色
  ),
  strokeWidth: 3.0,
)
```

## 9. 空状态优化

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // 插图或图标
    Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Color(0xFF059669).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.receipt_long_outlined,
        size: 48,
        color: Color(0xFF059669).withOpacity(0.5),
      ),
    ),
    SizedBox(height: 24),
    Text(
      '暂无记账记录',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),
    SizedBox(height: 8),
    Text(
      '点击下方按钮开始记账',
      style: TextStyle(
        fontSize: 13,
        color: textSecondary,
      ),
    ),
  ],
)
```

## 10. 动画效果建议

### 页面切换动画
```dart
// 使用淡入淡出 + 轻微缩放
PageRouteBuilder(
  transitionDuration: Duration(milliseconds: 300),
  pageBuilder: (context, animation, secondaryAnimation) => page,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: child,
      ),
    );
  },
)
```

### 列表项动画
```dart
// 使用交错动画
AnimatedList(
  itemBuilder: (context, index, animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 0.1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: FadeTransition(
        opacity: animation,
        child: listItem,
      ),
    );
  },
)
```

### 按钮点击反馈
```dart
// 使用缩放动画
GestureDetector(
  onTapDown: (_) => controller.forward(),
  onTapUp: (_) => controller.reverse(),
  onTapCancel: () => controller.reverse(),
  child: ScaleTransition(
    scale: Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    ),
    child: button,
  ),
)
```
