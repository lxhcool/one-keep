import type { FastifyInstance } from "fastify";
import { getPrisma } from "../utils/prisma.js";
import { toNumber } from "../utils/date.js";
import { exportDataSchema } from "../schemas/export.js";
import ExcelJS from "exceljs";

interface ExportQuery {
  startMonth?: string;
  endMonth?: string;
}

interface TransactionRow {
  occurredAt: string;
  direction: string;
  categoryName: string;
  title: string;
  amount: number;
  merchant: string;
  note: string;
}

function buildDateRange(startMonth?: string, endMonth?: string) {
  const now = new Date();
  const start = startMonth
    ? new Date(`${startMonth}-01T00:00:00.000Z`)
    : new Date(Date.UTC(now.getFullYear(), now.getMonth(), 1));

  let end: Date;
  if (endMonth) {
    const [y, m] = endMonth.split("-").map(Number);
    end = new Date(Date.UTC(y, m, 1)); // first day of next month
  } else {
    end = new Date(Date.UTC(now.getFullYear(), now.getMonth() + 1, 1));
  }

  return { start, end };
}

async function fetchTransactions(userId: string, startMonth?: string, endMonth?: string): Promise<TransactionRow[]> {
  const prisma = getPrisma();
  const { start, end } = buildDateRange(startMonth, endMonth);

  const items = await prisma.transaction.findMany({
    where: {
      userId,
      occurredAt: { gte: start, lt: end },
    },
    orderBy: { occurredAt: "desc" },
    include: {
      category: { select: { name: true } },
    },
  });

  return items.map((t) => ({
    occurredAt: t.occurredAt.toISOString().slice(0, 10),
    direction: t.direction === "expense" ? "支出" : "收入",
    categoryName: (t as any).category?.name ?? "未分类",
    title: t.title,
    amount: toNumber(t.amount),
    merchant: t.merchant ?? "",
    note: t.note ?? "",
  }));
}

const CSV_HEADERS = ["日期", "类型", "分类", "标题", "金额", "商家", "备注"];

function buildCsv(rows: TransactionRow[]): string {
  // BOM for Excel to recognize UTF-8
  const bom = "\uFEFF";
  const lines: string[] = [CSV_HEADERS.join(",")];

  for (const r of rows) {
    const cells = [
      r.occurredAt,
      r.direction,
      escapeCsvField(r.categoryName),
      escapeCsvField(r.title),
      r.amount.toFixed(2),
      escapeCsvField(r.merchant),
      escapeCsvField(r.note),
    ];
    lines.push(cells.join(","));
  }

  return bom + lines.join("\n");
}

function escapeCsvField(value: string): string {
  if (value.includes(",") || value.includes('"') || value.includes("\n")) {
    return `"${value.replace(/"/g, '""')}"`;
  }
  return value;
}

async function buildXlsx(rows: TransactionRow[]): Promise<Buffer> {
  const workbook = new ExcelJS.Workbook();
  workbook.creator = "OneKeep";
  workbook.created = new Date();

  const sheet = workbook.addWorksheet("记账数据");

  // Define columns
  sheet.columns = [
    { header: "日期", key: "occurredAt", width: 14 },
    { header: "类型", key: "direction", width: 8 },
    { header: "分类", key: "categoryName", width: 12 },
    { header: "标题", key: "title", width: 20 },
    { header: "金额", key: "amount", width: 12 },
    { header: "商家", key: "merchant", width: 18 },
    { header: "备注", key: "note", width: 24 },
  ];

  // Style header row
  const headerRow = sheet.getRow(1);
  headerRow.font = { bold: true, color: { argb: "FFFFFFFF" } };
  headerRow.fill = {
    type: "pattern",
    pattern: "solid",
    fgColor: { argb: "FF10B981" },
  };
  headerRow.alignment = { vertical: "middle", horizontal: "center" };
  headerRow.height = 28;

  // Add data rows
  for (const r of rows) {
    const row = sheet.addRow({
      occurredAt: r.occurredAt,
      direction: r.direction,
      categoryName: r.categoryName,
      title: r.title,
      amount: r.amount,
      merchant: r.merchant,
      note: r.note,
    });

    // Color-code expense/income
    const directionCell = row.getCell("direction");
    if (r.direction === "支出") {
      directionCell.font = { color: { argb: "FFFF6B6B" } };
    } else {
      directionCell.font = { color: { argb: "FF10B981" } };
    }

    // Number format for amount
    row.getCell("amount").numFmt = "#,##0.00";
  }

  // Freeze header row
  sheet.views = [{ state: "frozen", ySplit: 1 }];

  const buffer = await workbook.xlsx.writeBuffer();
  return Buffer.from(buffer);
}

export default async function exportRoutes(app: FastifyInstance) {
  // GET /api/export/csv
  app.get("/api/export/csv", { schema: exportDataSchema }, async (request, reply) => {
    const userId = request.userId;
    const { startMonth, endMonth } = request.query as ExportQuery;

    const rows = await fetchTransactions(userId, startMonth, endMonth);
    const csv = buildCsv(rows);

    const filename = `onekeep-export-${startMonth ?? "all"}-${endMonth ?? "all"}.csv`;

    reply
      .header("Content-Type", "text/csv; charset=utf-8")
      .header("Content-Disposition", `attachment; filename="${filename}"`)
      .send(csv);
  });

  // GET /api/export/xlsx
  app.get("/api/export/xlsx", { schema: exportDataSchema }, async (request, reply) => {
    const userId = request.userId;
    const { startMonth, endMonth } = request.query as ExportQuery;

    const rows = await fetchTransactions(userId, startMonth, endMonth);
    const buffer = await buildXlsx(rows);

    const filename = `onekeep-export-${startMonth ?? "all"}-${endMonth ?? "all"}.xlsx`;

    reply
      .header("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      .header("Content-Disposition", `attachment; filename="${filename}"`)
      .send(buffer);
  });
}
