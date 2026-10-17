import eslint from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  {
    files: ["src/**/*.ts", "test/**/*.ts"],
    languageOptions: {
      parserOptions: {
        project: false,
      },
    },
    rules: {
      "no-console": "off",
    },
  },
  {
    // CommonJS configuration and build scripts (for example jest.config.cjs)
    // run under Node; declare the module system and the Node globals they use.
    files: ["**/*.cjs"],
    languageOptions: {
      sourceType: "commonjs",
      globals: {
        module: "writable",
        require: "readonly",
        __dirname: "readonly",
        process: "readonly",
      },
    },
  },
  {
    ignores: ["out/**", "node_modules/**"],
  },
);
