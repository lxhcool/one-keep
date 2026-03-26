# 统计页分析

## 1. 输入信息

| 项目 | 内容 |
| --- | --- |
| 来源 | Pencli 本地设计稿 /Users/liwenya/lxhcool/pen/new.pen |
| 分析页面 | OneKeep 统计 - Dark（62VWg）/ Stats Light（7yTdl）；交互状态帧：月份选择器（cAnat）、收入 Tab（Rzpio） |
| 目标设备 | 手机端，设计稿画板尺寸 402 x 874 |
| 已知约束 | 当前仓库只有首页占位实现，尚无统计页和相关图表组件 |
| 假设前提 | 以设计稿可见结构和文本为准；未展示的数据来源、切换逻辑、钻取流程仅记录为推断或待确认事项 |

## 2. 页面结构说明

| 区域 | 目标 | 布局类型 | 关键元素 | 备注 |
| --- | --- | --- | --- | --- |
| 系统状态栏 | 展示系统状态 | 单行横向，两端对齐 | 时间、信号、Wi-Fi、电量 | 静态展示 |
| 页面头部 | 标识统计页并提供月份筛选 | 单行横向 | 标题“统计”、月份选择器“2026年3月” | 月份选择器带下拉提示 |
| 汇总卡片区 | 快速展示收入支出总览 | 双列卡片 | 总支出 ¥6,420.00、总收入 ¥19,000.00 | 深浅版视觉不同，信息结构一致 |
| 趋势图卡片 | 展示按星期维度的趋势数据 | 卡片内纵向结构 | 标题“支出趋势”、支出/收入切换、周一到周日柱状图 | 当前稿件只展示支出为选中态 |
| 分类排行卡片 | 展示主要消费分类和金额占比 | 卡片内纵向列表 | 分类排行标题、查看全部、3 条分类条目、进度条 | 当前仅展示 Top3 |
| 底部导航栏 | 页面切换与快捷记账 | 五槽导航，中间 FAB | 首页、统计、FAB、账单、我的 | 统计为当前选中态 |
| 页面背景 | 维持主题风格 | 全屏背景层 | 深色为暗底 + glow，浅色为浅底 + 实体白卡 | 视觉层 |

## 3. 功能点清单

| 功能点 | 用户动作 | 页面反馈 | 优先级 | 备注 |
| --- | --- | --- | --- | --- |
| 查看月度统计总览 | 打开统计页 | 展示当月支出、收入、趋势和分类排行 | P0 | 统计页主任务 |
| 切换统计月份 | 点击月份选择器 | 弹出底部月份选择弹层（4×3 网格、年份切换、当前月份高亮选中） | P0 | 设计稿已补充月份选择器帧 cAnat |
| 查看总支出 | 阅读总支出卡片 | 显示当月支出总额 | P0 | 是否可点击钻取未确认 |
| 查看总收入 | 阅读总收入卡片 | 显示当月收入总额 | P0 | 是否可点击钻取未确认 |
| 切换趋势指标 | 点击"支出/收入"切换 | 柱状图渐变色从粉紫切换为青绿、分类排行刷新为收入类目（工资薪资/兼职收入/投资理财） | P0 | 设计稿已补充收入 Tab 帧 Rzpio |
| 浏览周趋势 | 阅读柱状图 | 识别周一到周日的波动 | P1 | 未见 tooltip 或详情浮层 |
| 查看分类排行 | 浏览分类列表 | 展示餐饮美食、交通出行、购物消费及金额 | P0 | 当前为支出分类排行的合理推断 |
| 查看全部分类 | 点击“查看全部” | 预期进入更完整分类统计页面 | P1 | 目标页未展示 |
| 切换至其他主 Tab | 点击底部导航 | 页面跳转并切换选中态 | P0 | 首页、账单设计稿可见，我的页未见 |
| 快速新增记账 | 点击中间 FAB | 预期打开记账流程 | P0 | 后续流程缺失 |

## 4. 布局树

```text
StatsPage
  StatusBar
  PageHeader
    Title
    MonthPicker
  SummaryRow
    TotalExpenseCard
    TotalIncomeCard
  TrendChartCard
    CardHeader
      Title
      MetricToggle
    WeeklyBarChart
      DayBar x 7
  CategoryRankingCard
    CardHeader
      Title
      ViewAllAction
    CategoryRankItem x 3
  BottomTabBar
    HomeTab
    StatsTab
    AddRecordFab
    BillsTab
    ProfileTab
```

## 5. 组件清单

| 组件名 | 类型（页面/共享） | 所在区域 | 参数/配置 | 状态 | 备注 |
| --- | --- | --- | --- | --- | --- |
| StatsPageContainer | 页面 | 整页 | month, totals, activeMetric, weeklySeries, categoryRanks, currentTab | 默认 | 深浅版建议同构换肤 |
| MonthPickerButton | 共享 | 页头 | monthLabel, onTap | 默认、展开、禁用 | 需要接筛选弹层或日期选择器 |
| FinanceOverviewCard | 共享 | 汇总区 | label, amount, tone | 默认、加载 | 与首页摘要卡风格接近但更简化 |
| MetricSegmentToggle | 共享 | 趋势图卡片 | options, selectedKey, onChange | 默认、选中、按下、禁用 | 当前仅展示“支出”选中 |
| WeeklyBarChartCard | 页面内共享 | 趋势图卡片 | title, metric, bars, labels | 默认、加载、空、错误 | 当前稿件没有 tooltip 或坐标轴 |
| WeeklyBarItem | 共享 | 柱状图 | label, value, color | 默认、选中悬浮 | 若移动端不做悬浮，可保留点击态 |
| CategoryRankingCard | 页面内共享 | 分类排行区 | title, items, moreAction | 默认、加载、空 | 适合未来拓展更多分类 |
| CategoryRankItem | 共享 | 分类排行区 | icon, title, amount, progress, tone | 默认、按下 | 视觉包含 icon + 金额 + 进度条 |
| AppBottomNavBar | 共享 | 底部导航 | currentTab, onTabChange, onPrimaryAction | 默认、选中、按下 | 与首页、账单页共用 |
| PrimaryActionFab | 共享 | 底部导航 | icon, onTap | 默认、按下、禁用 | 统一主操作入口 |

## 6. 组件匹配检查表

| 候选组件 | 是否已有可匹配组件 | 匹配组件路径 | 匹配结论（可匹配/需开发） | 处理方式 | 需开发原因 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| StatsPageContainer | 否 | 无 | 需开发 | 新开发 | 当前项目没有统计页容器和对应路由 | 现有占位实现仅见首页 |
| MonthPickerButton | 否 | 无 | 需开发 | 新开发 | 项目内无月份筛选基础组件 | 需确认选择器形式 |
| FinanceOverviewCard | 否 | 无 | 需开发 | 新开发 | 虽与首页摘要类似，但仓库内并未实现 | 可与首页共建通用摘要卡 |
| MetricSegmentToggle | 否 | 无 | 需开发 | 新开发 | 项目内无分段切换组件 | 需支持主题 token |
| WeeklyBarChartCard | 否 | 无 | 需开发 | 新开发 | 无图表容器和数据映射组件 | 需确认是否引入图表库 |
| WeeklyBarItem | 否 | 无 | 需开发 | 新开发 | 当前没有可复用柱状图条目 | 简单图形可自绘 |
| CategoryRankingCard | 否 | 无 | 需开发 | 新开发 | 无分类排行卡片 | 适合统计页独立模块 |
| CategoryRankItem | 否 | 无 | 需开发 | 新开发 | 无“分类 + 金额 + 进度”组合组件 | 与账单项不属于同构 |
| AppBottomNavBar | 否 | 无 | 需开发 | 新开发 | 底部导航体系尚不存在 | 需全局路由配合 |
| PrimaryActionFab | 否 | 无 | 需开发 | 新开发 | 中间主操作未落地 | 可与首页、账单共用 |

检查结论：当前仓库未发现统计页相关可复用组件，全部为需开发项。

## 7. 深浅版差异对照

| 对比项 | 深色统计页 | 浅色统计页 | 结论 |
| --- | --- | --- | --- |
| 页面底色 | 暗底 + 青绿紫 glow | 浅灰背景 | 同结构不同主题 |
| 月份选择器 | 半透明深色胶囊 | 白色实体胶囊 | 主题 token 差异 |
| 汇总卡片 | 半透明玻璃感 | 白色实体卡 | 同构组件 |
| 趋势图切换选中态 | 青绿高亮 | 靛蓝高亮 | 仅品牌色差异 |
| 柱状图配色 | 青绿到紫渐变 | 靛蓝到紫渐变 | 数据结构一致 |
| 分类排行强调色 | 粉、紫、青绿 | 红、紫、靛蓝 | 颜色映射策略需统一 |
| 底部导航选中态 | 统计为青绿 | 统计为靛蓝 | 当前选中逻辑一致 |

## 8. 交互与状态表

| 场景 | 触发条件 | 页面反馈 | 依赖组件 | 备注 |
| --- | --- | --- | --- | --- |
| 主流程：进入统计页 | 点击底部“统计”或默认进入 | 展示当月总览、趋势图、分类排行 | StatsPageContainer, AppBottomNavBar | P0 |
| 主流程：切换月份 | 点击月份选择器 | 预期弹出月份选择器并刷新所有统计数据 | MonthPickerButton, StatsPageContainer | 当前缺少展开态稿 |
| 主流程：切换支出/收入趋势 | 点击切换项 | 图表和配色随指标变化 | MetricSegmentToggle, WeeklyBarChartCard | 当前仅展示支出选中态 |
| 分支流程：查看分类详情 | 点击“查看全部” | 预期进入完整分类统计页 | CategoryRankingCard | 目标页未见 |
| 分支流程：点击总收入/总支出 | 点击汇总卡片 | 预期进入按类型过滤的明细或图表页 | FinanceOverviewCard | 行为未确认 |
| 分支流程：新增记账 | 点击 FAB | 预期打开新增记账流程 | PrimaryActionFab | 后续流程未展示 |
| 异常流程：统计接口失败 | 拉取数据失败 | 预期展示错误提示和重试 | StatsPageContainer, WeeklyBarChartCard, CategoryRankingCard | 设计稿未覆盖 |
| 状态说明：默认 | 页面成功获取数据 | 展示卡片、柱状图、排行 | 全部组件 | 设计稿已覆盖 |
| 状态说明：加载 | 首次加载或切月刷新 | 预期展示骨架卡片和图表占位 | FinanceOverviewCard, WeeklyBarChartCard, CategoryRankingCard | 设计稿未覆盖 |
| 状态说明：空 | 某月没有数据 | 预期展示“暂无统计数据”空态 | WeeklyBarChartCard, CategoryRankingCard | 设计稿未覆盖 |
| 状态说明：错误 | 接口异常 | 预期错误提示、重试按钮 | StatsPageContainer | 设计稿未覆盖 |
| 状态说明：选中/按下 | 切换标签、月份、底部导航 | 颜色、底色、阴影变化 | MetricSegmentToggle, MonthPickerButton, AppBottomNavBar | 仅默认态可见 |

## 9. 响应式与可访问性说明

- 断点假设：当前仅覆盖手机单列，不包含平板横向扩展布局。
- 键盘与焦点预期：月份选择器、支出/收入切换、查看全部、底部导航、FAB 均应可聚焦并有焦点态。
- 可读性与对比度风险：深色页中非选中态切换项、日期标签与次级金额颜色偏暗，低亮度设备上可能偏弱。
- 可访问性建议：柱状图不能仅依赖高度和颜色表达，需提供可读文本或语义描述；分类排行金额和占比应可被屏幕阅读器完整朗读。

## 10. 待确认问题与假设表

| 类型 | 内容 | 影响范围 | 处理建议 |
| --- | --- | --- | --- |
| 待确认问题 | 月份选择器是底部弹层、日期滚轮还是独立页面 | MonthPickerButton、筛选体验 | 明确交互形式 |
| 待确认问题 | “支出/收入”切换是否只换图表，还是同时影响下方分类排行 | WeeklyBarChartCard、CategoryRankingCard | 明确联动规则 |
| 待确认问题 | 分类排行中的进度条基准是最大项、总额占比还是预算占比 | CategoryRankItem | 关系到数据计算逻辑 |
| 待确认问题 | 点击柱状图某一天是否可钻取到日明细 | WeeklyBarChartCard | 若支持需补交互稿 |
| 待确认问题 | 查看全部是进入分类详情页、报表页还是完整统计页 | CategoryRankingCard | 需明确信息架构 |
| 待确认问题 | 汇总卡片是否可点击进入按收入/支出过滤后的账单页 | FinanceOverviewCard | 影响组件交互定义 |
| 假设 | 当前分类排行展示的是支出 Top3 分类 | CategoryRankingCard | 因趋势切换默认为“支出” |
| 假设 | 深浅版采用统一业务组件，只替换颜色、边框、阴影等主题 token | 全部统计组件 | 适合 Flutter 主题化实现 |
| 假设 | 柱状图数据按周一到周日展示当前月某一周或平均趋势，而非全月每日明细 | WeeklyBarChartCard | 需要产品确认统计口径 |

## 11. 缺失项说明

以下内容无法仅凭当前设计稿完整判断，需要额外补充：

1. 月份选择器展开后的交互形式与可选范围。
2. 支出/收入切换后的另一套图表和排行视觉状态。
3. 柱状图是否支持点击、tooltip、长按或横向滑动查看更多周期。
4. 分类排行“查看全部”的目标页面与层级关系。
5. 统计接口的加载、空态、错误态和刷新逻辑。
6. 趋势数值、单位、统计口径和时间范围定义。

