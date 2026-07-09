# TypeScript Coverage — extensions/drm-copilot (Issue #305, BLOCKING-2)

Timestamp: 2026-07-04T15-06
Working directory: extensions/drm-copilot

Command: npm run test:coverage
  (node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary)
EXIT_CODE: 0

Output Summary (whole-extension text-summary):
- Statements : 96.75% (29855/30855)
- Branches   : 88.27% (3803/4308)
- Functions  : 87.37% (851/974)
- Lines      : 96.75% (29855/30855)
- Artifact produced: extensions/drm-copilot/coverage/lcov.info (405 KB)
- Test Suites: 123 passed / 123; Tests: 1473 passed / 1473.

## Threshold scoping note (plan P2-T2 vs delegation guidance)

The plan text calls for a coverageThreshold of lines:85 / branches:75. The delegation
prohibits a GLOBAL Jest coverageThreshold that would fail the run on pre-existing untested
code outside this feature's changed set. Reconciliation: coverage is measured across ALL
production `src/**` files (no runtime path excluded, per general-unit-test.md), and the
85/75 threshold is verified per-changed-file via lcov extraction rather than via a global
Jest gate. A per-changed-file `coverageThreshold` block (no `global` key) is added in the
final config so only the changed non-type-only files are gated. The whole extension is not
gated on unrelated legacy coverage.

## Per-Changed-File Coverage (source: coverage/lcov.info)

| Changed file | Lines% (LH/LF) | Branches% (BRH/BRF) | Verdict |
|---|---|---|---|
| src/lib/validate/orchestrator-state-core.ts | 97.31% (471/484) | 91.03% (71/78) | PASS |
| src/lib/validate/orchestration-artifacts.ts | 100.00% (205/205) | 97.67% (42/43) | PASS |
| src/lib/validate/validate-orchestration-service-call.ts | 100.00% (95/95) | 85.71% (6/7) | PASS |
| src/lib/validate/build-validate-orchestration-service-call-input.ts | 100.00% (46/46) | 33.33% (1/3) | BELOW branch threshold — remediation below |
| src/repo-automation-service.ts | 98.38% (487/495) | 88.89% (40/45) | PASS |
| src/mcp-repo-automation-tool-definitions.ts | 100.00% (452/452) | n/a (0 branches) | PASS (definition/data module, no branches) |
| src/mcp-tool-definitions.ts | 100.00% (418/418) | n/a (0 branches) | PASS (definition/data module, no branches) |
| src/mcp-tool-inputs.ts | 93.15% (449/482) | 90.32% (56/62) | PASS |

Files with 0 branches (`mcp-repo-automation-tool-definitions.ts`, `mcp-tool-definitions.ts`)
are tool-definition/data modules with no branching logic; the branch threshold is not
applicable and their line coverage is 100%.

## Remediation (P2-T5)

The new sibling `build-validate-orchestration-service-call-input.ts` reports 100% lines but
33.33% branch coverage because the existing service-level tests exercise only one arm of the
two optional-field omit ternaries. A dedicated unit test at
`test/lib/validate/build-validate-orchestration-service-call-input.test.ts` is added to
exercise all combinations of `requireComplete` / `requireModelRouting` present vs absent.
See the appended re-run result below.

## Re-run after adding builder tests + scoped coverageThreshold

Timestamp: 2026-07-04T15-10
Command: npm run test:coverage
EXIT_CODE: 0
- Test Suites: 124 passed / 124 (added build-validate-orchestration-service-call-input.test.ts).
- Tests: 1478 passed / 1478 (added 5 tests).
- Whole-extension: Lines 96.75%, Branches 88.32%, Statements 96.75%, Functions 87.37%.

Updated per-changed-file coverage (source: coverage/lcov.info):

| Changed file | Lines% | Branches% | Verdict |
|---|---|---|---|
| src/lib/validate/orchestrator-state-core.ts | 97.31% (471/484) | 91.03% (71/78) | PASS |
| src/lib/validate/orchestration-artifacts.ts | 100.00% (205/205) | 97.67% (42/43) | PASS |
| src/lib/validate/validate-orchestration-service-call.ts | 100.00% (95/95) | 85.71% (6/7) | PASS |
| src/lib/validate/build-validate-orchestration-service-call-input.ts | 100.00% (46/46) | 100.00% (5/5) | PASS (was 33.33%; gap closed) |
| src/repo-automation-service.ts | 98.38% (487/495) | 88.89% (40/45) | PASS |
| src/mcp-repo-automation-tool-definitions.ts | 100.00% (452/452) | n/a (0 branches) | PASS |
| src/mcp-tool-definitions.ts | 100.00% (418/418) | n/a (0 branches) | PASS |
| src/mcp-tool-inputs.ts | 93.15% (449/482) | 90.32% (56/62) | PASS |

No-regression on changed lines: the Phase 1 extraction preserved behavior (1473 -> 1478 tests,
all passing) and every changed file is at or above 85% line / 75% branch. The scoped
per-changed-file `coverageThreshold` (no `global` key) is enforced and the run exits 0.

COVERAGE_GATE: PASS

