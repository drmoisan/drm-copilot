# Phase 0 baseline — Jest coverage (extension)

Timestamp: 2026-11-17T18-50
Command: sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh jest-extension --coverage (the `jest-extension` suite of `config/test-execution-policy.json`, `node run-jest.cjs` in `extensions/drm-copilot/` with its normal parallel workers); figures read from `extensions/drm-copilot/coverage/lcov.info` (SCRATCH/issue-1028-lcov.ps1)
EXIT_CODE: 0
Output Summary: 351 suites passed of 351; 5881 tests passed of 5881; 0 failures; 16.397 s. The lcov totals over 261 files are line 97.25% (65742/67598) and branch 94.20% (10149/10774). Per file under `src/lib/codex-native-converter/`:
- `mapping.ts`: line 99.19% (246/248), branch 95.12% (39/41)
- `engine-pipeline.ts`: line 98.01% (295/301), branch 84.78% (39/46)
- `pipeline.ts`: line 100.00% (154/154), branch 100.00% (29/29)
- `pipeline-render.ts`: line 93.80% (348/371), branch 77.78% (35/45)
- `validation.ts`: line 99.46% (370/372), branch 92.59% (50/54)

All five are at or above 85% line and 75% branch, so [P2-T1] needs no added tests on account of the baseline.

Note: an earlier launcher run with the suite name `jest` ran the repository-root TypeScript project (354 suites, 5898 tests, all passed), not the extension. It is not this baseline and is recorded here only for completeness.
