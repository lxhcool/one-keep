# 页面与架构映射

| 页面 | 限界上下文 | 服务端模块 | API/契约 | 后台模块 |
| --- | --- | --- | --- | --- |
| home | Home Ledger Context | `ledger-home-service` | `GET /api/home/snapshot?month=YYYY-MM` | 分类图标配置、空态素材配置 |
| home（月份切换） | Home Ledger Context | `ledger-home-service` | `GET /api/home/summary?month=YYYY-MM` + `GET /api/home/day-groups?month=YYYY-MM` | 月份文案配置（可选） |
| home（点击流水） | Home Ledger Context | `ledger-transaction-service` | `GET /api/transactions/{id}` | 分类展示配置 |
| home（点击+） | Transaction Entry Context | `ledger-transaction-service` | `POST /api/transactions` | 分类/账户配置 |
| app-shell（底部导航） | Navigation Shell Context | `navigation-gateway`（可选） | 路由契约（前端） | 导航文案配置 |
