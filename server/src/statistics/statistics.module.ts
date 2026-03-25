import { Module } from '@nestjs/common';
import { StatisticsController } from './statistics.controller';
import { TransactionsModule } from '../transactions/transactions.module';

@Module({
  imports: [TransactionsModule],
  controllers: [StatisticsController],
})
export class StatisticsModule {}
