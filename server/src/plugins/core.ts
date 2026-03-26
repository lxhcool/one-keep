import type { FastifyInstance } from "fastify";
import fp from "fastify-plugin";
import cors from "@fastify/cors";
import jwt from "@fastify/jwt";
import swagger from "@fastify/swagger";
import swaggerUI from "@fastify/swagger-ui";

export default fp(async function corePlugins(app: FastifyInstance) {
  // CORS
  await app.register(cors, { origin: true });

  // JWT
  await app.register(jwt, {
    secret: process.env.JWT_SECRET || "dev-secret-change-me",
  });

  // Swagger
  await app.register(swagger, {
    openapi: {
      info: {
        title: "OneKeep API",
        version: "0.1.0",
        description: "个人记账应用 API",
      },
    },
  });

  await app.register(swaggerUI, {
    routePrefix: "/docs",
  });
});
