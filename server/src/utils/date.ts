import type { Decimal } from "@prisma/client/runtime/library";

/** 将 month 字符串 "2026-03" 转为当月起止时间 */
export function monthRange(month: string): { start: Date; end: Date } {
  const [year, mon] = month.split("-").map(Number);
  const start = new Date(year, mon - 1, 1);
  const end = new Date(year, mon, 1);
  return { start, end };
}

/** Decimal → number */
export function toNumber(val: Decimal): number {
  return Number(val);
}
