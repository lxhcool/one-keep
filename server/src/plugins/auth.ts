import type { FastifyInstance } from "fastify";
import fp from "fastify-plugin";
import { getPrisma } from "../utils/prisma.js";

declare module "fastify" {
  interface FastifyRequest {
    userId: string;
  }
}

export default fp(async function authPlugin(app: FastifyInstance) {
  app.decorateRequest("userId", "");

  app.addHook("onRequest", async (request, reply) => {
    // 跳过不需要认证的路由
    const publicRoutes = ["/api/auth/login", "/api/auth/register", "/api/auth/send-code", "/api/auth/verify-code", "/api/health", "/docs"];
    const isPublic = publicRoutes.some((r) => request.url.startsWith(r));
    if (isPublic) return;

    try {
      const decoded = await request.jwtVerify<{ sub: string }>();
      request.userId = decoded.sub;
    } catch {
      reply.status(401).send({ error: "未授权" });
    }
  });
});
