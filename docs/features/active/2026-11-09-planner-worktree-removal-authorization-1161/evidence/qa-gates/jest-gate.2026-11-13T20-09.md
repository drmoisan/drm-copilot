# Final Jest gate ([P4-T5])

Timestamp: 2026-11-13T20-09
Command: sh SCRATCH/issue-1161-jest.sh (in `extensions/drm-copilot`: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`, normal Jest workers; per-file figures read from `extensions/drm-copilot/coverage/lcov.info`)
EXIT_CODE: 0
Output Summary: Test Suites 342 passed of 342; Tests 5546 passed, 0 failed; no coverage-threshold failure (the run exits 0 with the per-file `coverageThreshold` entries of `jest.config.cjs` enforced). Repo-wide: lines 97.18% (64207/66073), branches 93.95% (9845/10479); baseline lines 97.15%, branches 93.87%. `src/lib/validate/epic-planner-state-planner-worktrees.ts`: lines 100.00% (172/172), branches 100.00% (44/44), enforced by its own entry `{ lines: 85, branches: 75 }`. `src/lib/validate/epic-planner-state-core.ts`: lines 100.00% (499/499), branches 96.85% (123/127); baseline lines 100.00% (495/495), branches 96.85% (123/127).

## Per-file comparison with the Phase 0 baseline

Baseline: `evidence/baseline/jest-gate.2026-11-10T03-38.md`.

| File | Baseline line | Final line | Baseline branch | Final branch | Thresholds 85% / 75% | No drop |
| --- | --- | --- | --- | --- | --- | --- |
| src/lib/validate/epic-planner-state-planner-worktrees.ts | new file | 100.00% (172/172) | new file | 100.00% (44/44) | PASS | n/a |
| src/lib/validate/epic-planner-state-core.ts | 100.00% (495/495) | 100.00% (499/499) | 96.85% (123/127) | 96.85% (123/127) | PASS | PASS |
| Repo-wide | 97.15% | 97.18% | 93.87% | 93.95% | PASS | PASS |

The four uncovered branches of `epic-planner-state-core.ts` are the same four as the baseline; the added import and call add four covered lines and no branch.
