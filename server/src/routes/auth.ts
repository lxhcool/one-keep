import type { FastifyInstance } from "fastify";
import bcrypt from "bcryptjs";
import { getPrisma } from "../utils/prisma.js";
import { registerSchema, loginSchema } from "../schemas/auth.js";
import { ensureUserCategories } from "../utils/default-categories.js";

function serializeUser(user: {
  id: string;
  username: string | null;
  email: string;
  name: string;
}) {
  return {
    id: user.id,
    username: user.username,
    email: user.email,
    name: user.name,
    displayName: user.name,
  };
}

export default async function authRoutes(app: FastifyInstance) {
  const prisma = getPrisma();

  app.post("/api/auth/register", { schema: registerSchema }, async (request, reply) => {
    const { username, email, displayName, password } = request.body as {
      username: string;
      email: string;
      displayName: string;
      password: string;
    };

    const normalizedUsername = username.trim().toLowerCase();
    const normalizedEmail = email.trim().toLowerCase();
    const normalizedDisplayName = displayName.trim();

    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [{ email: normalizedEmail }, { username: normalizedUsername }],
      },
    });

    if (existingUser?.email === normalizedEmail) {
      return reply.status(409).send({ error: "邮箱已被注册" });
    }
    if (existingUser?.username === normalizedUsername) {
      return reply.status(409).send({ error: "用户名已被占用" });
    }

    const hashed = await bcrypt.hash(password, 10);
    const user = await prisma.user.create({
      data: {
        username: normalizedUsername,
        email: normalizedEmail,
        password: hashed,
        name: normalizedDisplayName,
      },
    });
    await ensureUserCategories(prisma, user.id);

    const token = app.jwt.sign({ sub: user.id }, { expiresIn: "7d" });
    return {
      token,
      user: serializeUser(user),
    };
  });

  app.post("/api/auth/login", { schema: loginSchema }, async (request, reply) => {
    const { identifier, password } = request.body as {
      identifier: string;
      password: string;
    };

    const normalizedIdentifier = identifier.trim().toLowerCase();
    const user = await prisma.user.findFirst({
      where: {
        OR: [{ email: normalizedIdentifier }, { username: normalizedIdentifier }],
      },
    });

    if (!user) {
      return reply.status(401).send({ error: "用户名/邮箱或密码错误" });
    }

    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      return reply.status(401).send({ error: "用户名/邮箱或密码错误" });
    }

    const token = app.jwt.sign({ sub: user.id }, { expiresIn: "7d" });
    return {
      token,
      user: serializeUser(user),
    };
  });
}
