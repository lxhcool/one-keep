import cors from '@fastify/cors';
import Fastify from 'fastify';

import { loadEnv } from './config/env';
import prismaPlugin from './plugins/prisma';
import healthRoute from './routes/health';
import transactionsRoute from './routes/transactions';

async function bootstrap() {
  const env = loadEnv();
  const app = Fastify({ logger: true });

  await app.register(cors, {
    origin: true,
  });
  await app.register(prismaPlugin, { databaseUrl: env.DATABASE_URL });
  await app.register(healthRoute, { prefix: '/health' });
  await app.register(transactionsRoute, { prefix: '/transactions' });

  await app.listen({
    port: env.PORT,
    host: '0.0.0.0',
  });
}

bootstrap().catch((error) => {
  console.error(error);
  process.exit(1);
});
