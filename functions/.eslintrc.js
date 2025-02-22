module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2018,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", { "allowTemplateLiterals": true }],
    "max-len": ["warn", { "code": 120 }], // Allow longer lines (default is 80)
    "indent": ["error", 2], // Enforce 2-space indentation
    "object-curly-spacing": ["error", "always"], // Ensure spaces inside {}
    "comma-dangle": ["error", "always-multiline"], // Require trailing commas in objects/arrays
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
