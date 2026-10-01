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

## D4 — TypeScript split moves the validate-helper count across two files

- Task IDs: P4-T2 (acceptance search), P4-T4 (split branch).
- Expected: P4-T2's acceptance search `git grep -c -E "^(export )?function validate" -- extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts` prints a count of at least 4. P4-T4's split branch moves "the review-outcome checks and `deriveReviewVerdict`" into `orchestrator-state-remediation-accounting.ts`.
- Observed: P4-T2 was verified before the split at a count of 5. P4-T4 then measured 455 lines (above 450) and the split branch applied. After the split the same search prints 3 for `orchestrator-state-remediation.ts` (`validateRemediationCycle`, `validateRemediationAccounting`, `validateRemediationLoop`) and 2 for `orchestrator-state-remediation-accounting.ts` (`validateReviewOutcome`, `validateReviewOutcomes`), 5 in total. Mechanically necessary addition to the move: the vocabulary the moved code reads (`REVIEW_OUTCOMES_KEY`, `type ReviewVerdict`, `REVIEW_VERDICTS`, `REMEDIABILITY_CLASSES`, `NON_REMEDIABLE_CLASSES`, `HALT_CLASSES`) moved with it, so the new module does not import from the module that re-exports it; `orchestrator-state-remediation.ts` re-exports every one of those names, so the public import surface used by the tests is unchanged.
- Amendment applied: any later re-run of the P4-T2 search counts both files and expects a combined count of at least 4, the same way P3-T6 directs later Python coverage commands to add the split module. No plan text is edited.

## D5 — Accounting Pester test import order conflicts with the P5-T3 `-Force` import

- Task IDs: P5-T3 (production import line), P2-T9 (test `BeforeAll`), verified by P5-T11.
- Expected: P5-T3 adds `Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'OrchestratorStateRemediationAccounting.psm1') -Force -ErrorAction Stop` to `OrchestratorStateReceipts.psm1`, matching every sibling import in `.claude/lib/orchestrator-state`. P2-T9's `BeforeAll` imports `OrchestratorStateRemediationAccounting.psm1`, `OrchestratorStateUnconditional.psm1`, and `OrchestratorState.psm1`, each with `-Force`; P2-T9 lists the three modules but, unlike P1-T10, does not state "in this order".
- Observed: with the Phase 2 file importing the accounting module first, the subsequent `OrchestratorStateUnconditional.psm1` import reaches `OrchestratorStateReceipts.psm1`, whose `-Force` import of the accounting module removes and reloads it inside the receipts module scope; the removal also drops the test session's global command entry. A probe run of the accounting and parity suites returned `Passed=122 Failed=57`; all 57 failures were the direct entry-point cases (39 spec cases and 18 case variants) with "The term 'Get-OrchestratorStateRemediationAccountingError' is not recognized". The `InModuleScope` verdict cases and every parity case passed.
- Resolution (micro-action inside P5-T3): `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationAccounting.Tests.ps1` `BeforeAll` now imports `OrchestratorStateUnconditional.psm1`, then `OrchestratorState.psm1`, then `OrchestratorStateRemediationAccounting.psm1` (each still with `-Force`), with a three-line comment stating why. No assertion, case, or parameter name changed. The production import keeps the P5-T3 literal and the sibling `-Force` convention. Re-probe: `Passed=179 Failed=0`. It is a test file, so it does not count against the three-production-file batch budget (`ProdCap = 3` in the PowerShell batch-budget hook counts production files only). Because P5-T14's acceptance requires the B9 commit to list exactly eight paths, the test edit was committed on its own immediately before it (eadb31d5), and the B9 commit (3ee89bb8) names exactly the eight P5-T14 paths.
