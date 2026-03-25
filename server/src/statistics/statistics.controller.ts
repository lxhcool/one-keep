import { Controller, Get, ParseIntPipe, Query } from '@nestjs/common';
import { CurrentUser, JwtPayload } from '../common/decorators/current-user.decorator';
import { TransactionsService } from '../transactions/transactions.service';

@Controller('statistics')
export class StatisticsController {
  constructor(private readonly transactionsService: TransactionsService) {}

  @Get('summary')
  summary(
    @CurrentUser() user: JwtPayload,
    @Query('year', ParseIntPipe) year: number,
    @Query('month', ParseIntPipe) month: number,
  ) {
    return this.transactionsService.monthlySummary(user.sub, year, month);
  }

  @Get('categories')
  categories(
    @CurrentUser() user: JwtPayload,
    @Query('year', ParseIntPipe) year: number,
    @Query('month', ParseIntPipe) month: number,
    @Query('type') type: 'income' | 'expense' = 'expense',
  ) {
    return this.transactionsService.categoryStats(user.sub, year, month, type);
  }
}
