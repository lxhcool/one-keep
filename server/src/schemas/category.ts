const categoryTypeSchema = { type: "string", enum: ["expense", "income"] } as const;

export const listCategoriesSchema = {} as const;

export const createCategorySchema = {
  body: {
    type: "object",
    required: ["name", "icon", "type"],
    properties: {
      name: { type: "string", minLength: 1, maxLength: 20 },
      icon: { type: "string", minLength: 1, maxLength: 60 },
      type: categoryTypeSchema,
    },
  },
} as const;

export const updateCategorySchema = {
  params: {
    type: "object",
    required: ["id"],
    properties: {
      id: { type: "string", minLength: 1 },
    },
  },
  body: {
    type: "object",
    minProperties: 1,
    properties: {
      name: { type: "string", minLength: 1, maxLength: 20 },
      icon: { type: "string", minLength: 1, maxLength: 60 },
      type: categoryTypeSchema,
    },
  },
} as const;

export const reorderCategoriesSchema = {
  body: {
    type: "object",
    required: ["type", "categoryIds"],
    properties: {
      type: categoryTypeSchema,
      categoryIds: {
        type: "array",
        minItems: 1,
        uniqueItems: true,
        items: { type: "string", minLength: 1 },
      },
    },
  },
} as const;

export const deleteCategorySchema = {
  params: {
    type: "object",
    required: ["id"],
    properties: {
      id: { type: "string", minLength: 1 },
    },
  },
} as const;
