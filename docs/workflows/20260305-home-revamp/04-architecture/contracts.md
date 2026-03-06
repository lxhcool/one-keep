# 契约定义

## API 契约

1. 获取首页快照
- `GET /api/home/snapshot?month=YYYY-MM`
- 响应示例：
```json
{
  "month": "2025-07",
  "summary": { "income": 3000.00, "expense": 1816.48 },
  "dayGroups": [
    {
      "date": "2025-07-26",
      "dayExpense": 26.9,
      "items": [
        { "id": "tx_1", "category": "午饭", "type": "expense", "amount": 12.9 }
      ]
    }
  ]
}
```

2. 分步获取（用于先统计后列表）
- `GET /api/home/summary?month=YYYY-MM`
- `GET /api/home/day-groups?month=YYYY-MM`

3. 获取流水详情
- `GET /api/transactions/{id}`

4. 新增流水
- `POST /api/transactions`
- 请求关键字段：`type`, `amount`, `categoryId`, `occurredAt`
- 规则：`type=income` 按正数处理，`type=expense` 按负向展示语义处理。

5. 错误约定
- 通用错误体：`{ "code": "...", "message": "...", "retryable": true|false }`
- 首页查询失败默认可重试；前端节流 1 秒。

## 事件契约

- `transaction.created`
  - 触发时机：新增流水成功后。
  - 关键字段：`transactionId`, `occurredAt`, `month`。
  - 消费方：首页缓存刷新器/统计聚合器。

- `home.snapshot.refreshed`（可选）
  - 触发时机：某月首页快照重算完成后。
  - 用途：前端轮询或推送更新的扩展点。

## 版本策略说明

- 版本前缀：`/api/v1/...`（落地时统一加版本前缀）。
- 字段新增遵循向后兼容；字段删除需至少跨一个小版本并提前公告。
- “中间记账说明位不可点击”属于前端交互契约，不通过服务端字段切换。
