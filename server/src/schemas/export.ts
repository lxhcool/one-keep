export const exportDataSchema = {
  querystring: {
    type: "object",
    properties: {
      startMonth: { type: "string", pattern: "^\\d{4}-\\d{2}$" },
      endMonth: { type: "string", pattern: "^\\d{4}-\\d{2}$" },
    },
  },
};
