# TypeScript lcov Coverage (Issue #543, PA-1 remediation)

Timestamp: 2026-10-10T08-42
Command: cd extensions/drm-copilot && node run-jest.cjs --coverage --coverageReporters=lcov --coverageReporters=text --coverageReporters=text-summary
EXIT_CODE: 0
Output Summary:
- `Test Suites: 265 passed, 265 total`
- `Tests:       3951 passed, 3951 total` (no failed test)
- text-summary `Lines        : 97.23% ( 51064/52517 )`
- text-summary `Branches     : 92.01% ( 7516/8168 )`
- text table row (verbatim): `  epic-planner-state-core.ts                                |   98.31 |     93.8 |     100 |   98.31 | 69-70,75-76,78-79,273-274`
- Exit 0 also shows every configured `coverageThreshold` entry in `jest.config.cjs` is met.
- The lcov file `extensions/drm-copilot/coverage/lcov.info` exists (gitignored tool output; not committed). Section details follow.

## lcov file

- Glob `extensions/drm-copilot/coverage/lcov.info`: listed (pre-run state was absent, see `evidence/remediation-baseline/lcov-pre-run-state.2026-10-10T08-41.md`).
- Command: `ls -l --time-style=long-iso extensions/drm-copilot/coverage/lcov.info`, exit 0.
- Line printed: `-rw-r--r-- 1 DanMoisan 197121 712929 2026-10-10 08:42 extensions/drm-copilot/coverage/lcov.info`
- Repository-relative path: `extensions/drm-copilot/coverage/lcov.info`
- Size: 712929 bytes (greater than 0).
- Write time: 2026-10-10 08:42 (not earlier than the P1-T1 Timestamp minute 08-42).

## per-file lcov values

- Record located by Grep `SF:.*epic-planner-state-core\.ts` in lcov.info: exactly one match, line 48368: `SF:src\lib\validate\epic-planner-state-core.ts` (repository-relative tail `extensions/drm-copilot/src/lib/validate/epic-planner-state-core.ts`). The record spans lcov.info lines 48368 to 48982 (`end_of_record`).
- `LF:474` (line 48865), `LH:466` (line 48866)
- `BRF:113` (line 48980), `BRH:106` (line 48981)
- DERIVED_LINES = LH / LF x 100 = 466 / 474 x 100 = 98.3122, rounded 98.31
- DERIVED_BRANCH = BRH / BRF x 100 = 106 / 113 x 100 = 93.8053, rounded 93.81
- Text-table values from the P1-T1 run: `% Lines` 98.31, `% Branch` 93.8.
- Absolute difference, lines: |98.31 - 98.31| = 0.00 (unrounded 0.0022). Branches: |93.81 - 93.8| = 0.01 (unrounded 0.0053). Neither exceeds 0.01.

## added-line hits

Records from lcov.info lines 48834 to 48836, verbatim:
- `DA:444,46`
- `DA:445,42`
- `DA:446,42`

All three lines are present (none absent) and each has a hit count greater than 0. The lines are the added condition `if (!requireLaunchPaths || "topology_receipt" in value) {` (444), its body (445), and its closing brace (446).

## verdict

- DERIVED_LINES >= 85: 98.31 vs 85, PASS
- DERIVED_BRANCH >= 75: 93.81 vs 75, PASS
- DERIVED_LINES >= 98.3 (BASELINE_LINES): 98.31 vs 98.3, PASS
- DERIVED_BRANCH >= 93.57 (BASELINE_BRANCH): 93.81 vs 93.57, PASS
- Repo-wide text-summary beside the floors: Lines 97.23% (floor 85), Branches 92.01% (floor 75).
- No source, test, or configuration file was edited by this plan.
