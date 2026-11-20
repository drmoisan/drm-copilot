# Preflight Fixes (stage B, confirming preflight after the planner revision)

Timestamp: 2026-11-20T10-03
Plan: docs/features/active/2026-10-30-move-development-docs-to-dev-root-and-reserve-docs-for-production-1016/plan.2026-10-30T23-35.md
Signal: PREFLIGHT: REVISIONS REQUIRED (substantive defects are returned in the preflight output; they are not recorded here)

## Fixes

1. [P1-T6] | unanchored git diff (validator Warning G8) | `git diff --name-status` of the rehearsal tree became `git diff -M --name-status HEAD` with a `git status --porcelain` companion. The rehearsal repository's single commit is the pre-apply tree, so `HEAD` is the comparison the task text already named ("against its commit"); the porcelain companion makes a file the tool creates, such as `docs/README.md`, visible. Rules `E-TEST` and `E-PROD` read tracked test and production files, which the anchored diff covers.
2. [P1-T1] | evidence field consumed by a later task and not recorded | The acceptance now records the `DECISIONS` file name in `digest-comparison.<timestamp>.md`. [P1-T6] compares `DECISIONS` with "the decision file the newest `digest-comparison.*.md` names", which no artifact recorded, so the comparison had no source.
3. [P1-T6] | observation with no consequence | The module-load observation (`UNDER_REHEARSAL`) now states that an observation that does not hold stops with `BLOCKED: re-plan-required`. The acceptance already asserted that the gates load from the rehearsal tree; the fix states the branch taken when the assertion fails.
4. [P2-T4] | acceptance clause contradicting the task's own rule | "the only `ProcessReductionChain.Ledger.Tests.ps1` failure is `PRC-LEDGER-CHAIN-HOLDS`" became "the only ... failure, if any, is ...". The same task accepts a run A `FIX` test that passes as `PASSED`, and the preflight prototype with a fallback stand-in recorded `ProcessReductionChain.Ledger.Tests.ps1` 5 tests, 0 failures (SCRATCH `proto/artifacts/pester/pester-junit.xml`), so the clause could otherwise demand a failure that does not occur.
5. [P0-T4] | restated tool route with a relative operand | `npm --prefix extensions/drm-copilot ci` was replaced by `npm ci` on the item worktree's `extensions/drm-copilot` through the sibling-worktree route of the `execution-environment` skill (absolute `--prefix`). The executor's Bash working directory is the coordinator root, so the relative prefix would install into the coordinator checkout.

## Validation

Command: env -u VIRTUAL_ENV poetry -C <worktree> run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>
EXIT_CODE: 0
Output Summary: plan validation passed after the fixes, with no Warning (the G8 Warning on [P1-T6] is resolved); 40 tasks, 315 lines (legacy pair 40/400).
