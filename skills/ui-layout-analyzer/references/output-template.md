# 页面布局分析输出模板

## 1. 输入信息

- 来源：（截图/设计稿/Figma 导出）
- 分析页面：
- 设备假设：
- 已知约束：

## 2. 页面结构

| 区域 | 目标 | 布局类型 | 备注 |
| --- | --- | --- | --- |
| 页头 |  |  |  |
| 主内容 |  |  |  |
| 侧边栏 |  |  |  |
| 页脚 |  |  |  |

## 3. 布局树

```text
Page
  Header
  Main
    Section A
    Section B
  Footer
```

## 4. 组件清单

| 组件名 | 可复用 | 参数/配置 | 状态 | 备注 |
| --- | --- | --- | --- | --- |
| ProductCard | 是 | image, title, price | default/hover/sold-out |  |
| FilterPanel | 是 | filters, selected | collapsed/expanded |  |

### 4.1 组件复用决策表（防重复造轮子）

| 候选组件 | 是否已有 | 已有组件路径 | 决策（复用/新增） | 新增原因（若新增必填） | 备注 |
| --- | --- | --- | --- | --- | --- |
| ProductCard | 是 | `client/lib/features/product/presentation/widgets/product_card.dart` | 复用 |  |  |
| SummaryBadge | 否 |  | 新增 | 现有组件不支持“图标 + 双行文本 + 状态色”组合能力 |  |

## 5. 交互与状态说明

- 导航行为：
- 弹层/模态行为：
- 表单/校验行为：
- 空态/加载态/错误态：

## 6. 响应式与可访问性说明

- 断点假设：
- 键盘与焦点预期：
- 对比度/可读性风险：

## 7. 待确认问题与假设

- 待确认问题：
- 假设：
