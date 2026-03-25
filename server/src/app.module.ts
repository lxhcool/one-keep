import { Module } from '@nestjs/common';
import { APP_FILTER, APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { TransactionsModule } from './transactions/transactions.module';
import { StatisticsModule } from './statistics/statistics.module';
import { HealthController } from './health/health.controller';
import { JwtAuthGuard } from './common/guards/jwt-auth.guard';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { LoggingInterceptor } from './common/interceptors/logging.interceptor';

@Module({
  imports: [
    PrismaModule,
    AuthModule,
    UsersModule,
    TransactionsModule,
    StatisticsModule,
  ],
  controllers: [HealthController],
  providers: [
    // 全局 JWT 守卫（白名单路由用 @Public() 跳过）
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    // 全局异常过滤
    { provide: APP_FILTER, useClass: HttpExceptionFilter },
    // 全局请求日志
    { provide: APP_INTERCEPTOR, useClass: LoggingInterceptor },
  ],
})
export class AppModule {}
