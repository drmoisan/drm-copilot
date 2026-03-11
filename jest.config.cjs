/** @type {import('jest').Config} */
module.exports = {
  testEnvironment: "node",
  testMatch: [
    "<rootDir>/tests/unit/**/*.test.ts",
    "<rootDir>/extensions/drm-copilot/test/**/*.test.ts",
  ],
  testPathIgnorePatterns: ["/node_modules/", "/out/"],
  moduleFileExtensions: ["ts", "tsx", "js", "jsx", "json", "node"],
  transform: {
    "^.+\\.tsx?$": ["ts-jest", { tsconfig: "<rootDir>/tsconfig.jest.json" }],
  },
  coverageProvider: "v8",
};
