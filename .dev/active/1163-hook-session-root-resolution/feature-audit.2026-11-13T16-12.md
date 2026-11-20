# Feature Audit: Hook Session-Root Resolution (Issue #1163)

**Audit Date:** 2026-11-13
**Branch:** `bug/hook-session-root-resolution-1163` @ `e5948a38dbe6ffaba2315f72ffb03f0057d84aa8` (PR #1170)
**Base:** `main`; merge base `1d62aa292161035aec8058e6c370f133e10a04db`
**Review type:** Re-audit, remediation cycle 2 (C1, CI failure); prior audits `feature-audit.2026-11-13T14-23.md` and `feature-audit.2026-11-13T15-02.md`.

## Scope and Baseline

- Scope: the full branch diff `1d62aa292..e5948a38d`, 170 files, read through `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` (collected at this head) and direct `git diff`.
- Baseline: the merge base on `main`; the Phase 0 artifacts under `evidence/baseline/`; and, for cycle 2, the artifacts under `evidence/remediation-baseline/` stamped 2026-11-13T15-46 to 15-51.
- Requirements source and work mode: `issue.md` marker `Work Mode: full-bug`, so the AC source is `spec.md` `## Acceptance Criteria` only.
- Cycle 2 evidence: `evidence/other/task-check.P1-T1` to `P1-T3` (2026-11-13T15-52 to 15-54) and `evidence/qa-gates/` files stamped 2026-11-13T15-59 to 16-05. Earlier evidence still describes the unchanged PowerShell, test, mirror, manifest, and Markdown files.
- Cycle change: the three npm lockfiles (`hono` 4.13.18, `@hono/node-server` 2.1.8). No other file outside the feature folder changed after the prior audit.

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
| AC-1 | PASS | Unchanged since the 2026-11-13T15-02 audit: both functions exported, nine parameters and the `ValidateSet`; `AgentTargetWorktree.Tests.ps1` (77 tests, 0 failed) carries the AST purity row. |
| AC-2 | PASS | `agent-target-worktree.Tests.ps1` (26 tests, 0 failed) asserts function-text identity and runs the shared rows; neither file changed in cycle 2. |
| AC-3 | PASS | Reviewer `git diff --name-status <merge base> HEAD` lists neither path nor either suite; both suites 83 tests, 0 failed in the cycle-1 gate. |
| AC-4 | PASS | Precedence rows pass; unchanged. |
| AC-5 | PASS | Coordinator-root rows pass; unchanged. |
| AC-6 | PASS | Restored-host rows pass; unchanged. |
| AC-7 | PASS | Prunable rows, including the two rows tightened in cycle 1 to require the full branch name, pass; unchanged in cycle 2. |
| AC-8 | PASS | Parity rows pass; unchanged. |
| AC-9 | PASS | Helper uses `Policy = 'FailClosedOnIdentity'` and envelope `cwd`; unchanged. |
| AC-10 | PASS | Six `TargetWorktree` suites carry not-derivable and ambiguous rows with a `FailIfCalled` probe; all pass. |
| AC-11 | PASS | No-identity rows present; converted rows carry the D4 reason comment. |
| AC-12 | PASS | `validate-orchestrator-output.ps1` absent from the diff; `ORCHESTRATOR_CHECKPOINT_FALLBACK:` rows unedited. |
| AC-13 | PASS | Claude completion-consistency rows pass. |
| AC-14 | PASS | Codex completion-consistency rows pass. |
| AC-15 | PASS | Claude file-size 801-line deny, 800-line allow, and relative-path rows pass. |
| AC-16 | PASS | Codex file-size rows pass. |
| AC-17 | PASS | Docs-role item-probe, unresolved-identity, and no-identity rows pass. |
| AC-18 | PASS | Docs-complete receipt-root rows pass. |
| AC-19 | PASS | Three optional parameters; rows M12 to M16 pass. |
| AC-20 | PASS | Rows B15 and B16 pass for both kinds. |
| AC-21 | PASS | Gate scripts pass `branch_name`; `RelativeRecord` rows pass. |
| AC-22 | PASS | `CleanupWorktreeManifest.psm1` and its suites absent from the diff. |
| AC-23 | PASS | Rooted runbook row and missing-runbook block row pass; no changed code writes a path. |
| AC-24 | PASS | `.claude/settings.json` and `.codex/config.toml` absent from the diff; cycle 2 changed no `package.json` and no hook registration. |
| AC-25 | PASS | Fail-before run: 54 failures, all issue #1163 rows; no decision changed in cycle 2. |
| AC-26 | PASS | No preimplementation gate path in the diff. |
| AC-27 | PASS | Mirrors identical and manifests list the new files (prior audit); no mirror or manifest changed in cycle 2. |
| AC-28 | PASS | Cycle 2 re-ran the push-down contracts within the 151-test selection (`pytest-contracts-final.2026-11-13T16-03.md`, 0 failed) and the generator check (`codex-generator-check-final.2026-11-13T16-04.md`, exit 0); the two runtime suites passed in the cycle-1 gate and no PowerShell file changed since. |
| AC-29 | PASS | Six brief copies identical; unchanged in cycle 2. |
| AC-30 | PASS | Rule note and identical mirror; unchanged. |
| AC-31 | PASS | No `.py` path in the diff (reviewer `--name-status` and `scope-invariants.2026-11-13T16-05.md`); the no-Python-invocation suite passes. |
| AC-32 | PASS | New suites use POSIX-style roots, no temporary file, no sleep; leak scan 0 failures. |
| AC-33 | PASS | One parallel Pester run (21666 tests, 0 failed) after the last PowerShell production commit; all 20 changed production files between 93.10% and 100%. Cycle 2 evidence is new append-only files using `SCRATCH` and `<item worktree>` placeholders, with no absolute path. |
| AC-34 | PENDING-CI | PR #1170 exists at head `e5948a38d`; its CI checks were queued or in progress at review time. The prior run at `ab6c96321` failed only the `NPM Audit Gate` jobs, which cycle 2 addresses; the reviewer's local re-run of the gate command exits 0 in all three manifests. Not a blocking finding; checked off at S9 by the item's orchestrator run. |

## Findings Outside the Criterion Text

- C1 (CI failure, blocking, contained): resolved in cycle 2. See `code-review.2026-11-13T16-12.md`.
- U1 (unrelated, non-blocking): root Prettier `format:check` fails on three pre-existing `tests/` fixtures that the branch does not touch; to be filed as a separate issue per OD-8.
- No new finding for this item.

## Summary

33 PASS, 1 pending CI, 0 FAIL. No blocking finding.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-11-09-hook-session-root-resolution-1163/spec.md`
- Total AC items: 34
- Checked off (delivered): 33
- Remaining (unchecked): 1
- Items remaining: AC-34 (CI-dependent): CI on the PR head is fully green, including the Linux hook-suite job.

## Acceptance Criteria Check-off

AC-1 to AC-33 were already checked in `spec.md` and are confirmed PASS at this head; this review makes no new check-off and unchecks no item. `spec.md` is unchanged since the prior review. AC-34 stays unchecked as pending CI and is checked off at S9 by the item's orchestrator run.
