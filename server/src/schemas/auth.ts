export const registerSchema = {
  body: {
    type: "object",
    additionalProperties: false,
    required: ["username", "email", "displayName", "password"],
    properties: {
      username: {
        type: "string",
        minLength: 3,
        maxLength: 20,
        pattern: "^[a-zA-Z0-9_]+$",
      },
      email: { type: "string", format: "email" },
      password: { type: "string", minLength: 6 },
      displayName: { type: "string", minLength: 1, maxLength: 20 },
    },
  },
} as const;

export const loginSchema = {
  body: {
    type: "object",
    additionalProperties: false,
    required: ["identifier", "password"],
    properties: {
      identifier: { type: "string", minLength: 1, maxLength: 100 },
      password: { type: "string", minLength: 1 },
    },
  },
} as const;
