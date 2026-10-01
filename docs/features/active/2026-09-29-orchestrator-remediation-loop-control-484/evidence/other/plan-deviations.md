# Plan Deviations (Issue #484)

Timestamp: 2026-10-01T21-30

Each entry records the task ID, what the plan expected, and what was observed.

## D1 — Delegation tooling unavailable for batches B1-B6

- Task IDs: P1-T2 through P1-T4 (B1), P1-T6 and P1-T7 (B2), P1-T9 and P1-T10 (B3), P2-T1 through P2-T3 (B4), P2-T6 and P2-T7 (B5), P2-T9 and P2-T10 (B6).
- Expected: the Delegation and Batch Plan table assigns each batch to a typed engineer (`python-typed-engineer`, `typescript-engineer`, `powershell-typed-engineer`).
- Observed: the executor session that ran Phases 1 and 2 exposes no subagent-delegation tool, so the batches could not be handed to the named engineers. The executor authored each batch directly, applying the same task text and constraints the delegation would have passed (at most 3 test files per batch, no temporary files in tests, 500-line limit, LF line endings for fixtures). Task scope, file paths, and order are unchanged.

## D2 — Back-compat capture committed at batch boundaries before P1-T15

- Task ID: P1-T15.
- Expected: one pathspec commit naming `tests/fixtures/orchestrator_state_remediation_loop_backcompat`, `tests/fixtures/orchestrator_state_remediation_loop_backcompat_expected.json`, and the three P1-T14 test files.
- Observed: the caller's execution contract requires a commit and push at every batch boundary, so the capture files were committed in the B1 (075394db), B2 (142a6802), and B3 (a2ac3c18) commits. The P1-T15 pathspec commit names the same five paths plus the P1-T12 to P1-T15 evidence and the plan; the five capture paths carry no further change in it. The P1-T15 acceptance (`git status --porcelain -- tests extensions/drm-copilot/test` prints nothing; a 40-character SHA recorded) is unaffected.

## D3 — Jest accounting suite fails at run time, not at compile time

- Task ID: P2-T8.
- Expected: the parenthetical states that "the accounting suite fails to compile on the missing exports; the parity suite fails on the new-error cases".
- Observed: `extensions/drm-copilot/tsconfig.jest.json` sets `isolatedModules: true`, so ts-jest transpiles without type diagnostics. The accounting suite loads, the nine missing exports are `undefined` at run time, and 100 cases fail (`TypeError: ... deriveReviewVerdict is not a function` and missing R5-R11 messages). The acceptance condition (`EXIT_CODE: 1`; `Test Suites:` line reports `2 failed`) is met as written. The compile-level failure is observable separately: `npx tsc -p tsconfig.jest.json --noEmit` reports nine `TS2305` errors in the accounting test file, one per missing export. No plan text was reinterpreted; only the parenthetical mechanism differs.
