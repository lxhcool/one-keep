import {
  IsEnum,
  IsInt,
  IsISO8601,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from 'class-validator';
import { Transform } from 'class-transformer';

export enum TransactionTypeEnum {
  income = 'income',
  expense = 'expense',
}

const VALID_CATEGORIES = ['food', 'transport', 'shopping', 'salary', 'other'];

export class CreateTransactionDto {
  @IsEnum(TransactionTypeEnum, { message: 'type 必须为 income 或 expense' })
  type!: TransactionTypeEnum;

  @IsString()
  @Transform(({ value }: { value: string }) => value.toLowerCase())
  categoryId!: string;

  @IsInt({ message: 'amountCents 必须为整数' })
  @Min(1, { message: 'amountCents 必须大于 0' })
  amountCents!: number;

  @IsString()
  @MaxLength(50)
  title!: string;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  note?: string;

  @IsISO8601({}, { message: 'occurredAt 必须为 ISO 8601 格式' })
  occurredAt!: string;
}
