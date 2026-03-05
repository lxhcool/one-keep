import type { FastifyPluginAsync } from 'fastify';

const healthRoute: FastifyPluginAsync = async (app) => {
  app.get('/', async () => {
    return { status: 'ok', service: 'onekeep-server' };
  });
};

export default healthRoute;
