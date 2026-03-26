# 首页分析

## 1. 输入信息

| 项目 | 内容 |
| --- | --- |
| 来源 | Pencli 本地设计稿 /Users/liwenya/lxhcool/pen/new.pen |
| 分析页面 | OneKeep 首页（深色 M5Wes）/ OneKeep 首页 - Light（浅色 IY3QK） |
| 目标设备 | 手机端，设计稿画板尺寸 402 x 874 |
| 已知约束 | 当前仓库 UI 代码仅有首页占位实现，尚无可复用业务组件 |
| 假设前提 | 以设计稿可见信息为准；未展示的跳转目标、弹层内容、异步状态和权限流均不做强结论 |

## 2. 页面结构说明

| 区域 | 目标 | 布局类型 | 关键元素 | 备注 |
| --- | --- | --- | --- | --- |
| 系统状态栏 | 展示系统时间与状态 | 单行横向，两端对齐 | 时间、信号、Wi-Fi、电量 | 设计稿为静态展示 |
| 页头 | 展示用户身份并提供全局提醒入口 | 单行横向 | 头像、问候语、用户名、通知按钮 | 深浅版仅视觉风格不同，结构一致 |
| 余额总览卡 | 展示本月结余与趋势 | 单列卡片 | 本月结余标签、金额、环比涨幅、金额显隐图标 | 图标存在，显隐逻辑未展示 |
| 收支摘要区 | 快速查看本月收入与支出 | 双列卡片 | 支出卡、收入卡、箭头图标、金额 | 卡片样式一致，数据语义不同 |
| 最近记账标题区 | 作为交易列表入口 | 单行横向 | 渐变装饰条、标题、查看全部、右箭头 | 典型列表分区标题 |
| 交易列表 | 浏览最近几条记账记录 | 单列列表 | 3 条记录卡片，含图标、标题、分类时间、金额 | 当前仅见午餐、地铁、工资三条示例数据 |
| 底部导航栏 | 主页面切换与快捷记账 | 五槽横向导航，中间悬浮主操作 | 首页、统计、FAB、新增账单、我的 | 首页为选中态；中间为主操作按钮 |
| 页面背景 | 强化主题氛围 | 全屏背景叠加 | 深色版为多层 glow + 暗底，浅色版为浅灰底 + 轻投影 | 属视觉层，不单独承载业务 |

## 3. 功能点清单

| 功能点 | 用户动作 | 页面反馈 | 优先级 | 备注 |
| --- | --- | --- | --- | --- |
| 查看首页摘要 | 打开首页 | 展示余额、收支和最近交易 | P0 | 首页核心任务 |
| 查看本月结余 | 阅读余额卡 | 显示总金额与较上月变化 | P0 | 是否支持金额隐藏未确认 |
| 切换金额显隐 | 点击余额卡右上角眼睛图标 | 预期切换金额明文/掩码 | P1 | 设计稿仅给出图标，无状态稿 |
| 进入通知中心 | 点击通知按钮 | 预期进入消息或提醒页 | P1 | 路由和未读态未展示 |
| 查看本月支出 | 阅读支出摘要卡 | 显示支出金额 | P0 | 可进一步跳转明细是合理推断 |
| 查看本月收入 | 阅读收入摘要卡 | 显示收入金额 | P0 | 可进一步跳转明细是合理推断 |
| 查看最近交易列表 | 下滑或浏览列表 | 看到最近 3 条交易 | P0 | 当前画面未体现分页或加载更多 |
| 查看全部交易 | 点击查看全部 | 预期进入完整账单页 | P1 | 与底部“账单”入口可能目标一致 |
| 查看单条交易详情 | 点击交易卡片 | 预期进入交易详情页 | P1 | 设计稿未展示详情页 |
| 切换到统计页 | 点击底部“统计” | 底部导航切换选中态并进入统计页 | P0 | 统计页设计稿已存在 |
| 快速新增记账 | 点击中间 FAB | 预期打开新增记账流程或弹层 | P0 | 入口很强，但后续流程缺失 |
| 切换到账单页 | 点击底部“账单” | 进入账单页 | P0 | 账单页设计稿已存在 |
| 切换到我的页 | 点击底部“我的” | 进入个人中心 | P1 | 我的页设计稿未见 |

## 4. 布局树

```text
HomePage
  StatusBar
    Time
    SystemIcons
  Header
    AvatarButton
    UserInfo
      Greeting
      Username
    NotificationButton
  BalanceSummaryCard
    BalanceBadge
    VisibilityToggle
    BalanceAmount
    MonthOverMonthChange
  IncomeExpenseRow
    ExpenseSummaryCard
      ExpenseIcon
      ExpenseLabel
      ExpenseAmount
    IncomeSummaryCard
      IncomeIcon
      IncomeLabel
      IncomeAmount
  RecentTransactionSection
    SectionHeader
      AccentBar
      Title
      ViewAllAction
    TransactionList
      TransactionItemCard
      TransactionItemCard
      TransactionItemCard
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
| HomePageContainer | 页面 | 整页 | themeMode, user, summary, recentTransactions, currentTab | 默认 | 深浅版建议共用结构，不同 token 换肤 |
| SystemStatusBar | 共享 | 顶部 | timeText, iconColor | 默认 | 业务价值低，可按系统容器处理 |
| HomeHeader | 共享 | 页头 | greeting, username, avatarIcon, hasNotificationBadge | 默认、未读 | 设计稿未给未读红点 |
| RoundIconButton | 共享 | 页头/卡片 | icon, size, background, border, onTap | 默认、按下、禁用 | 可承载通知按钮和金额显隐按钮 |
| BalanceSummaryCard | 页面内共享 | 余额区 | title, amount, deltaText, amountVisible | 默认、金额隐藏、加载 | 首页核心卡片 |
| SummaryBadge | 共享 | 余额区 | text, tone | 默认 | 深浅版仅颜色不同 |
| FinanceMetricCard | 共享 | 收支区 | type, icon, label, amount, tone | 默认、按下、加载 | 收入/支出为同构组件 |
| SectionHeaderAction | 共享 | 最近记账标题区 | title, accentStyle, actionText | 默认、按下 | 适用于列表分区标题 |
| TransactionList | 页面内共享 | 交易区 | items, isLoading, isEmpty | 默认、加载、空、错误 | 当前稿件仅展示默认态 |
| TransactionItemCard | 共享 | 交易区 | icon, title, category, time, amount, direction | 默认、按下 | 收支靠 amount 正负色区分 |
| HomeBottomNavBar | 共享 | 底部导航 | currentTab, onTabChange, onPrimaryAction | 默认、选中、按下 | 中间 FAB 与普通 Tab 不同 |
| PrimaryActionFab | 共享 | 底部导航 | icon, onTap | 默认、按下、禁用 | 预期打开新增记账流程 |

## 6. 组件匹配检查表

| 候选组件 | 是否已有可匹配组件 | 匹配组件路径 | 匹配结论（可匹配/需开发） | 处理方式 | 需开发原因 | 备注 |
| --- | --- | --- | --- | --- | --- | --- |
| HomePageContainer | 否 | 无 | 需开发 | 新开发 | 当前只有首页占位页，没有真实首页结构 | 当前实现见 client/lib/app.dart |
| HomeHeader | 否 | 无 | 需开发 | 新开发 | 无头像、问候、通知入口组件 | 需支持深浅主题 |
| RoundIconButton | 否 | 无 | 需开发 | 新开发 | 项目尚未抽出通用图标按钮组件 | 可后续沉淀为共享基础组件 |
| BalanceSummaryCard | 否 | 无 | 需开发 | 新开发 | 无金额卡片、显隐状态、趋势文案承载组件 | 首页核心模块 |
| FinanceMetricCard | 否 | 无 | 需开发 | 新开发 | 收入/支出双卡需要统一抽象 | 适合复用到统计页 |
| SectionHeaderAction | 否 | 无 | 需开发 | 新开发 | 无分区标题组件 | 可服务多列表页面 |
| TransactionList | 否 | 无 | 需开发 | 新开发 | 无列表容器、空态/错误态约定 | 需定义数据模型 |
| TransactionItemCard | 否 | 无 | 需开发 | 新开发 | 无可复用交易项卡片 | 账单页也可共用 |
| HomeBottomNavBar | 否 | 无 | 需开发 | 新开发 | 当前项目未实现底部导航体系 | 需和全局路由共同设计 |
| PrimaryActionFab | 否 | 无 | 需开发 | 新开发 | 中间主操作与普通 Tab 不同 | 需确认点击后流程 |

检查结论：当前仓库中未发现可直接复用的业务 UI 组件。现有代码仅包含一个占位首页，无法构成“可匹配”结论。

## 7. 深浅版差异对照

| 对比项 | 深色首页 | 浅色首页 | 结论 |
| --- | --- | --- | --- |
| 页面底色 | #0A0A0A 暗底，带多层彩色 glow | #F7F7F8 浅灰底 | 仅主题差异，不改信息架构 |
| 主强调色 | 青绿 #00CEC9 + 紫色辅助 | 靛蓝 #4F46E5 + 紫色辅助 | 主题 token 可切换 |
| 余额卡样式 | 半透明玻璃卡 + 背景模糊 | 白色实体卡 + 轻阴影 | 同构组件，不同 surface token |
| 摘要卡样式 | 暗色半透明卡 | 白色实体卡 | 同构组件 |
| 文本色 | 白色/半透明白 | 深灰/中灰 | 主题 token 差异 |
| 导航选中态 | 青绿高亮 | 靛蓝高亮 | 当前 tab 逻辑一致 |
| FAB 渐变 | 青绿到紫 | 靛蓝到紫 | 同一交互，不同主题色 |

## 8. 交互与状态表

| 场景 | 触发条件 | 页面反馈 | 依赖组件 | 备注 |
| --- | --- | --- | --- | --- |
| 主流程：进入首页 | App 启动或切到首页 Tab | 渲染头部、余额卡、收支卡、交易列表、底部导航 | HomePageContainer, HomeBottomNavBar | P0 主入口 |
| 主流程：查看余额趋势 | 页面加载完成 | 显示余额金额与“较上月 +8.2%” | BalanceSummaryCard | 趋势为静态文案，涨跌规则未展示 |
| 主流程：查看最近交易 | 页面加载完成 | 显示最近 3 条交易摘要 | TransactionList, TransactionItemCard | 当前为默认态 |
| 分支流程：查看全部 | 点击“查看全部” | 预期跳到账单列表页 | SectionHeaderAction | 目标页可能为 Bills |
| 分支流程：查看通知 | 点击通知按钮 | 预期进入通知页或消息中心 | HomeHeader | 无未读角标状态稿 |
| 分支流程：新增记账 | 点击中间 FAB | 预期弹出新增记账面板或进入录入页 | PrimaryActionFab | 关键流程，但设计稿缺失 |
| 分支流程：切换 Tab | 点击统计/账单/我的 | 导航选中态切换并跳转页面 | HomeBottomNavBar | 统计页、账单页有稿；我的页无稿 |
| 异常流程：余额或列表接口失败 | 数据请求失败 | 预期展示重试、错误提示或骨架替代 | BalanceSummaryCard, TransactionList | 设计稿未展示 |
| 状态说明：默认 | 页面正常展示数据 | 可见所有卡片和列表 | 全部组件 | 设计稿已覆盖 |
| 状态说明：加载 | 首次进入或刷新 | 预期展示骨架屏或占位卡片 | BalanceSummaryCard, TransactionList | 设计稿未覆盖 |
| 状态说明：空 | 无最近交易 | 预期展示空状态插画/文案/CTA | TransactionList | 设计稿未覆盖 |
| 状态说明：错误 | 接口异常 | 预期展示错误提示与重试 | TransactionList, BalanceSummaryCard | 设计稿未覆盖 |
| 状态说明：选中/按下 | 点击 Tab、按钮、卡片 | 颜色加深、阴影或透明度变化 | HomeBottomNavBar, RoundIconButton, TransactionItemCard | 视觉反馈稿未覆盖 |
| 状态说明：金额隐藏 | 点击眼睛图标 | 预期金额替换为掩码 | BalanceSummaryCard | 设计稿未覆盖第二状态 |

## 9. 响应式与可访问性说明

- 断点假设：当前稿件仅覆盖手机单列布局，未提供平板或桌面适配方案。
- 键盘与焦点预期：通知按钮、眼睛按钮、查看全部、交易项、底部导航和 FAB 均应可聚焦并有明确焦点样式。
- 可读性与对比度风险：深色版次级信息使用半透明白，若实际设备亮度较低，交易元信息和次要按钮文案可能对比不足；浅色版整体对比安全，但 10px 导航标签偏小。
- 可访问性建议：金额与涨跌应提供语义化朗读；颜色不应作为收支唯一识别手段，需辅以正负号和文案；底部 FAB 需设置明确的辅助功能名称，如“新增记账”。

## 10. 待确认问题与假设表

| 类型 | 内容 | 影响范围 | 处理建议 |
| --- | --- | --- | --- |
| 待确认问题 | 点击余额卡眼睛图标后，金额是全局隐藏还是仅首页隐藏 | BalanceSummaryCard、全局设置 | 明确产品规则和持久化策略 |
| 待确认问题 | 通知按钮进入通知中心、待办提醒还是系统消息 | HomeHeader、路由设计 | 明确目标页面和未读态规则 |
| 待确认问题 | 点击收入/支出摘要卡是否进入筛选后的账单明细 | FinanceMetricCard、账单页联动 | 明确点击行为与筛选参数 |
| 待确认问题 | 点击单条交易是否进入编辑页、详情页还是底部弹层 | TransactionItemCard | 明确详情交互和返回路径 |
| 待确认问题 | 中间 FAB 打开的是快速记账弹层、完整表单页还是多操作菜单 | PrimaryActionFab、录入流程 | 需要补后续流程稿 |
| 待确认问题 | “查看全部”和底部“账单”是否进入同一页面及相同筛选状态 | 导航、列表跳转 | 明确入口归因与默认筛选 |
| 待确认问题 | 首页是否支持下拉刷新、自动刷新或切后台回前台刷新 | HomePageContainer、数据层 | 影响状态管理与动画设计 |
| 待确认问题 | 我的页是否存在，若存在是否也属于本次导航主框架 | 全局信息架构 | 需要补稿 |
| 假设 | 深浅版共用同一信息结构与交互，仅替换主题 token | 全部首页组件 | 开发上按一套组件双主题处理 |
| 假设 | 最近交易当前只展示最近 3 条，完整数据需进入账单页查看 | TransactionList、Bills 页面 | 与“查看全部”行为一致化 |
| 假设 | 交易列表支持按收支类型着色，但文案和正负号仍保留 | TransactionItemCard | 满足可读性和无障碍 |
| 假设 | 首页数据来自统一聚合接口，包含用户信息、余额摘要和 recent transactions | 页面数据模型 | 便于减少多接口拼装复杂度 |

## 11. 缺失项说明

以下页面细节无法仅凭当前设计稿完整判断，需要补充交互稿、流程稿或说明文档：

1. 余额显隐切换后的视觉状态与作用域。
2. 通知中心、交易详情、新增记账、我的页的目标页面与交互路径。
3. 列表加载、空态、错误态、下拉刷新、分页加载更多的表现方式。
4. 交易项长按、左滑删除、编辑等高频账本操作是否存在。
5. FAB 是否触发底部弹层、多操作菜单或直接跳转表单页。
6. 深浅主题切换的入口位置、切换规则及是否跟随系统。
7. 动效规范，包括卡片点击、页面切换、列表刷新和 FAB 呼出动效。
