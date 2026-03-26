import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  const categories = [
    // 支出分类
    { name: "餐饮美食", icon: "restaurant", type: "expense" as const, sort: 1 },
    { name: "交通出行", icon: "directions_bus", type: "expense" as const, sort: 2 },
    { name: "购物消费", icon: "shopping_bag", type: "expense" as const, sort: 3 },
    { name: "生活缴费", icon: "receipt_long", type: "expense" as const, sort: 4 },
    { name: "休闲娱乐", icon: "sports_esports", type: "expense" as const, sort: 5 },
    { name: "医疗健康", icon: "local_hospital", type: "expense" as const, sort: 6 },
    { name: "教育学习", icon: "school", type: "expense" as const, sort: 7 },
    { name: "其他支出", icon: "more_horiz", type: "expense" as const, sort: 8 },
    // 收入分类
    { name: "工资薪资", icon: "work", type: "income" as const, sort: 1 },
    { name: "兼职收入", icon: "account_balance_wallet", type: "income" as const, sort: 2 },
    { name: "投资理财", icon: "trending_up", type: "income" as const, sort: 3 },
    { name: "其他收入", icon: "more_horiz", type: "income" as const, sort: 4 },
  ];

  for (const cat of categories) {
    await prisma.category.upsert({
      where: { id: `${cat.type}_${cat.sort}` },
      update: { name: cat.name, icon: cat.icon, type: cat.type, sort: cat.sort },
      create: { id: `${cat.type}_${cat.sort}`, ...cat },
    });
  }

  console.log(`Seeded ${categories.length} categories`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
