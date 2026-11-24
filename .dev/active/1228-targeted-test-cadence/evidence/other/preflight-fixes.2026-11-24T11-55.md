# Preflight Fixes (remediation cycle 2, R2 preflight)

Timestamp: 2026-11-24T11-55
Plan: .dev/active/1228-targeted-test-cadence/remediation-plan.2026-11-24T10-50.md
Command: single-pass preflight review of the plan against the tree at the item worktree HEAD; plan validation through `mcp__drm-copilot__validate_orchestration_artifacts` (plan) and `env -u VIRTUAL_ENV poetry -C <item worktree> run python -m scripts.dev_tools.validate_orchestration_artifacts plan <plan>`
EXIT_CODE: 0
Output Summary: 12 trivial fixes in task text and the Pre-Mortem; no task added, removed, or reordered; both validators pass after the fixes (77 lines, 13 tasks). Pre-fix snapshot kept at SCRATCH/issue-1228-plan-snapshot-r2.md.

Classification note: fixes 4, 6, 7, 8, 9, and 10 add test rows or assertions for behavior that the same task already owns in the same file and the same decision (RD1, RD2), following the #1016 precedent that classified such missing rows as trivial. They are listed here so the orchestrator can review that classification.

## Fixes

1. Pre-Mortem `Mirror parity` | generated-file route | `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` and its Claude bundle copy are outputs of `scripts/harness-generation/Invoke-HarnessGeneration.ps1` (`Get-HarnessSkillMirrorFileMap` in `scripts/harness-generation/HarnessSkillMirror.psm1` renders every file of `.agents/skills/test-execution-policy/`). The bullet now states that the generator renders them from the `.agents` source and that the `.agents` bundle is a byte copy. The `Coverage` bullet wording follows.
2. [P1-T2] | generated-file route | The task edited the generated `.claude` launcher by hand and copied it outward, contrary to the plan's own standing rule that generated outputs change only through their generators. The task now edits the `.agents` source, runs the generator (write, then `-Check`) for the `.claude` copy and its bundle, and copies the source to its `.agents` bundle. The four copies, their equal `git hash-object` values, and every row are unchanged.
3. [P1-T7] | ledger labels | `## Files Changed` labels follow the entry's convention: the four hook sources and the `.agents` launcher as `source`, the `.claude` launcher as generated from the `.agents` launcher; revert step 3 gains the generated launcher and its bundle, step 2 keeps the hand-copied bundles.
4. [P1-T1] | discriminating row | The absent-text and non-JSON `RSCOPE-READ-*` rows also assert the write-time seam is not invoked, so the "seam invoked only after the record passes" rule (relied on by RD4) has a failing test.
5. [P1-T1] | disposition | `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (shared-module parse, 500-line cap, root/bundle byte identity of the Codex freshness file) named in the task check.
6. [P1-T2] | discriminating rows | The `-ForEach` table adds a lower-case `-testpath` for pester and a `-TestPath` word for the `bats` and `mstest` runners as full ("every other runner" rule); a row with an advancing clock seam asserts `started_utc` precedes and `completed_utc` follows the suite start, which the static clock of `Get-LauncherCase` cannot show.
7. [P1-T2] | disposition | The script-file entry row of `Invoke-TestSuite.Tests.ps1`, which does not use `Get-LauncherCase`, is named unchanged (its refusal path writes no record); the generator `-Check` exit is added to the acceptance.
8. [P1-T3] | null-path guard and existing discriminator | The record read is skipped when `Get-FeatureReviewRunScopeRecordPath` is `$null` (C#). A read with a `$null` path would bind `$null` to the mandatory `Path` of `Get-ArtifactFileContent` and turn F824-8 of `validate-feature-review-coverage.Issue824.Tests.ps1` (a C# change) into a validator error; that row is named as the existing test that fails if the guard is broken.
9. [P1-T3] | discriminating rows | `RSCOPE-HOOK-ITEM-ROOT-ACCEPTED` now uses the below-floor report and a record held only beneath the item root, so a session-root read would reject it; `RSCOPE-HOOK-STALE-SELECTION-BLOCKED` is added so the input finding's rule that freshness still applies to a selection report (remediation inputs F3 fix item 2, RD2) has a failing test.
10. [P1-T3] | isolation guard | The new suite dot-sources the hook, so `enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1` AC-4 and AC-6 discover it; the task now names its `Register-EpicStateBaselineMock` line and the interception-probe It, and the Discovery suite in the task check.
11. [P1-T3] and [P1-T4] | dispositions | Named unchanged: `hook-dependency-failure.Claude.Tests.ps1`, `hook-dependency-failure.SpecialCases.Tests.ps1`, `subagentstop-uncaught-error.Tests.ps1`, `hook-dependency-failure.Codex.Tests.ps1`; named passing: `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`. [P1-T4] skips the record read for a `$null` path and adds `RSCOPE-CODEX-CSHARP-FULL`, since no existing Codex entry row changes C#.
12. [P1-T5] | dispositions | The other suites that read `## Hook Execution Context` of the brief copies (four under `tests/scripts/claude-hooks`, four under `tests/scripts/claude-runtime`) are named unchanged and passing.

## Addendum (Timestamp: 2026-11-24T11-57)

13. [P1-T3] | row name | The stale-selection row added by fix 9 is renamed `RSCOPE-HOOK-STALE-SELECTION-REJECTED`, matching the `-REJECTED` suffix of its sibling rows; its assertion is unchanged.
