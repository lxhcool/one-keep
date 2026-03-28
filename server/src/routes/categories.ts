import type { FastifyInstance, FastifyReply } from "fastify";
import type { TransactionType } from "@prisma/client";
import { getPrisma } from "../utils/prisma.js";
import {
  createCategorySchema,
  deleteCategorySchema,
  listCategoriesSchema,
  reorderCategoriesSchema,
  updateCategorySchema,
} from "../schemas/category.js";
import {
  ensureUserCategories,
  resequenceUserCategories,
} from "../utils/default-categories.js";

function serializeCategory(category: {
  id: string;
  name: string;
  icon: string;
  type: TransactionType;
  sort: number;
}) {
  return {
    id: category.id,
    name: category.name,
    icon: category.icon,
    type: category.type,
    sort: category.sort,
  };
}

async function findOwnedCategory(
  prisma: ReturnType<typeof getPrisma>,
  userId: string,
  categoryId: string,
  reply: FastifyReply,
) {
  const category = await prisma.category.findFirst({
    where: { id: categoryId, userId },
  });

  if (!category) {
    reply.status(404).send({ error: "分类不存在" });
    return null;
  }

  return category;
}

export default async function categoryRoutes(app: FastifyInstance) {
  const prisma = getPrisma();

  app.get("/api/categories", { schema: listCategoriesSchema }, async (request) => {
    await ensureUserCategories(prisma, request.userId);

    const categories = await prisma.category.findMany({
      where: { userId: request.userId },
      orderBy: [{ type: "asc" }, { sort: "asc" }, { id: "asc" }],
    });

    return { categories: categories.map(serializeCategory) };
  });

  app.post("/api/categories", { schema: createCategorySchema }, async (request, reply) => {
    const { name, icon, type } = request.body as {
      name: string;
      icon: string;
      type: TransactionType;
    };
    const userId = request.userId;

    await ensureUserCategories(prisma, userId);

    const sort = await prisma.category.count({
      where: { userId, type },
    });

    const category = await prisma.category.create({
      data: {
        name: name.trim(),
        icon,
        type,
        sort: sort + 1,
        userId,
      },
    });

    return reply.status(201).send({ category: serializeCategory(category) });
  });

  app.put("/api/categories/reorder", { schema: reorderCategoriesSchema }, async (request, reply) => {
    const { type, categoryIds } = request.body as {
      type: TransactionType;
      categoryIds: string[];
    };
    const userId = request.userId;

    const categories = await prisma.category.findMany({
      where: { userId, type },
      select: { id: true },
      orderBy: [{ sort: "asc" }, { id: "asc" }],
    });
    const ownedIds = categories.map((category) => category.id);

    if (
      ownedIds.length !== categoryIds.length ||
      ownedIds.some((id) => !categoryIds.includes(id))
    ) {
      return reply.status(400).send({ error: "分类排序数据无效" });
    }

    await prisma.$transaction(
      categoryIds.map((id, index) =>
        prisma.category.update({
          where: { id },
          data: { sort: index + 1 },
        }),
      ),
    );

    const updated = await prisma.category.findMany({
      where: { userId },
      orderBy: [{ type: "asc" }, { sort: "asc" }, { id: "asc" }],
    });

    return { categories: updated.map(serializeCategory) };
  });

  app.put("/api/categories/:id", { schema: updateCategorySchema }, async (request, reply) => {
    const { id } = request.params as { id: string };
    const { name, icon, type } = request.body as {
      name?: string;
      icon?: string;
      type?: TransactionType;
    };
    const userId = request.userId;

    const category = await findOwnedCategory(prisma, userId, id, reply);
    if (!category) return;

    const nextType = type ?? category.type;
    if (type && type !== category.type) {
      const txCount = await prisma.transaction.count({
        where: { categoryId: category.id },
      });
      if (txCount > 0) {
        return reply.status(400).send({ error: "已有记账记录的分类暂不支持切换收入/支出类型" });
      }
    }

    const nextSort =
      nextType === category.type
        ? category.sort
        : (await prisma.category.count({ where: { userId, type: nextType } })) + 1;

    const updated = await prisma.category.update({
      where: { id: category.id },
      data: {
        name: name?.trim() ?? category.name,
        icon: icon ?? category.icon,
        type: nextType,
        sort: nextSort,
      },
    });

    if (nextType !== category.type) {
      await resequenceUserCategories(prisma, userId, category.type);
      await resequenceUserCategories(prisma, userId, nextType);
    }

    return { category: serializeCategory(updated) };
  });

  app.delete("/api/categories/:id", { schema: deleteCategorySchema }, async (request, reply) => {
    const { id } = request.params as { id: string };
    const userId = request.userId;

    const category = await findOwnedCategory(prisma, userId, id, reply);
    if (!category) return;

    const txCount = await prisma.transaction.count({
      where: { categoryId: category.id },
    });
    if (txCount > 0) {
      return reply.status(400).send({ error: "已有记账记录的分类不能删除" });
    }

    await prisma.category.delete({
      where: { id: category.id },
    });
    await resequenceUserCategories(prisma, userId, category.type);

    return reply.status(204).send();
  });
}
