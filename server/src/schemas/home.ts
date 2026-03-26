export const homeSummarySchema = {
  querystring: {
    type: "object",
    required: ["month"],
    properties: {
      month: { type: "string", pattern: "^\\d{4}-\\d{2}$" },
    },
  },
} as const;
