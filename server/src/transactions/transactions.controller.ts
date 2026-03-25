import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import { CurrentUser, JwtPayload } from '../common/decorators/current-user.decorator';
import { CreateTransactionDto } from './dto/create-transaction.dto';
import { ListTransactionsDto } from './dto/list-transactions.dto';
import { TransactionsService } from './transactions.service';

@Controller('transactions')
export class TransactionsController {
  constructor(private readonly transactionsService: TransactionsService) {}

  @Post()
  create(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateTransactionDto,
  ) {
    return this.transactionsService.create(user.sub, dto);
  }

  @Get()
  list(@CurrentUser() user: JwtPayload, @Query() dto: ListTransactionsDto) {
    return this.transactionsService.list(user.sub, dto);
  }

  @Get('recent')
  recent(
    @CurrentUser() user: JwtPayload,
    @Query('limit', new ParseIntPipe({ optional: true })) limit = 5,
  ) {
    return this.transactionsService.recent(user.sub, Math.min(limit, 20));
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  delete(
    @CurrentUser() user: JwtPayload,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.transactionsService.delete(user.sub, id);
  }
}
