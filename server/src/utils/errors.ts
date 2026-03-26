import type { FastifyReply } from "fastify";

export class AppError extends Error {
  constructor(
    public statusCode: number,
    message: string,
  ) {
    super(message);
  }
}

export function sendError(reply: FastifyReply, statusCode: number, message: string) {
  return reply.status(statusCode).send({ error: message });
}
