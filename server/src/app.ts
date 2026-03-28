import Fastify from "fastify";
import corePlugins from "./plugins/core.js";
import authPlugin from "./plugins/auth.js";
import authRoutes from "./routes/auth.js";
import homeRoutes from "./routes/home.js";
import statsRoutes from "./routes/stats.js";
import billsRoutes from "./routes/bills.js";
import categoryRoutes from "./routes/categories.js";
import transactionRoutes from "./routes/transactions.js";

export async function buildApp() {
  const app = Fastify({
    logger: {
      level: process.env.NODE_ENV === "production" ? "info" : "debug",
    },
  });

  // 插件
  await app.register(corePlugins);
  await app.register(authPlugin);

  // 路由
  await app.register(authRoutes);
  await app.register(homeRoutes);
  await app.register(statsRoutes);
  await app.register(billsRoutes);
  await app.register(categoryRoutes);
  await app.register(transactionRoutes);

  // 健康检查
  app.get("/api/health", async () => ({ status: "ok" }));

  return app;
}
