import type { FastifyInstance } from "fastify";
import { getPrisma } from "../utils/prisma.js";
import { monthRange, toNumber } from "../utils/date.js";
import { billsListSchema } from "../schemas/bills.js";
import type { Prisma } from "@prisma/client";

export default async function billsRoutes(app: FastifyInstance) {
  const prisma = getPrisma();

  // GET /api/bills
  app.get("/api/bills", { schema: billsListSchema }, async (request) => {
    const { month, filterType, query, cursor, pageSize } = request.query as {
      month?: string;
      filterType?: string;
      query?: string;
      cursor?: string;
      pageSize?: number;
    };
    const userId = request.userId;
    const take = pageSize ?? 20;

    const where: Prisma.TransactionWhereInput = { userId };

    // 月份筛选
    if (month) {
      const { start, end } = monthRange(month);
      where.occurredAt = { gte: start, lt: end };
    }

    // 收支类型筛选
    if (filterType && filterType !== "all") {
      where.direction = filterType as "expense" | "income";
    }

    // 搜索
    if (query) {
      where.OR = [
        { title: { contains: query } },
        { note: { contains: query } },
        { category: { name: { contains: query } } },
      ];
    }

    // 游标分页
    const findArgs: Prisma.TransactionFindManyArgs = {
      where,
      orderBy: { occurredAt: "desc" },
      take: take + 1, // 多取一条判断是否有下一页
      include: { category: { select: { name: true, icon: true } } },
    };
    if (cursor) {
      findArgs.cursor = { id: cursor };
      findArgs.skip = 1;
    }

    const items = await prisma.transaction.findMany(findArgs);
    const hasMore = items.length > take;
    if (hasMore) items.pop();

    // 按日期分组
    const groups = new Map<
      string,
      {
        date: string;
        items: typeof items;
        expenseTotal: number;
        incomeTotal: number;
      }
    >();

    for (const item of items) {
      const dateKey = item.occurredAt.toISOString().slice(0, 10);
      let group = groups.get(dateKey);
      if (!group) {
        group = { date: dateKey, items: [], expenseTotal: 0, incomeTotal: 0 };
        groups.set(dateKey, group);
      }
      group.items.push(item);
      const amt = toNumber(item.amount);
      if (item.direction === "expense") group.expenseTotal += amt;
      else group.incomeTotal += amt;
    }

    const groupedBills = Array.from(groups.values()).map((g) => ({
      date: g.date,
      summary: {
        expense: g.expenseTotal,
        income: g.incomeTotal,
      },
      items: g.items.map((t) => {
        const cat = (t as any).category as { name: string; icon: string };
        return {
          transactionId: t.id,
          categoryId: t.categoryId,
          title: t.title,
          categoryName: cat.name,
          categoryIcon: cat.icon,
          occurredAt: t.occurredAt.toISOString(),
          amount: toNumber(t.amount),
          direction: t.direction,
          note: t.note,
          merchant: t.merchant,
        };
      }),
    }));

    return {
      groupedBills,
      nextCursor: hasMore ? items[items.length - 1]?.id : null,
    };
  });
}
