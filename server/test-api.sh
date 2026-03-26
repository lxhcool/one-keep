#!/bin/bash
# 本地 API 测试脚本
BASE="http://localhost:3000"

echo "=== 1. 登录 ==="
LOGIN=$(curl -s -X POST "$BASE/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"123456"}')
TOKEN=$(echo "$LOGIN" | python3 -c "import sys,json; data=sys.stdin.read(); start=data.rfind('{\"token\"'); print(json.loads(data[start:])['token'])" 2>/dev/null)
echo "TOKEN=${TOKEN:0:20}..."

AUTH="Authorization: Bearer $TOKEN"

echo ""
echo "=== 2. 新增交易: 午餐 ¥38 ==="
curl -s -X POST "$BASE/api/transactions" \
  -H "Content-Type: application/json" -H "$AUTH" \
  -d "{\"title\":\"午餐\",\"amount\":38,\"direction\":\"expense\",\"categoryId\":\"expense_1\",\"occurredAt\":\"2026-03-26T12:00:00Z\"}"
echo ""

echo ""
echo "=== 3. 新增交易: 地铁 ¥6 ==="
curl -s -X POST "$BASE/api/transactions" \
  -H "Content-Type: application/json" -H "$AUTH" \
  -d "{\"title\":\"地铁通勤\",\"amount\":6,\"direction\":\"expense\",\"categoryId\":\"expense_2\",\"occurredAt\":\"2026-03-26T08:00:00Z\"}"
echo ""

echo ""
echo "=== 4. 新增交易: 工资 ¥15000 ==="
curl -s -X POST "$BASE/api/transactions" \
  -H "Content-Type: application/json" -H "$AUTH" \
  -d "{\"title\":\"3月工资\",\"amount\":15000,\"direction\":\"income\",\"categoryId\":\"income_1\",\"occurredAt\":\"2026-03-25T10:00:00Z\"}"
echo ""

echo ""
echo "=== 5. 首页聚合 ==="
curl -s "$BASE/api/home/summary?month=2026-03" -H "$AUTH" | python3 -m json.tool 2>/dev/null || curl -s "$BASE/api/home/summary?month=2026-03" -H "$AUTH"
echo ""

echo ""
echo "=== 6. 统计页 ==="
curl -s "$BASE/api/stats/overview?month=2026-03" -H "$AUTH" | python3 -m json.tool 2>/dev/null || curl -s "$BASE/api/stats/overview?month=2026-03" -H "$AUTH"
echo ""

echo ""
echo "=== 7. 账单列表 ==="
curl -s "$BASE/api/bills?month=2026-03" -H "$AUTH" | python3 -m json.tool 2>/dev/null || curl -s "$BASE/api/bills?month=2026-03" -H "$AUTH"
echo ""

echo ""
echo "=== 8. 分类列表 ==="
curl -s "$BASE/api/categories" -H "$AUTH" | python3 -m json.tool 2>/dev/null || curl -s "$BASE/api/categories" -H "$AUTH"
echo ""
