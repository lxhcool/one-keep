import type { FastifyPluginAsync } from 'fastify';
import { TransactionType } from '@prisma/client';
import { z } from 'zod';

const createTransactionSchema = z.object({
  type: z.enum([TransactionType.income, TransactionType.expense, TransactionType.transfer]),
  amountCents: z.number().int().positive(),
  note: z.string().trim().min(1).max(200).optional(),
  occurredAt: z.coerce.date().optional(),
});

const transactionsRoute: FastifyPluginAsync = async (app) => {
  app.get('/', async () => {
    return app.prisma.transaction.findMany({
      orderBy: { occurredAt: 'desc' },
      take: 100,
    });
  });

  app.post('/', async (request, reply) => {
    const body = createTransactionSchema.parse(request.body);

    const transaction = await app.prisma.transaction.create({
      data: {
        type: body.type,
        amountCents: body.amountCents,
        note: body.note,
        occurredAt: body.occurredAt ?? new Date(),
      },
    });

    return reply.code(201).send(transaction);
  });
};

export default transactionsRoute;
