/** @type {import('jest').Config} */
module.exports = {
  testEnvironment: "node",
  testMatch: ["<rootDir>/test/**/*.test.ts"],
  testPathIgnorePatterns: ["/node_modules/", "/out/"],
  moduleFileExtensions: ["ts", "tsx", "js", "jsx", "json", "node"],
  transform: {
    "^.+\\.tsx?$": ["ts-jest", { tsconfig: "<rootDir>/tsconfig.jest.json" }],
  },
  coverageProvider: "v8",
  // Coverage is enabled via the `--coverage` CLI flag in the `test:coverage`
  // script; the default `test`/`test:unit` runs remain coverage-free.
  collectCoverage: false,
  // Measure every production source file. Per `.claude/rules/general-unit-test.md`
  // no production `src/**` runtime path may be excluded from coverage; only
  // TypeScript declaration files (no executable behavior) are omitted.
  collectCoverageFrom: ["src/**/*.ts", "!src/**/*.d.ts"],
  coverageReporters: ["lcov", "text-summary"],
  coverageDirectory: "<rootDir>/coverage",
  // Per-changed-file thresholds only (no `global` key). Per issue #305 the 85%
  // line / 75% branch gate applies to THIS feature's changed files, not to the
  // whole pre-existing extension; a global threshold would fail the run on
  // unrelated legacy coverage. Zero-branch definition modules report 100% branch
  // by convention and therefore satisfy the branch gate.
  coverageThreshold: {
    "./src/lib/validate/orchestrator-state-core.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/lib/validate/orchestration-artifacts.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/lib/validate/validate-orchestration-service-call.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/lib/validate/build-validate-orchestration-service-call-input.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/repo-automation-service.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/mcp-repo-automation-tool-definitions.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/mcp-tool-definitions.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/mcp-tool-inputs.ts": {
      lines: 85,
      branches: 75,
    },
  },
};
