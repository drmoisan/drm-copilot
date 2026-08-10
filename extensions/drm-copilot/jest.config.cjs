/** @type {import('jest').Config} */
module.exports = {
  testEnvironment: "node",
  testMatch: ["**/test/**/*.test.ts"],
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
    "./src/repo-automation-service-subagent-tree.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/repo-automation-execute-script.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/mcp-tool-inputs-subagent-tree.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/mcp-handlers/render-subagent-tree-handler.ts": {
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
    // No entry for "./src/lib/subagent-tree/types.ts": the file consists
    // solely of `interface` declarations with no executable behavior. Per
    // `.claude/rules/general-unit-test.md` ("Interface/type-only files with
    // no executable behavior... may be omitted from coverage measurement"),
    // this file legitimately reports 0% line/branch coverage under the v8
    // coverage provider (confirmed via `coverage/lcov.info`) and cannot be
    // brought above threshold by any test, since there is no runtime code to
    // exercise. It remains included in `collectCoverageFrom` (not excluded
    // from measurement) and is omitted only from the per-file threshold gate.
    "./src/lib/subagent-tree/transcript-parser.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/lib/subagent-tree/transcript-scanner.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/lib/subagent-tree/tree-assembler.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/lib/subagent-tree/tree-formatter.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/lib/subagent-tree/index.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/lib/subagent-tree/quick-pick-labels.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/lib/subagent-tree/session-transcript-resolver.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/subagent-tree-command.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/lib/subagent-tree/workspace-encoding.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/command-runtime.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/terminal-writer.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/runtime-detection.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/repo-automation-execute-discovery.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/mcp-tool-inputs-discovery.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/mcp-handlers/discovery-handlers.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/mcp-discovery-tool-definitions.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/discovery-command-registration.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/mcp-tools.ts": {
      lines: 85,
      branches: 75,
    },
    // No entry for "./src/repo-automation-service-contract.ts": the file
    // consists solely of `interface` and re-exported `type` declarations with
    // no executable behavior. Per `.claude/rules/general-unit-test.md`
    // ("Interface/type-only files with no executable behavior... may be omitted
    // from coverage measurement"), it legitimately reports 0% executable
    // coverage under the v8 provider and is omitted only from the per-file
    // threshold gate; it remains included in `collectCoverageFrom`.
    "./src/lib/validate/parallel-state-shared.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/lib/validate/parallel-state-structures.ts": {
      lines: 85,
      branches: 75,
    },
    // `parallel-state-records.ts` carries the record-level validators split out
    // of `parallel-state-structures.ts` to keep both modules under the 500-line
    // cap. It is production runtime code, so the coverage-exclusion policy in
    // `.claude/rules/general-unit-test.md` requires it to sit behind the same
    // per-file gate as the module it was split from.
    "./src/lib/validate/parallel-state-records.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/lib/validate/parallel-orchestrator-state-cohort-barrier.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/lib/validate/parallel-orchestrator-state-core.ts": {
      lines: 85,
      branches: 75,
    },
    "./src/lib/validate/parallel-planner-state-core.ts": {
      lines: 85,
      branches: 75,
    },
  },
};
