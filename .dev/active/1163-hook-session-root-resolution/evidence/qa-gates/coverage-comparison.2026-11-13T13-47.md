# Coverage Comparison (issue #1163, P8-T7)

Timestamp: 2026-11-13T13-47
Command: sh SCRATCH/issue-1163-changed-lines.sh <merge base> (pwsh 7: for each of the 20 files, `git diff -U0 <merge base> HEAD -- <file>` new-side line numbers, matched against the `<line>` records of the file's `<sourcefile>` in artifacts/pester/powershell-coverage.xml; a line counts as covered when `ci` is above 0)
EXIT_CODE: 0
Output Summary: Phase 0 baseline (evidence/baseline/pester-parallel.2026-11-10T04-07.md) compared with the final Pester gate (evidence/qa-gates/pester-parallel-final.2026-11-12T13-02.md). Repo-wide line coverage 95.80% -> 95.82% (+0.02). No per-file drop across the 18 existing files; every one of the 20 files is at or above 85%. Changed-line coverage across the 20 files: 287 of 289 executable changed lines covered (99.31%); the 2 uncovered lines are the default `WorktreeListInvoker` body of the two new resolver files, the single process call that the plan keeps out of every test path. Outcome: PASS (no remediation required).

## Inputs

- Merge base: `git merge-base origin/main HEAD` on the item worktree; `origin/main` resolved to the same commit, so the merge base is the head of `origin/main` at the time of the comparison.
- Coverage XML: artifacts/pester/powershell-coverage.xml in the item worktree, last written 2026-11-12 13:01Z, which is the end time recorded by pester-parallel-final.2026-11-12T13-02.md (started 12:36Z, ended 13:01Z). No tracked non-evidence file has changed since that run (the later head only adds evidence and plan check-offs).
- Baseline per-file values: pester-parallel.2026-11-10T04-07.md. Final per-file values: pester-parallel-final.2026-11-12T13-02.md.

## Repo-wide Line Coverage

| Run | Line % | Covered | Missed |
|---|---|---|---|
| Phase 0 baseline (P0-T3) | 95.80 | 37558 | 1645 |
| Final gate (P8-T2) | 95.82 | 37799 | 1647 |
| Delta | +0.02 | | |

## Existing Files (18): Baseline, Final, Delta

| File | P0-T3 % | P8-T2 % | Delta | >= 85% |
|---|---|---|---|---|
| `.claude/hooks/subagentstop-target-worktree.ps1` | 100.00 | 100.00 | 0.00 | yes |
| `.claude/hooks/validate-task-researcher-output.ps1` | 98.33 | 98.33 | 0.00 | yes |
| `.claude/hooks/validate-prd-feature-output.ps1` | 100.00 | 100.00 | 0.00 | yes |
| `.claude/hooks/validate-required-artifact-output.ps1` | 98.73 | 98.73 | 0.00 | yes |
| `.claude/hooks/validate-planner-output.ps1` | 99.55 | 99.55 | 0.00 | yes |
| `.claude/hooks/validate-executor-output.ps1` | 100.00 | 100.00 | 0.00 | yes |
| `.claude/hooks/validate-human-exception-runbook-output.ps1` | 93.10 | 93.10 | 0.00 | yes |
| `.claude/hooks/enforce-completion-consistency.ps1` | 95.33 | 95.60 | +0.27 | yes |
| `.codex/hooks/enforce-completion-consistency.ps1` | 100.00 | 100.00 | 0.00 | yes |
| `.claude/hooks/enforce-file-size-limit.ps1` | 100.00 | 100.00 | 0.00 | yes |
| `.codex/hooks/enforce-file-size-limit.ps1` | 100.00 | 100.00 | 0.00 | yes |
| `.claude/hooks/validate-docs-role-output.ps1` | 100.00 | 100.00 | 0.00 | yes |
| `.claude/hooks/enforce-docs-complete-gate.ps1` | 93.90 | 94.57 | +0.67 | yes |
| `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` | 100.00 | 100.00 | 0.00 | yes |
| `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | 100.00 | 100.00 | 0.00 | yes |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 94.92 | 95.12 | +0.20 | yes |
| `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` | 96.23 | 96.55 | +0.32 | yes |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 95.58 | 95.83 | +0.25 | yes |

## New Files (2): Final Value Against the 85% Threshold

| File | P8-T2 % | Covered | Missed | >= 85% |
|---|---|---|---|---|
| `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` | 98.70 | 76 | 1 | yes |
| `.codex/hooks/agent-target-worktree.ps1` | 98.65 | 73 | 1 | yes |

## Changed-Line Coverage (from the coverage XML)

Added or modified lines are the new-side lines of `git diff -U0 <merge base> HEAD`; executable lines are those that carry a `<line>` record in the XML.

| File | Changed lines | Executable | Covered | Missed | Changed-line % |
|---|---|---|---|---|---|
| `.claude/hooks/subagentstop-target-worktree.ps1` | 28 | 10 | 10 | 0 | 100.00 |
| `.claude/hooks/validate-task-researcher-output.ps1` | 1 | 1 | 1 | 0 | 100.00 |
| `.claude/hooks/validate-prd-feature-output.ps1` | 2 | 2 | 2 | 0 | 100.00 |
| `.claude/hooks/validate-required-artifact-output.ps1` | 1 | 1 | 1 | 0 | 100.00 |
| `.claude/hooks/validate-planner-output.ps1` | 1 | 1 | 1 | 0 | 100.00 |
| `.claude/hooks/validate-executor-output.ps1` | 2 | 2 | 2 | 0 | 100.00 |
| `.claude/hooks/validate-human-exception-runbook-output.ps1` | 1 | 1 | 1 | 0 | 100.00 |
| `.claude/hooks/enforce-completion-consistency.ps1` | 18 | 10 | 10 | 0 | 100.00 |
| `.codex/hooks/enforce-completion-consistency.ps1` | 11 | 8 | 8 | 0 | 100.00 |
| `.claude/hooks/enforce-file-size-limit.ps1` | 20 | 8 | 8 | 0 | 100.00 |
| `.codex/hooks/enforce-file-size-limit.ps1` | 29 | 12 | 12 | 0 | 100.00 |
| `.claude/hooks/validate-docs-role-output.ps1` | 32 | 13 | 13 | 0 | 100.00 |
| `.claude/hooks/enforce-docs-complete-gate.ps1` | 45 | 11 | 11 | 0 | 100.00 |
| `.claude/lib/worktree-resolution/WorktreeRunRecordPath.psm1` | 21 | 7 | 7 | 0 | 100.00 |
| `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` | 21 | 13 | 13 | 0 | 100.00 |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 32 | 13 | 13 | 0 | 100.00 |
| `.claude/hooks/enforce-epic-worktree-removal-gate-resolution.ps1` | 20 | 10 | 10 | 0 | 100.00 |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 34 | 15 | 15 | 0 | 100.00 |
| `.claude/lib/worktree-resolution/AgentTargetWorktree.psm1` | 201 | 77 | 76 | 1 | 98.70 |
| `.codex/hooks/agent-target-worktree.ps1` | 195 | 74 | 73 | 1 | 98.65 |
| Total | 715 | 289 | 287 | 2 | 99.31 |

The uncovered changed line in each new file is the parameter-default script block of `WorktreeListInvoker` on `Resolve-AgentTargetWorktree` (the `git worktree list --porcelain` call). The plan keeps this as the only process call, and every test injects an in-memory invoker in its place.

## Result

- No per-file drop: every existing file's final value is equal to or above its baseline value.
- No repo-wide drop: 95.80% -> 95.82%.
- Every one of the 20 files is at or above 85% line coverage.
- Outcome: PASS.
