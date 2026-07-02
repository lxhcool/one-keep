import type { FastifyInstance } from "fastify";
import fp from "fastify-plugin";
import cors from "@fastify/cors";
import helmet from "@fastify/helmet";
import rateLimit from "@fastify/rate-limit";
import jwt from "@fastify/jwt";
import swagger from "@fastify/swagger";
import swaggerUI from "@fastify/swagger-ui";

export default fp(async function corePlugins(app: FastifyInstance) {
  const isDev = process.env.NODE_ENV !== "production";

  // 安全头
  await app.register(helmet);

  // 限流 — 登录接口每 IP 每分钟最多 10 次
  await app.register(rateLimit, {
    max: 100,
    timeWindow: "1 minute",
    keyGenerator: (request) => {
      return request.ip;
    },
  });

  // CORS — 生产环境只允许自己的域名
  await app.register(cors, {
    origin: isDev
      ? true
      : (
          process.env.CORS_ORIGIN ||
          "https://liqing.lxhcoool.cn,https://onekeep.lxhcoool.cn"
        ).split(","),
  });

  // JWT — 生产环境必须设置 JWT_SECRET
  if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET environment variable is required in production");
  }
  await app.register(jwt, {
    secret: process.env.JWT_SECRET,
  });

  // Swagger — 仅开发环境开启
  if (isDev) {
    await app.register(swagger, {
      openapi: {
        info: {
          title: "OneKeep API",
          version: "1.0.0",
          description: "个人记账应用 API",
        },
      },
    });

    await app.register(swaggerUI, {
      routePrefix: "/docs",
    });
  }
});
