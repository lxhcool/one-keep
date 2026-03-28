import type { FastifyInstance } from "fastify";
import { getPrisma } from "../utils/prisma.js";
import {
  createTransactionSchema,
  deleteTransactionSchema,
  updateTransactionSchema,
} from "../schemas/transaction.js";

export default async function transactionRoutes(app: FastifyInstance) {
  const prisma = getPrisma();

  async function findAccessibleCategory(userId: string, categoryId: string) {
    return prisma.category.findFirst({
      where: {
        id: categoryId,
        OR: [{ userId }, { userId: null }],
      },
    });
  }

  app.post("/api/transactions", { schema: createTransactionSchema }, async (request, reply) => {
    const { title, amount, direction, categoryId, occurredAt, note, merchant } = request.body as {
      title: string;
      amount: number;
      direction: "expense" | "income";
      categoryId: string;
      occurredAt: string;
      note?: string;
      merchant?: string;
    };
    const userId = request.userId;

    const category = await findAccessibleCategory(userId, categoryId);
    if (!category) {
      return reply.status(400).send({ error: "分类不存在" });
    }
    if (category.type !== direction) {
      return reply.status(400).send({ error: "分类类型与记账方向不匹配" });
    }

    const tx = await prisma.transaction.create({
      data: {
        title,
        amount,
        direction,
        categoryId,
        occurredAt: new Date(occurredAt),
        note,
        merchant,
        userId,
      },
    });

    return reply.status(201).send({
      transactionId: tx.id,
      createdAt: tx.createdAt.toISOString(),
    });
  });

  app.put("/api/transactions/:id", { schema: updateTransactionSchema }, async (request, reply) => {
    const { id } = request.params as { id: string };
    const userId = request.userId;
    const data = request.body as Record<string, unknown>;

    const existing = await prisma.transaction.findUnique({ where: { id } });
    if (!existing || existing.userId !== userId) {
      return reply.status(404).send({ error: "记账记录不存在" });
    }

    const nextDirection = (data.direction as "expense" | "income" | undefined) ?? existing.direction;
    const nextCategoryId = (data.categoryId as string | undefined) ?? existing.categoryId;
    const category = await findAccessibleCategory(userId, nextCategoryId);
    if (!category) {
      return reply.status(400).send({ error: "分类不存在" });
    }
    if (category.type !== nextDirection) {
      return reply.status(400).send({ error: "分类类型与记账方向不匹配" });
    }

    if (data.occurredAt) {
      data.occurredAt = new Date(data.occurredAt as string);
    }

    const updated = await prisma.transaction.update({
      where: { id },
      data,
    });

    return { transactionId: updated.id, updatedAt: updated.updatedAt.toISOString() };
  });

  app.delete(
    "/api/transactions/:id",
    { schema: deleteTransactionSchema },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const userId = request.userId;

      const existing = await prisma.transaction.findUnique({ where: { id } });
      if (!existing || existing.userId !== userId) {
        return reply.status(404).send({ error: "记账记录不存在" });
      }

      await prisma.transaction.delete({ where: { id } });
      return reply.status(204).send();
    },
  );
}
