import type { FastifyInstance } from "fastify";
import bcrypt from "bcryptjs";
import { getPrisma } from "../utils/prisma.js";
import { registerSchema, loginSchema } from "../schemas/auth.js";
import { ensureUserCategories } from "../utils/default-categories.js";

export default async function authRoutes(app: FastifyInstance) {
  const prisma = getPrisma();

  // 注册
  app.post("/api/auth/register", { schema: registerSchema }, async (request, reply) => {
    const { email, password, name } = request.body as {
      email: string;
      password: string;
      name: string;
    };

    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      return reply.status(409).send({ error: "邮箱已被注册" });
    }

    const hashed = await bcrypt.hash(password, 10);
    const user = await prisma.user.create({
      data: { email, password: hashed, name },
    });
    await ensureUserCategories(prisma, user.id);

    const token = app.jwt.sign({ sub: user.id }, { expiresIn: "7d" });
    return { token, user: { id: user.id, email: user.email, name: user.name } };
  });

  // 登录
  app.post("/api/auth/login", { schema: loginSchema }, async (request, reply) => {
    const { email, password } = request.body as { email: string; password: string };

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      return reply.status(401).send({ error: "邮箱或密码错误" });
    }

    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      return reply.status(401).send({ error: "邮箱或密码错误" });
    }

    const token = app.jwt.sign({ sub: user.id }, { expiresIn: "7d" });
    return { token, user: { id: user.id, email: user.email, name: user.name } };
  });
}
