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
      code: { type: "string", minLength: 6, maxLength: 6, pattern: "^[0-9]{6}$" },
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

export const meSchema = {} as const;

export const sendCodeSchema = {
  body: {
    type: "object",
    additionalProperties: false,
    required: ["email"],
    properties: {
      email: { type: "string", format: "email" },
    },
  },
} as const;

export const verifyCodeSchema = {
  body: {
    type: "object",
    additionalProperties: false,
    required: ["email", "code"],
    properties: {
      email: { type: "string", format: "email" },
      code: { type: "string", minLength: 6, maxLength: 6, pattern: "^[0-9]{6}$" },
    },
  },
} as const;
