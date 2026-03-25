import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import {
  FastifyAdapter,
  NestFastifyApplication,
} from '@nestjs/platform-fastify';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create<NestFastifyApplication>(
    AppModule,
    new FastifyAdapter({ logger: false }),
  );

  // 全局路由前缀
  app.setGlobalPrefix('api');

  // 全局请求校验
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,         // 剥离未声明字段
      forbidNonWhitelisted: true,
      transform: true,         // 自动类型转换（Query number 等）
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  // CORS（生产环境替换为实际域名）
  app.enableCors({
    origin: process.env.NODE_ENV === 'production'
      ? false           // 同域部署无需 CORS
      : true,           // 开发环境允许所有来源
    credentials: true,
  });

  const port = Number(process.env.PORT) || 3000;
  await app.listen(port, '0.0.0.0');
  console.log(`OneKeep API running on http://0.0.0.0:${port}/api`);
}

bootstrap();
