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

## D6 — Codex variant generator rewrites six pack manifests with CRLF line endings

- Task ID: P6-T14.
- Expected: after `poetry run python -m scripts.dev_tools.generate_codex_agent_variants`, the status listing of `.codex/agents` and `extensions/drm-copilot/resources/codex-and-agents-customizations` names exactly twelve paths, each containing `feature-reviewer`; "any other path fails the task".
- Observed: the listing immediately after the generator also named the six files under `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/` (`core.json`, `csharp-legacy.json`, `csharp-modern.json`, `powershell.json`, `python.json`, `typescript.json`). `git ls-files --eol` reported `i/lf w/crlf` for each; `git diff --numstat` listed no line for them; `git diff --exit-code --quiet HEAD -- <pack-manifests>` exited 0. The generator re-serializes the manifests on Windows with platform line endings; the content is unchanged.
- Resolution (micro-action inside P6-T14): the six manifests were restored to their committed LF bytes with `git checkout -- extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests`. The re-listed status names exactly the twelve `feature-reviewer` paths. All three listings are recorded in `evidence/other/codex-variants-regenerated.md`. No generator, manifest content, or hook file was edited.
- Amendment applied: the P6-T14 acceptance is evaluated on the status listing taken after the line-ending restoration; a manifest entry whose only difference is CRLF in the working copy (no `--numstat` line, `git diff --exit-code` 0) is not treated as a content path. No plan text is edited.

## D7 — B10 test file committed at its batch boundary before P6-T30

- Task ID: P6-T30.
- Expected: one pathspec commit naming the fifteen documents, their fifteen bundle copies, the twelve `feature-reviewer*.toml` files, and `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py`.
- Observed: the caller's execution contract requires a commit and push at every batch boundary, so the B10 test file was committed with the P6-T1 to P6-T3 evidence in 8d56c122. The P6-T30 pathspec commit still names the test file; it carries no further change in that commit. The P6-T30 acceptance (`git status --porcelain -- .agents .claude .codex extensions/drm-copilot/resources tests` prints nothing after the commit) is unaffected. This is the same pattern as D2.

## D8 — Phase 7 checks include the TypeScript split module (follows D4)

- Task IDs: P7-T12 (change-set classification), P7-T14 (final line counts).
- Expected: P7-T12 permits "`extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation.ts` (and the P4-T4 split file)"; P7-T14 measures "every production and test file created or edited (the P7-T12 set excluding documents, fixtures, and `.toml` files)". Neither task names `orchestrator-state-remediation-accounting.ts` literally.
- Observed: the P4-T4 split branch applied (D4), so `extensions/drm-copilot/src/lib/validate/orchestrator-state-remediation-accounting.ts` exists (`A` in the P7-T12 listing, 221 lines).
- Adjustment applied: P7-T12 classifies the file under the "P4-T4 split file" allowance (`evidence/other/scope-change-set.md`), and P7-T14 measures it as a created production file (`evidence/other/line-counts-final.md`, 221 lines, at or below 500). P7-T13's file list names test files only and needs no adjustment; P7-T9 and P7-T10 enumerate excluded files and need none. P7-T14 also excludes `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` as JSON configuration, not production or test code. No plan text is edited.

## D9 — Full Python suite found two pins invalidated by the Phase 6 document edits

- Task ID: P8-T5 (loop iteration 1).
- Expected: `EXIT_CODE: 0` and `0 failed` (P0-T34 recorded no failures).
- Observed: `2 failed, 6294 passed, 6 skipped`. Both failures are in `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`, a suite that no Phase 6 or Phase 7 task ran:
  - `test_orchestrate_skill_section_states_its_required_obligations[merge-conflict-exhaustion-and-f8-handoff]`: `## Per-Item Merge-Conflict Handling is missing required text: with the cap of 3`. P6 rewrote step 3 of that section in `.claude/skills/parallel-orchestrate/SKILL.md` to the `remediation_loop.completed_attempts` wording, which removed the pinned phrase.
  - `test_frozen_epic_surface_matches_pinned_baseline_digest[.claude/skills/epic-orchestrate/SKILL.md-9bff54a4...]`: the digest moved to `03f95bfb9d046bc3fb6c94c0f2844369a56bee9307ca5a8c96f7ab8341a13719` because P6 rewrote steps 4 and 5 of the epic skill's merge-conflict procedure.
- Resolution (fix in scope, single test-support file): after the Python pre-fix reset (`evidence/other/batch-budget-reset-qa-1.md`, OD-484-2), `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` was edited: (1) the epic-skill digest was re-baselined to the new value with a `RE-BASELINED by issue #484` comment, following the file's documented convention (issues #673, #663, #762, #659); the agent digest is unchanged; (2) the `MERGE_CONFLICT_FRAGMENTS` entry `with the cap of 3` was replaced by `the child halts after three completed attempts`, the sentence P6 wrote in the same step, so the section is still required to state the three-attempt cap. No document, hook, or production file changed. The suite then passed (`36 passed`). The file is a test file outside the P7-T12 change set recorded at 1162ab0a, so it is an addition to that set; it is 370 lines.
- The Python loop restarts from P8-T1 (iteration 2).
