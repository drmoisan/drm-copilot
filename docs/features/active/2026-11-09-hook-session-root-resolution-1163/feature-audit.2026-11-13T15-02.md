# Feature Audit: Hook Session-Root Resolution (Issue #1163)

**Audit Date:** 2026-11-13
**Branch:** `bug/hook-session-root-resolution-1163` @ `f4c42955364876622140605f693579a91ee91e82` (no PR exists yet)
**Base:** `main`; merge base `1d62aa292161035aec8058e6c370f133e10a04db`
**Review type:** Re-audit, remediation cycle 1 (light); prior audit `feature-audit.2026-11-13T14-23.md`.

## Scope and Baseline

- Scope: the full branch diff `1d62aa292..f4c429553`, 139 files, read through `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (generated 2026-11-13 14:58:07 UTC at this head) and direct `git diff`.
- Baseline: the merge base on `main`, and the Phase 0 artifacts `evidence/baseline/pester-parallel.2026-11-10T04-07.md`, `powershell-static.2026-11-10T03-19.md`, `pytest-contracts.2026-11-10T04-09.md`, `codex-generator-check.2026-11-10T04-10.md`, and `pre-change-context.2026-11-10T03-14.md`.
- Requirements source and work mode: `issue.md` marker `Work Mode: full-bug`, so the AC source is `spec.md` `## Acceptance Criteria` only.
- Final QA evidence of cycle 1: `evidence/regression-testing/fail-before.F1.2026-11-13T14-33.md`, `evidence/other/task-check.P0-T1.2026-11-13T14-36.md`, and `evidence/qa-gates/` files stamped 2026-11-13T14-38 to 2026-11-13T14-55. Earlier evidence (`fail-before.2026-11-11T04-47.md` and the 2026-11-13T13-55 to 14-12 gates) still describes the unchanged production files.
- Cycle change: `Resolve-AgentTargetWorktree` (module, Codex twin, two mirrors) and two `DetailPattern` values in `AgentTargetWorktree.Rows.Helpers.ps1`. No other production or test file changed after the prior audit.

## Acceptance Criteria Inventory

| ID | Criterion (abbreviated) | Source |
|---|---|---|
| AC-1 | Module exports two functions with the named parameters; AST purity test | `spec.md` |
| AC-2 | Codex twin function text byte-identical; shared rows run | `spec.md` |
| AC-3 | `HookTargetWorktree.psm1` and `hook-target-worktree.ps1` byte-unchanged; their suites pass unedited | `spec.md` |
| AC-4 | D2 precedence row per source | `spec.md` |
| AC-5 | Coordinator-root row set | `spec.md` |
| AC-6 | Restored-host row set | `spec.md` |
| AC-7 | Prunable exclusion; prunable-only branch not derivable with `git worktree repair` detail | `spec.md` |
| AC-8 | Parity with `Resolve-HookTargetWorktree` on non-prunable rows | `spec.md` |
| AC-9 | SubagentStop helper routes through the resolver; `-Target` default keeps today's rows | `spec.md` |
| AC-10 | Six hooks block on not-derivable and ambiguous rows without a probe | `spec.md` |
| AC-11 | No-identity rows keep the session-root fallback; converted rows record the reason | `spec.md` |
| AC-12 | `validate-orchestrator-output.ps1` unmodified; no-identity fallback rows unedited | `spec.md` |
| AC-13 | Claude completion-consistency allow, fail-before, unchanged rows | `spec.md` |
| AC-14 | Codex completion-consistency rows | `spec.md` |
| AC-15 | Claude file-size deny, allow, fail-before, unchanged rows | `spec.md` |
| AC-16 | Codex file-size rows | `spec.md` |
| AC-17 | Docs-role output rows | `spec.md` |
| AC-18 | Docs-complete receipt-root rows | `spec.md` |
| AC-19 | `Test-WorktreeRunRecordedPathMatchesTarget` new parameters and rows | `spec.md` |
| AC-20 | `Resolve-WorktreeRunTargetByRecord` host-moved rows | `spec.md` |
| AC-21 | Removal gates pass `branch_name`; three row kinds | `spec.md` |
| AC-22 | Cleanup manifest module unmodified; tests unedited | `spec.md` |
| AC-23 | Rooted `runbook_path` unchanged; missing runbook blocks; no absolute path persisted | `spec.md` |
| AC-24 | No configuration key or registration change | `spec.md` |
| AC-25 | Only D3, D4, D6 to D9 decisions change, each with a fail-before row | `spec.md` |
| AC-26 | Preimplementation gate files unmodified | `spec.md` |
| AC-27 | Mirrors byte-identical; manifests list the new files | `spec.md` |
| AC-28 | Push-down contracts, generator check, and two runtime suites pass | `spec.md` |
| AC-29 | Brief `## Hook Execution Context` content; six copies identical | `spec.md` |
| AC-30 | Restored-host rule note and identical mirror | `spec.md` |
| AC-31 | No Python file; no changed hook invokes Python | `spec.md` |
| AC-32 | In-memory POSIX roots, no temp files or waits; leak scan clean | `spec.md` |
| AC-33 | One parallel run passes; each changed production file at or above 85% lines; evidence append-only with no absolute path | `spec.md` |
| AC-34 | CI green on the PR head (CI-dependent) | `spec.md` |

## Acceptance Criteria Evaluation

| ID | Status | Evidence |
|---|---|---|
| AC-1 | PASS | Module read at head: `Export-ModuleMember` lists both functions; parameter block holds all nine names and the `ValidateSet`. `AgentTargetWorktree.Tests.ps1` (77 tests, 0 failed in the cycle gate) carries the AST purity row. |
| AC-2 | PASS | `agent-target-worktree.Tests.ps1` (26 tests, 0 failed) asserts function-text identity and runs the shared rows; reviewer read of both files shows the same function bodies. |
| AC-3 | PASS | Reviewer `git diff --stat <merge base> HEAD` on both paths and both suites: empty; both suites 83 tests, 0 failed. |
| AC-4 | PASS | Precedence rows in the shared row file; reviewer probe P5 (identity plus working directory) resolved by identity. |
| AC-5 | PASS | Coordinator-root rows pass; reviewer probe P3 resolved the item root with `Source = AgentWorkingDirectory`. |
| AC-6 | PASS | Restored-host rows pass; reviewer probe P1 resolved the live root with `StaleRegistration` holding the stale root, while `Resolve-HookTargetWorktree` returned `TARGET_WORKTREE_AMBIGUOUS`; probe P9 resolved the issue-only prompt to the new root. |
| AC-7 | PASS | Prunable rows pass in the cycle gate. Cycle 1 tightened the two prunable-only rows to require `branch 'bug/item'` before the stale root and `git worktree repair`; they failed before the fix (4 failures, observed `branch 'b'`) and pass after it. Reviewer probes R1, R2, R4, R5, R7 on both surfaces return `TARGET_WORKTREE_NOT_DERIVABLE` with the full branch, the stale root, and the remedy. |
| AC-8 | PASS | Parity rows over `Get-HookTargetWorktreeResolverRows` and `Get-HookTargetWorktreeIdentityRows` pass in the final gate. |
| AC-9 | PASS | Helper read at head: `Policy = 'FailClosedOnIdentity'` and envelope `cwd` as `AgentWorkingDirectory`; `-Target` defaults to `$null` and its rejection runs only when a reason code is present. |
| AC-10 | PASS | Six `TargetWorktree` suites carry not-derivable and ambiguous rows with a `FailIfCalled` probe; all pass; they failed in the fail-before run. |
| AC-11 | PASS | No-identity rows present in each suite; converted rows carry the D4 reason comment. |
| AC-12 | PASS | `validate-orchestrator-output.ps1` absent from the diff; the suite edit changes only the mocked collaborator in row H8 (resolver throw), with the reason recorded; the `ORCHESTRATOR_CHECKPOINT_FALLBACK:` rows are unedited. |
| AC-13 | PASS | `enforce-completion-consistency.TargetWorktree.Tests.ps1` rows pass; the allow row is among the fail-before failures. |
| AC-14 | PASS | Codex `enforce-completion-consistency-target-worktree.Tests.ps1` carries the same rows; all pass. |
| AC-15 | PASS | `enforce-file-size-limit.TargetWorktree.Tests.ps1` 801-line deny, 800-line allow, and relative-path rows pass; deny rows are fail-before failures. |
| AC-16 | PASS | Codex `enforce-file-size-limit-target-worktree.Tests.ps1` carries the same rows; all pass. |
| AC-17 | PASS | `validate-docs-role-output.TargetWorktree.Tests.ps1` item-probe, unresolved-identity, and no-identity rows pass. |
| AC-18 | PASS | Receipt-root Describe in `enforce-docs-complete-gate.Tests.ps1`: one-match, zero, several, and prunable-only rows pass. |
| AC-19 | PASS | Function read at head: three optional parameters; rows M12 to M16 pass; existing rows unedited. |
| AC-20 | PASS | Rows B15 and B16 in `WorktreeRunResolution.Record.Tests.ps1` pass for both kinds. |
| AC-21 | PASS | All three gate scripts pass `branch_name` (diff read); `RelativeRecord` suites carry host-moved allow, unresolvable-branch deny, and live-match rows; all pass. |
| AC-22 | PASS | `CleanupWorktreeManifest.psm1` and its suites absent from the diff. |
| AC-23 | PASS | Final gate: 'S2-9 returns a rooted runbook path unchanged' and the missing-runbook block row pass; no changed code writes a path. |
| AC-24 | PASS | `.claude/settings.json` and `.codex/config.toml` absent from the diff; no hook registration change. |
| AC-25 | PASS | Fail-before run: 54 failures, all issue #1163 rows; every other existing row passes in the final gate. |
| AC-26 | PASS | `git diff --name-only <merge base> HEAD` lists no preimplementation gate path. |
| AC-27 | PASS | Reviewer `cmp` of each changed source and mirror: identical; both manifests list the new files. |
| AC-28 | PASS | `pytest-contracts-final.2026-11-13T14-54.md` 198 passed; generator check exit 0; `hook-dependency-guard-completeness` (731) and `enforcement-hooks-no-python-invocation` (35) pass in the final gate. |
| AC-29 | PASS | Brief section names `Resolve-AgentTargetWorktree` (three occurrences), the precedence, prunable exclusion, `git worktree repair`, the adopters, and D9; the six copies share one blob id. |
| AC-30 | PASS | Rule note at line 413 of `.claude/rules/orchestrator-state.md`; mirror identical (`cmp`). |
| AC-31 | PASS | No `.py` path in the diff; the no-Python-invocation suite passes. |
| AC-32 | PASS | Reviewer read of the new suites: POSIX-style roots, no temporary file, no sleep; leak scan 0 failures. |
| AC-33 | PASS | One parallel run in cycle 1 (after the fix commit), 21666 tests, 0 failed; all 20 files between 93.10% and 100% (`pester-parallel-final.2026-11-13T14-54.md`; reviewer parse of the coverage XML for the repo total and the two F1 files); evidence files use `<item worktree>` and `SCRATCH` placeholders, no absolute path. |
| AC-34 | PENDING-CI | No PR exists yet, so no CI run exists at this head. Not a blocking finding; checked off at S9 by the item's orchestrator run. |


## Findings Outside the Criterion Text

- F1 (prior review, blocking, contained): resolved in cycle 1. The D3 detail names the full branch of the matching stale record on both surfaces; see `code-review.2026-11-13T15-02.md`.
- No new finding.

## Summary

33 PASS, 1 pending CI, 0 FAIL. No blocking finding.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-11-09-hook-session-root-resolution-1163/spec.md`
- Total AC items: 34
- Checked off (delivered): 33
- Remaining (unchecked): 1
- Items remaining: AC-34 (CI-dependent): CI on the PR head is fully green, including the Linux hook-suite job.

## Acceptance Criteria Check-off

AC-1 to AC-33 were already checked in `spec.md` with evidence and are confirmed PASS at this head; this review makes no new check-off and unchecks no item. `spec.md` is unchanged since the prior review. AC-34 stays unchecked as pending CI and is checked off at S9 by the item's orchestrator run.
