import type { FastifyInstance } from "fastify";
import { getPrisma } from "../utils/prisma.js";
import { monthRange, toNumber } from "../utils/date.js";
import { statsOverviewSchema } from "../schemas/stats.js";
import type { TransactionType } from "@prisma/client";

export default async function statsRoutes(app: FastifyInstance) {
  const prisma = getPrisma();

  // GET /api/stats/overview?month=2026-03&metricType=expense
  app.get("/api/stats/overview", { schema: statsOverviewSchema }, async (request) => {
    const { month, metricType } = request.query as {
      month: string;
      metricType?: TransactionType;
    };
    const userId = request.userId;
    const { start, end } = monthRange(month);

    const whereBase = { userId, occurredAt: { gte: start, lt: end } };

    // 总览
    const aggregates = await prisma.transaction.groupBy({
      by: ["direction"],
      where: whereBase,
      _sum: { amount: true },
    });

    const incomeAgg = aggregates.find((a) => a.direction === "income");
    const expenseAgg = aggregates.find((a) => a.direction === "expense");

    const totalIncome = incomeAgg?._sum.amount ? toNumber(incomeAgg._sum.amount) : 0;
    const totalExpense = expenseAgg?._sum.amount ? toNumber(expenseAgg._sum.amount) : 0;

    // 趋势：按日聚合（当月每一天）— 用 Prisma 查询代替原生 SQL 以兼容 SQLite/MySQL
    const trendDirection = metricType ?? "expense";
    const trendTransactions = await prisma.transaction.findMany({
      where: { userId, direction: trendDirection, occurredAt: { gte: start, lt: end } },
      select: { occurredAt: true, amount: true },
      orderBy: { occurredAt: "asc" },
    });

    // 在应用层按日聚合
    const dayMap = new Map<string, number>();
    for (const t of trendTransactions) {
      const day = t.occurredAt.toISOString().slice(0, 10);
      dayMap.set(day, (dayMap.get(day) ?? 0) + toNumber(t.amount));
    }
    const trendSeries = Array.from(dayMap.entries()).map(([day, total]) => ({
      label: day.slice(5), // "03-01"
      value: total,
    }));

    // 分类排行
    const categoryRanks = await prisma.transaction.groupBy({
      by: ["categoryId"],
      where: { ...whereBase, direction: trendDirection },
      _sum: { amount: true },
      orderBy: { _sum: { amount: "desc" } },
      take: 10,
    });

    const categoryIds = categoryRanks.map((r) => r.categoryId);
    const categories = await prisma.category.findMany({
      where: { id: { in: categoryIds } },
    });
    const catMap = new Map(categories.map((c) => [c.id, c]));

    const maxAmount = categoryRanks[0]?._sum.amount
      ? toNumber(categoryRanks[0]._sum.amount)
      : 0;

    return {
      totals: { income: totalIncome, expense: totalExpense },
      trendSeries,
      categoryRanks: categoryRanks.map((r) => {
        const cat = catMap.get(r.categoryId);
        const amount = r._sum.amount ? toNumber(r._sum.amount) : 0;
        return {
          categoryId: r.categoryId,
          categoryName: cat?.name ?? "",
          categoryIcon: cat?.icon ?? "",
          amount,
          progressBase: maxAmount,
          progressRatio: maxAmount > 0 ? amount / maxAmount : 0,
        };
      }),
    };
  });
}
