import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  const categories = [
    // ── 支出分类 ──
    // 餐饮
    { name: "早餐", icon: "breakfast", type: "expense" as const, sort: 1 },
    { name: "午餐", icon: "lunch", type: "expense" as const, sort: 2 },
    { name: "晚餐", icon: "dinner", type: "expense" as const, sort: 3 },
    { name: "火锅", icon: "hotpot", type: "expense" as const, sort: 4 },
    { name: "烤肉", icon: "bbq", type: "expense" as const, sort: 5 },
    { name: "烤串", icon: "skewer", type: "expense" as const, sort: 6 },
    { name: "饺子", icon: "dumpling", type: "expense" as const, sort: 7 },
    { name: "买菜", icon: "grocery", type: "expense" as const, sort: 8 },
    { name: "水果", icon: "fruit", type: "expense" as const, sort: 9 },
    { name: "零食", icon: "snacks", type: "expense" as const, sort: 10 },
    { name: "冰淇淋", icon: "ice_cream", type: "expense" as const, sort: 11 },
    // 饮品
    { name: "咖啡", icon: "coffee", type: "expense" as const, sort: 12 },
    { name: "奶茶", icon: "milk_tea", type: "expense" as const, sort: 13 },
    { name: "饮品", icon: "drinks", type: "expense" as const, sort: 14 },
    { name: "可乐", icon: "cola", type: "expense" as const, sort: 15 },
    { name: "雪碧", icon: "sprite", type: "expense" as const, sort: 16 },
    // 酒水
    { name: "啤酒", icon: "beer", type: "expense" as const, sort: 17 },
    { name: "葡萄酒", icon: "wine", type: "expense" as const, sort: 18 },
    { name: "白酒", icon: "baijiu", type: "expense" as const, sort: 19 },
    { name: "洋酒", icon: "spirits", type: "expense" as const, sort: 20 },
    { name: "菠萝啤", icon: "pineapple_beer", type: "expense" as const, sort: 21 },
    // 交通
    { name: "公交", icon: "bus", type: "expense" as const, sort: 22 },
    { name: "出租车", icon: "taxi", type: "expense" as const, sort: 23 },
    { name: "火车", icon: "train", type: "expense" as const, sort: 24 },
    { name: "飞机", icon: "flight", type: "expense" as const, sort: 25 },
    { name: "加油", icon: "fuel", type: "expense" as const, sort: 26 },
    { name: "停车费", icon: "parking", type: "expense" as const, sort: 27 },
    { name: "汽车", icon: "car", type: "expense" as const, sort: 28 },
    // 购物
    { name: "购物", icon: "shopping", type: "expense" as const, sort: 29 },
    { name: "衣服", icon: "clothing", type: "expense" as const, sort: 30 },
    { name: "鞋子", icon: "shoes", type: "expense" as const, sort: 31 },
    { name: "袜子", icon: "socks", type: "expense" as const, sort: 32 },
    { name: "围巾", icon: "scarf", type: "expense" as const, sort: 33 },
    // 数码 & 通讯
    { name: "手机", icon: "phone", type: "expense" as const, sort: 34 },
    { name: "电脑", icon: "computer", type: "expense" as const, sort: 35 },
    { name: "话费", icon: "phone_bill", type: "expense" as const, sort: 36 },
    // 生活
    { name: "水电", icon: "utilities", type: "expense" as const, sort: 37 },
    { name: "装修", icon: "renovation", type: "expense" as const, sort: 38 },
    { name: "车房贷", icon: "mortgage", type: "expense" as const, sort: 39 },
    { name: "宠物", icon: "pet", type: "expense" as const, sort: 40 },
    { name: "文具", icon: "stationery", type: "expense" as const, sort: 41 },
    // 娱乐
    { name: "电影", icon: "movie", type: "expense" as const, sort: 42 },
    { name: "游戏", icon: "gaming", type: "expense" as const, sort: 43 },
    { name: "演唱会", icon: "concert", type: "expense" as const, sort: 44 },
    { name: "音乐", icon: "music", type: "expense" as const, sort: 45 },
    { name: "运动", icon: "sports", type: "expense" as const, sort: 46 },
    { name: "旅游", icon: "travel", type: "expense" as const, sort: 47 },
    // 个人护理
    { name: "理发", icon: "haircut", type: "expense" as const, sort: 48 },
    { name: "美容", icon: "beauty", type: "expense" as const, sort: 49 },
    { name: "化妆品", icon: "cosmetics", type: "expense" as const, sort: 50 },
    { name: "按摩", icon: "massage", type: "expense" as const, sort: 51 },
    // 医疗
    { name: "看诊", icon: "clinic", type: "expense" as const, sort: 52 },
    { name: "药品", icon: "medicine", type: "expense" as const, sort: 53 },
    // 社交 & 节日
    { name: "礼物", icon: "gift", type: "expense" as const, sort: 54 },
    { name: "鲜花", icon: "flowers", type: "expense" as const, sort: 55 },
    { name: "节日", icon: "festival", type: "expense" as const, sort: 56 },
    // 其他
    { name: "其他支出", icon: "other", type: "expense" as const, sort: 57 },

    // ── 收入分类 ──
    { name: "工资", icon: "salary", type: "income" as const, sort: 1 },
    { name: "理财", icon: "investment", type: "income" as const, sort: 2 },
    { name: "红包", icon: "red_envelope", type: "income" as const, sort: 3 },
    { name: "转账", icon: "transfer", type: "income" as const, sort: 4 },
    { name: "其他收入", icon: "other", type: "income" as const, sort: 5 },
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
