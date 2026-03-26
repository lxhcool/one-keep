export const createTransactionSchema = {
  body: {
    type: "object",
    required: ["title", "amount", "direction", "categoryId", "occurredAt"],
    properties: {
      title: { type: "string", minLength: 1, maxLength: 100 },
      amount: { type: "number", exclusiveMinimum: 0 },
      direction: { type: "string", enum: ["expense", "income"] },
      categoryId: { type: "string", minLength: 1 },
      occurredAt: { type: "string", format: "date-time" },
      note: { type: "string", maxLength: 500 },
      merchant: { type: "string", maxLength: 100 },
    },
  },
} as const;

export const updateTransactionSchema = {
  params: {
    type: "object",
    required: ["id"],
    properties: {
      id: { type: "string" },
    },
  },
  body: {
    type: "object",
    properties: {
      title: { type: "string", minLength: 1, maxLength: 100 },
      amount: { type: "number", exclusiveMinimum: 0 },
      direction: { type: "string", enum: ["expense", "income"] },
      categoryId: { type: "string", minLength: 1 },
      occurredAt: { type: "string", format: "date-time" },
      note: { type: "string", maxLength: 500 },
      merchant: { type: "string", maxLength: 100 },
    },
  },
} as const;

export const deleteTransactionSchema = {
  params: {
    type: "object",
    required: ["id"],
    properties: {
      id: { type: "string" },
    },
  },
} as const;
