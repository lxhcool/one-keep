import type { FastifyInstance } from "fastify";
import { getPrisma } from "../utils/prisma.js";
import {
  createTransactionSchema,
  updateTransactionSchema,
  deleteTransactionSchema,
} from "../schemas/transaction.js";

export default async function transactionRoutes(app: FastifyInstance) {
  const prisma = getPrisma();

  // POST /api/transactions
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

    // 校验分类存在
    const category = await prisma.category.findUnique({ where: { id: categoryId } });
    if (!category) {
      return reply.status(400).send({ error: "分类不存在" });
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

  // PUT /api/transactions/:id
  app.put("/api/transactions/:id", { schema: updateTransactionSchema }, async (request, reply) => {
    const { id } = request.params as { id: string };
    const userId = request.userId;
    const data = request.body as Record<string, unknown>;

    const existing = await prisma.transaction.findUnique({ where: { id } });
    if (!existing || existing.userId !== userId) {
      return reply.status(404).send({ error: "交易不存在" });
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

  // DELETE /api/transactions/:id
  app.delete(
    "/api/transactions/:id",
    { schema: deleteTransactionSchema },
    async (request, reply) => {
      const { id } = request.params as { id: string };
      const userId = request.userId;

      const existing = await prisma.transaction.findUnique({ where: { id } });
      if (!existing || existing.userId !== userId) {
        return reply.status(404).send({ error: "交易不存在" });
      }

      await prisma.transaction.delete({ where: { id } });
      return reply.status(204).send();
    },
  );

  // GET /api/categories
  app.get("/api/categories", async () => {
    const categories = await prisma.category.findMany({
      orderBy: [{ type: "asc" }, { sort: "asc" }],
    });
    return { categories };
  });
}
