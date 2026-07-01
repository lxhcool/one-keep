import type { FastifyInstance } from "fastify";
import bcrypt from "bcryptjs";
import crypto from "node:crypto";
import { getPrisma } from "../utils/prisma.js";
import { registerSchema, loginSchema, meSchema, sendCodeSchema, verifyCodeSchema } from "../schemas/auth.js";
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

  app.get("/api/auth/me", { schema: meSchema }, async (request) => {
    const user = await prisma.user.findUniqueOrThrow({
      where: { id: request.userId },
      select: {
        id: true,
        username: true,
        email: true,
        name: true,
      },
    });

    return {
      user: serializeUser(user),
    };
  });

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

  app.delete("/api/auth/account", async (request, reply) => {
    const userId = request.userId;

    // 删除用户的所有交易记录和分类
    await prisma.transaction.deleteMany({ where: { userId } });
    await prisma.category.deleteMany({ where: { userId } });
    // 删除用户本身
    await prisma.user.delete({ where: { id: userId } });

    return { success: true };
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

  // ========== 邮箱验证码登录/注册 ==========

  app.post("/api/auth/send-code", { schema: sendCodeSchema }, async (request, reply) => {
    const { email } = request.body as { email: string };
    const normalizedEmail = email.trim().toLowerCase();

    // 限流: 同一邮箱 60 秒内只能发一次
    const recent = await prisma.verificationCode.findFirst({
      where: {
        email: normalizedEmail,
        createdAt: { gte: new Date(Date.now() - 60 * 1000) },
      },
      orderBy: { createdAt: "desc" },
    });
    if (recent) {
      const wait = Math.ceil((recent.createdAt.getTime() + 60000 - Date.now()) / 1000);
      return reply.status(429).send({ error: `请 ${wait} 秒后再试` });
    }

    // 生成 6 位验证码
    const code = String(Math.floor(100000 + Math.random() * 900000));
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 分钟有效

    await prisma.verificationCode.create({
      data: { email: normalizedEmail, code, expiresAt },
    });

    // 发送邮件。开发环境未配置 Resend 时，验证码打印到服务端日志方便本地联调。
    const resendKey = process.env.RESEND_API_KEY;
    if (resendKey) {
      try {
        const { Resend } = await import("resend");
        const resend = new Resend(resendKey);
        const result = await resend.emails.send({
          from: process.env.RESEND_FROM || "厘清 <noreply@lxhcoool.cn>",
          to: normalizedEmail,
          subject: "您的厘清验证码",
          html: `<div style="font-family: sans-serif; padding: 24px;">
            <h2 style="color: #10B981;">厘清</h2>
            <p>您的验证码是：</p>
            <div style="font-size: 32px; letter-spacing: 8px; font-weight: bold; color: #10B981; padding: 16px; text-align: center;">
              ${code}
            </div>
            <p style="color: #666;">验证码 10 分钟内有效，请勿透露给他人。</p>
          </div>`,
        });
        if (result.error) {
          request.log.warn(result.error, "Failed to send email via Resend");
          return reply.status(502).send({ error: "验证码邮件发送失败，请稍后重试" });
        }
      } catch (e) {
        request.log.warn(e, "Failed to send email via Resend");
        return reply.status(502).send({ error: "验证码邮件发送失败，请稍后重试" });
      }
    } else if (process.env.NODE_ENV !== "production") {
      request.log.info(`[DEV] Verification code for ${normalizedEmail}: ${code}`);
    } else {
      request.log.error("RESEND_API_KEY is not configured");
      return reply.status(503).send({ error: "验证码邮件服务未配置" });
    }

    return { success: true };
  });

  app.post("/api/auth/verify-code", { schema: verifyCodeSchema }, async (request, reply) => {
    const { email, code } = request.body as { email: string; code: string };
    const normalizedEmail = email.trim().toLowerCase();

    // 查找有效的验证码
    const record = await prisma.verificationCode.findFirst({
      where: {
        email: normalizedEmail,
        code,
        used: false,
        expiresAt: { gte: new Date() },
      },
      orderBy: { createdAt: "desc" },
    });

    if (!record) {
      return reply.status(400).send({ error: "验证码无效或已过期" });
    }

    // 标记为已使用
    await prisma.verificationCode.update({
      where: { id: record.id },
      data: { used: true },
    });

    // 查找或创建用户
    let user = await prisma.user.findUnique({ where: { email: normalizedEmail } });
    let isNewUser = false;

    if (!user) {
      const defaultName = normalizedEmail.split("@")[0];
      const randomSuffix = crypto.randomBytes(3).toString("hex");
      user = await prisma.user.create({
        data: {
          email: normalizedEmail,
          username: `user_${randomSuffix}`,
          password: "", // 邮箱验证用户无需密码
          name: defaultName,
        },
      });
      await ensureUserCategories(prisma, user.id);
      isNewUser = true;
    }

    const token = app.jwt.sign({ sub: user.id }, { expiresIn: "7d" });
    return {
      token,
      user: serializeUser(user),
      isNewUser,
    };
  });
}
