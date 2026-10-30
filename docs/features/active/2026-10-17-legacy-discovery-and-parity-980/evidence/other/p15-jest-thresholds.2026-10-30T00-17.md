# P15-T20 — Per-file Jest thresholds for the ten unthresholded TypeScript files

Task: [P15-T20] Gate the ten unthresholded TypeScript files.
Branch: feature/legacy-discovery-and-parity-980
Issue: #980
File: `extensions/drm-copilot/jest.config.cjs`

## Change

Ten `coverageThreshold` entries with `lines: 85` and `branches: 75` were appended
to the map under one comment naming this cycle (`Issue #980, remediation cycle 1
(P15-T20)`). No existing entry was lowered or removed; the map has no `global`
key. The header comment of `jest.config.cjs` and of
`extensions/drm-copilot/test/discovery-coverage-contracts.test.ts` now state the
tiered file-size policy (below the 700-line advisory tier) instead of the
retired 500-line limit.

## Coverage run

Timestamp: 2026-10-30T00:17Z
Command: `node run-jest.cjs --coverage` (in extensions/drm-copilot, through SCRATCH/issue-980-p15-jest.sh)
EXIT_CODE: 0
Output Summary: `Test Suites: 321 passed, 321 total`; `Tests: 5175 passed, 5175 total`;
`Statements 97.01% (61336/63223)`, `Branches 93.61% (9327/9963)`, `Functions 91.79% (1835/1999)`,
`Lines 97.01% (61336/63223)`. No `coverage threshold` failure line appears in the output.

Per-file values for the ten gated files, read from `extensions/drm-copilot/coverage/lcov.info`
of this run (`LH/LF` and `BRH/BRF`); every value meets its gate:

| File | Lines | Branches |
| --- | --- | --- |
| ./src/lib/codex-native-converter/classifier-claude.ts | 100.00% (307/307) | 100.00% (40/40) |
| ./src/lib/codex-native-converter/classifier.ts | 98.88% (352/356) | 95.35% (41/43) |
| ./src/lib/codex-native-converter/inventory.ts | 98.10% (310/316) | 87.72% (50/57) |
| ./src/lib/codex-native-converter/mapping.ts | 99.19% (246/248) | 95.12% (39/41) |
| ./src/lib/codex-native-converter/pipeline-render.ts | 93.80% (348/371) | 77.78% (35/45) |
| ./src/lib/codex-native-converter/rewrites-rules.ts | 100.00% (349/349) | 100.00% (14/14) |
| ./src/lib/codex-native-converter/rewrites.ts | 100.00% (179/179) | 100.00% (19/19) |
| ./src/lib/validate/codex-topology-resolver.ts | 97.88% (323/330) | 95.16% (59/62) |
| ./src/lib/validate/orchestrator-state-codex-model-routing.ts | 95.71% (468/489) | 94.35% (117/124) |
| ./src/repo-automation-tool-names.ts | 100.00% (47/47) | 100.00% (0/0, zero-branch module) |

## Static gates on the two edited files

Timestamp: 2026-10-30T00:16Z
Command: `npx prettier --check jest.config.cjs test/discovery-coverage-contracts.test.ts`; `npx eslint test/discovery-coverage-contracts.test.ts`; `npm run typecheck`
EXIT_CODE: 0 (each)
Output Summary: `All matched files use Prettier code style!`; eslint printed no finding; `tsc -p ./ --noEmit && tsc -p tsconfig.jest.json --noEmit` completed with no error.

## Logical line count of jest.config.cjs

Timestamp: 2026-10-30T00:16Z
Command: `wc -l extensions/drm-copilot/jest.config.cjs`; `grep -c -v -E '^\s*$|^\s*//' extensions/drm-copilot/jest.config.cjs`
EXIT_CODE: 0
Output Summary: 531 physical lines; 419 logical lines (non-blank, non-comment). Both are
below the 700-line advisory tier named in the plan's file-size decision. The file crossed the
500-line guidance tier by the ten entries the user directed into it (531 physical lines), as
the plan's File-size decision records.
