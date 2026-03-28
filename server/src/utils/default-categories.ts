import type { PrismaClient, TransactionType } from "@prisma/client";

type CategoryTemplate = {
  id: string;
  name: string;
  icon: string;
  type: TransactionType;
  sort: number;
};

export const defaultCategoryTemplates: CategoryTemplate[] = [
  { id: "tpl_expense_dining", name: "用餐", icon: "a-068_yongcan", type: "expense", sort: 1 },
  { id: "tpl_expense_transit", name: "公交", icon: "a-068_gongjiao", type: "expense", sort: 2 },
  { id: "tpl_expense_shopping", name: "购物", icon: "a-068_gouwu", type: "expense", sort: 3 },
  { id: "tpl_expense_life", name: "生活", icon: "a-068_shenghuo", type: "expense", sort: 4 },
  { id: "tpl_expense_utilities", name: "水电", icon: "a-068_shuidian", type: "expense", sort: 5 },
  { id: "tpl_expense_fuel", name: "加油", icon: "a-068_jiayou", type: "expense", sort: 6 },
  { id: "tpl_expense_travel", name: "旅行", icon: "a-068_lvyou", type: "expense", sort: 7 },
  { id: "tpl_expense_medical", name: "就医", icon: "a-068_jiuyi", type: "expense", sort: 8 },
  { id: "tpl_income_salary", name: "工资", icon: "a-068_gongzi", type: "income", sort: 1 },
  { id: "tpl_income_parttime", name: "兼职", icon: "a-068_jianzhi", type: "income", sort: 2 },
  { id: "tpl_income_finance", name: "理财", icon: "a-068_licai", type: "income", sort: 3 },
  { id: "tpl_income_transfer", name: "转账", icon: "a-068_zhuanzhang", type: "income", sort: 4 },
  { id: "tpl_income_reimbursement", name: "报销", icon: "a-068_baoxiao", type: "income", sort: 5 },
];

export async function ensureGlobalCategoryTemplates(prisma: PrismaClient) {
  for (const template of defaultCategoryTemplates) {
    await prisma.category.upsert({
      where: { id: template.id },
      update: {
        name: template.name,
        icon: template.icon,
        type: template.type,
        sort: template.sort,
        userId: null,
      },
      create: {
        id: template.id,
        name: template.name,
        icon: template.icon,
        type: template.type,
        sort: template.sort,
        userId: null,
      },
    });
  }
}

export async function ensureUserCategories(prisma: PrismaClient, userId: string) {
  const userCategoryCount = await prisma.category.count({
    where: { userId },
  });
  if (userCategoryCount > 0) return;

  await ensureGlobalCategoryTemplates(prisma);

  const templates = await prisma.category.findMany({
    where: { userId: null },
    orderBy: [{ type: "asc" }, { sort: "asc" }],
  });

  if (templates.length == 0) return;

  await prisma.category.createMany({
    data: templates.map((template) => ({
      name: template.name,
      icon: template.icon,
      type: template.type,
      sort: template.sort,
      userId,
    })),
  });
}

export async function resequenceUserCategories(
  prisma: PrismaClient,
  userId: string,
  type: TransactionType,
) {
  const categories = await prisma.category.findMany({
    where: { userId, type },
    orderBy: [{ sort: "asc" }, { id: "asc" }],
  });

  await prisma.$transaction(
    categories.map((category, index) =>
      prisma.category.update({
        where: { id: category.id },
        data: { sort: index + 1 },
      }),
    ),
  );
}
