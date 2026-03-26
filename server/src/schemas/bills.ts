export const billsListSchema = {
  querystring: {
    type: "object",
    properties: {
      month: { type: "string", pattern: "^\\d{4}-\\d{2}$" },
      filterType: { type: "string", enum: ["all", "expense", "income"], default: "all" },
      query: { type: "string" },
      cursor: { type: "string" },
      pageSize: { type: "integer", minimum: 1, maximum: 100, default: 20 },
    },
  },
} as const;
