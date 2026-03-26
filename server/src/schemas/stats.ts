export const statsOverviewSchema = {
  querystring: {
    type: "object",
    required: ["month"],
    properties: {
      month: { type: "string", pattern: "^\\d{4}-\\d{2}$" },
      metricType: { type: "string", enum: ["expense", "income"] },
    },
  },
} as const;
