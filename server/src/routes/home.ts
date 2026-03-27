import type { FastifyInstance } from "fastify";
import { getPrisma } from "../utils/prisma.js";
import { monthRange, toNumber } from "../utils/date.js";
import { homeSummarySchema } from "../schemas/home.js";

export default async function homeRoutes(app: FastifyInstance) {
  const prisma = getPrisma();

  // GET /api/home/summary?month=2026-03
  app.get("/api/home/summary", { schema: homeSummarySchema }, async (request) => {
    const { month } = request.query as { month: string };
    const userId = request.userId;
    const { start, end } = monthRange(month);

    // 并行查询
    const [user, aggregates, recentTransactions] = await Promise.all([
      prisma.user.findUniqueOrThrow({
        where: { id: userId },
        select: { id: true, name: true, email: true },
      }),

      prisma.transaction.groupBy({
        by: ["direction"],
        where: { userId, occurredAt: { gte: start, lt: end } },
        _sum: { amount: true },
      }),

      prisma.transaction.findMany({
        where: { userId, occurredAt: { gte: start, lt: end } },
        orderBy: { occurredAt: "desc" },
        take: 10,
        include: { category: { select: { name: true, icon: true } } },
      }),
    ]);

    const income = aggregates.find((a) => a.direction === "income");
    const expense = aggregates.find((a) => a.direction === "expense");

    const totalIncome = income?._sum.amount ? toNumber(income._sum.amount) : 0;
    const totalExpense = expense?._sum.amount ? toNumber(expense._sum.amount) : 0;

    return {
      user,
      balanceSummary: {
        amount: totalIncome - totalExpense,
      },
      incomeSummary: { amount: totalIncome },
      expenseSummary: { amount: totalExpense },
      recentTransactions: recentTransactions.map((t) => ({
        transactionId: t.id,
        categoryId: t.categoryId,
        title: t.title,
        categoryName: t.category.name,
        categoryIcon: t.category.icon,
        occurredAt: t.occurredAt.toISOString(),
        amount: toNumber(t.amount),
        direction: t.direction,
        note: t.note,
        merchant: t.merchant,
      })),
    };
  });
}
