import fp from 'fastify-plugin';
import { PrismaClient } from '@prisma/client';
import type { FastifyPluginAsync } from 'fastify';

declare module 'fastify' {
  interface FastifyInstance {
    prisma: PrismaClient;
  }
}

type PrismaPluginOptions = {
  databaseUrl: string;
};

const prismaPlugin: FastifyPluginAsync<PrismaPluginOptions> = async (app, options) => {
  const prisma = new PrismaClient({
    datasources: {
      db: {
        url: options.databaseUrl,
      },
    },
  });

  await prisma.$connect();
  app.decorate('prisma', prisma);

  app.addHook('onClose', async () => {
    await prisma.$disconnect();
  });
};

export default fp(prismaPlugin, {
  name: 'prisma',
});
