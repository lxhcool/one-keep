export const registerSchema = {
  body: {
    type: "object",
    required: ["email", "password", "name"],
    properties: {
      email: { type: "string", format: "email" },
      password: { type: "string", minLength: 6 },
      name: { type: "string", minLength: 1, maxLength: 50 },
    },
  },
} as const;

export const loginSchema = {
  body: {
    type: "object",
    required: ["email", "password"],
    properties: {
      email: { type: "string", minLength: 1 },
      password: { type: "string", minLength: 1 },
    },
  },
} as const;
