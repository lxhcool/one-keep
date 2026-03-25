import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { TransactionType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateTransactionDto } from './dto/create-transaction.dto';
import { FilterEnum, ListTransactionsDto } from './dto/list-transactions.dto';

const VALID_CATEGORIES = new Set([
  'food',
  'transport',
  'shopping',
  'salary',
  'other',
]);

@Injectable()
export class TransactionsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(userId: string, dto: CreateTransactionDto) {
    if (!VALID_CATEGORIES.has(dto.categoryId)) {
      throw new BadRequestException(`未知分类: ${dto.categoryId}`);
    }
    const occurredAt = new Date(dto.occurredAt);
    if (occurredAt > new Date()) {
      throw new BadRequestException('occurredAt 不能超过当前时间');
    }

    return this.prisma.transaction.create({
      data: {
        userId,
        type: dto.type as TransactionType,
        categoryId: dto.categoryId,
        amountCents: dto.amountCents,
        title: dto.title,
        note: dto.note ?? null,
        occurredAt,
      },
    });
  }

  async delete(userId: string, id: string) {
    const txn = await this.prisma.transaction.findUnique({ where: { id } });
    if (!txn) throw new NotFoundException('账单不存在');
    if (txn.userId !== userId) throw new ForbiddenException('无权操作此账单');
    await this.prisma.transaction.delete({ where: { id } });
  }

  async list(userId: string, dto: ListTransactionsDto) {
    const { year, month, filter, page, limit } = dto;
    const { start, end } = this.monthRange(year, month);

    const where = {
      userId,
      occurredAt: { gte: start, lt: end },
      ...(filter !== FilterEnum.all && { type: filter as TransactionType }),
    };

    const [data, total] = await this.prisma.$transaction([
      this.prisma.transaction.findMany({
        where,
        orderBy: { occurredAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.transaction.count({ where }),
    ]);

    return { data, total, page, limit };
  }

  async recent(userId: string, limit: number) {
    return this.prisma.transaction.findMany({
      where: { userId },
      orderBy: { occurredAt: 'desc' },
      take: limit,
    });
  }

  async monthlySummary(userId: string, year: number, month: number) {
    const { start, end } = this.monthRange(year, month);

    const rows = await this.prisma.transaction.groupBy({
      by: ['type'],
      where: { userId, occurredAt: { gte: start, lt: end } },
      _sum: { amountCents: true },
    });

    const totalIncome =
      rows.find((r) => r.type === 'income')?._sum.amountCents ?? 0;
    const totalExpense =
      rows.find((r) => r.type === 'expense')?._sum.amountCents ?? 0;
    const balance = totalIncome - totalExpense;

    // 计算上月结余用于环比
    const prev = month === 1
      ? { year: year - 1, month: 12 }
      : { year, month: month - 1 };
    const prevRange = this.monthRange(prev.year, prev.month);
    const prevRows = await this.prisma.transaction.groupBy({
      by: ['type'],
      where: { userId, occurredAt: { gte: prevRange.start, lt: prevRange.end } },
      _sum: { amountCents: true },
    });
    const prevIncome =
      prevRows.find((r) => r.type === 'income')?._sum.amountCents ?? 0;
    const prevExpense =
      prevRows.find((r) => r.type === 'expense')?._sum.amountCents ?? 0;
    const prevBalance = prevIncome - prevExpense;

    const changePercent =
      prevBalance !== 0
        ? Math.round(((balance - prevBalance) / Math.abs(prevBalance)) * 100)
        : null;

    return { year, month, totalIncome, totalExpense, balance, changePercent };
  }

  async categoryStats(
    userId: string,
    year: number,
    month: number,
    type: 'income' | 'expense',
  ) {
    const { start, end } = this.monthRange(year, month);

    const rows = await this.prisma.transaction.groupBy({
      by: ['categoryId'],
      where: {
        userId,
        type: type as TransactionType,
        occurredAt: { gte: start, lt: end },
      },
      _sum: { amountCents: true },
      _count: { id: true },
      orderBy: { _sum: { amountCents: 'desc' } },
    });

    const grandTotal = rows.reduce(
      (acc, r) => acc + (r._sum.amountCents ?? 0),
      0,
    );

    return rows.map((r) => ({
      categoryId: r.categoryId,
      total: r._sum.amountCents ?? 0,
      count: r._count.id,
      percentage: grandTotal > 0 ? (r._sum.amountCents ?? 0) / grandTotal : 0,
    }));
  }

  private monthRange(year: number, month: number) {
    const start = new Date(year, month - 1, 1);
    const end = new Date(year, month, 1);
    return { start, end };
  }
}
