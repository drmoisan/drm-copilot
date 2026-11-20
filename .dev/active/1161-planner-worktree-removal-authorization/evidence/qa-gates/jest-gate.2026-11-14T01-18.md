# Final Jest gate ([P2-T4], remediation cycle 1)

Timestamp: 2026-11-14T01-18
Command: sh SCRATCH/issue-1161-jest.sh final (in `extensions/drm-copilot`: `node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text-summary`, normal Jest workers; `coverage/lcov.info` copied to SCRATCH/issue-1161-jest-final.lcov)
EXIT_CODE: 0
Output Summary: Test Suites 342 passed of 342; Tests 5554 passed, 0 failed; no coverage-threshold failure. Repo-wide: lines 97.17% (64214/66080), branches 93.94% (9845/10479). `src/lib/validate/epic-planner-state-planner-worktrees.ts` from `lcov.info`: lines 100.00% (LH 179 / LF 179), branches 100.00% (BRH 44 / BRF 44); no BRDA record with a zero count. Its `coverageThreshold` entry in `extensions/drm-copilot/jest.config.cjs` is unchanged (`git diff --stat` from CycleStartHead for that file is empty).

## Comparison with the Phase 0 baseline

Baseline: `evidence/remediation-baseline/jest-gate.2026-11-14T00-59.md`.

| Measure | Baseline | Final | Result |
|---|---|---|---|
| Failing tests | 0 | 0 | no new failing test |
| Passed | 5546 | 5554 | +8 new corpus rows |
| Module lines | 100.00% (172/172) | 100.00% (179/179) | PASS |
| Module branches | 100.00% (44/44) | 100.00% (44/44) | PASS |
| Repo-wide lines | 97.17% | 97.17% | no drop |
| Repo-wide branches | 93.94% | 93.94% | no drop |
