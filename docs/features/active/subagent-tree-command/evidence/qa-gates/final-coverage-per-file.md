# Final QC — Per-File Coverage Breakdown (New Production Files)

Timestamp: 2026-07-05T23-15
Source: `coverage/lcov.info` from the `npm run test:coverage` run recorded in `final-test-coverage.md`.

## Per-file results

| File | Lines | Line % | Branches | Branch % | Threshold Gate |
|---|---|---|---|---|---|
| `src/lib/subagent-tree/types.ts` | 0/73 | 0.00% | 0/1 | 0.00% | Not gated — interface-only file, no executable behavior (see note below) |
| `src/lib/subagent-tree/transcript-parser.ts` | 127/129 | 98.45% | 27/28 | 96.43% | PASS (>= 85% / >= 75%) |
| `src/lib/subagent-tree/transcript-scanner.ts` | 155/155 | 100.00% | 26/26 | 100.00% | PASS (>= 85% / >= 75%) |
| `src/lib/subagent-tree/tree-assembler.ts` | 179/189 | 94.71% | 17/19 | 89.47% | PASS (>= 85% / >= 75%) |
| `src/lib/subagent-tree/tree-formatter.ts` | 33/33 | 100.00% | 3/3 | 100.00% | PASS (>= 85% / >= 75%) |
| `src/lib/subagent-tree/index.ts` | 28/28 | 100.00% | 2/2 | 100.00% | PASS (>= 85% / >= 75%) |
| `src/subagent-tree-command.ts` | 110/119 | 92.44% | 12/14 | 85.71% | PASS (>= 85% / >= 75%) |

## `types.ts` note

`types.ts` consists solely of `TreeNode`, `SubagentMeta`, `ScannedTranscript`, `ScannedSubagent`, and `ScannedSession` `interface` declarations — no functions, no statements, no runtime behavior. TypeScript interfaces compile away entirely; there are zero executable lines/branches for any test to exercise. This matches the documented exception in `.claude/rules/general-unit-test.md`: "Interface/type-only files with no executable behavior... may be omitted from coverage measurement... Such modules legitimately report 0% executable coverage." The file remains in `jest.config.cjs`'s `collectCoverageFrom` (not excluded from measurement, per `general-unit-test.md`'s Coverage Exclusion Policy); only its per-file `coverageThreshold` gate entry was omitted, since no test could ever raise it above 0%.

## Baseline comparison

- Baseline aggregate (from `baseline-test-coverage.md`): Statements 96.75%, Branches 88.31%, Functions 87.42%, Lines 96.75%.
- Post-change aggregate (from `final-test-coverage.md`): Statements 96.53%, Branches 88.42%, Functions 87.5%, Lines 96.53%.
- The small aggregate statement/line percentage decrease (96.75% -> 96.53%) is expected and consistent with adding the `types.ts` interface-only file (0 executable lines contributing to the denominator) to the measured file set; branch and function percentages both increased slightly. No pre-existing file's coverage regressed — the six executable new files (`transcript-parser.ts`, `transcript-scanner.ts`, `tree-assembler.ts`, `tree-formatter.ts`, `index.ts`, `subagent-tree-command.ts`) each individually exceed the 85% line / 75% branch gate.
