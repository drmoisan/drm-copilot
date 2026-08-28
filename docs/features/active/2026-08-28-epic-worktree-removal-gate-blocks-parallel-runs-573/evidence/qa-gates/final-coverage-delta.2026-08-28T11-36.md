# Final QA Loop — COVERAGE Comparison (P5-T5)

Timestamp: 2026-08-28T11-36

Task: [P5-T5]
Issue: #573
Acceptance criteria discharged: AC-23; supporting AC-6
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command:
1. Derivation from the report the [P5-T4] run wrote: `pwsh -NoProfile -File <scratch>/read-coverage.ps1 -CoverageXml artifacts/pester/powershell-coverage.xml -JUnitXml artifacts/pester/pester-junit.xml -SourceFileSuffix enforce-epic-worktree-removal-gate.ps1 -SuiteNameFragment enforce-epic-worktree-removal-gate`
2. Missed-line enumeration: `pwsh -NoProfile -File <scratch>/read-missed-lines.ps1 -CoverageXml artifacts/pester/powershell-coverage.xml -SourceFileSuffix enforce-epic-worktree-removal-gate.ps1`
3. Changed-line membership check: `git diff c7133fe75ce1ea1737843330b2232c175a689e37 -- .claude/hooks/enforce-epic-worktree-removal-gate.ps1` reduced to added-line numbers, then each added executable line's `ci` and `mi` attributes read from the same coverage report.

EXIT_CODE: 0

Branch coverage is deliberately **not** recorded. Pester does not measure branch coverage in any output format, and no branch-coverage gate applies to PowerShell per `.claude/rules/powershell.md` and `.claude/rules/quality-tiers.md`.

## Whole-run line coverage

| Metric | Baseline ([P0-T4]) | Post-change | Delta |
| --- | --- | --- | --- |
| Covered lines | 7211 | 7236 | +25 |
| Missed lines | 403 | 403 | 0 |
| Total lines | 7614 | 7639 | +25 |
| **Line coverage** | **94.71%** | **94.72%** | **+0.01 pp** |

`7236 / (7236 + 403) * 100 = 94.7244...`, rounded to `94.72`. The whole-run missed count is unchanged at 403, so all 25 newly measured lines are covered.

## Per-file line coverage — `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`

Derived per the plan's stated derivation: the `sourcefile` element whose `name` ends with `enforce-epic-worktree-removal-gate.ps1`, in package `.../.claude/hooks`; its `counter` element of type `LINE`; `covered / (covered + missed) * 100`. Exactly one `sourcefile` matched under that package.

| Metric | Baseline ([P0-T4]) | Post-change | Delta |
| --- | --- | --- | --- |
| Covered lines | 64 | 89 | +25 |
| Missed lines | 4 | 4 | 0 |
| Total lines | 68 | 93 | +25 |
| **Line coverage** | **94.12%** | **95.70%** | **+1.58 pp** |

`89 / (89 + 4) * 100 = 95.6989...`, rounded to `95.70`.

**Threshold: PASS.** 95.70% is at or above the uniform 85% line-coverage threshold.

**No regression: PASS.** 95.70% is not lower than the [P0-T4] baseline value of 94.12% for this file; it is 1.58 percentage points higher.

## The four missed lines are the same pre-existing unreachable tail

| Baseline missed | Post-change missed |
| --- | --- |
| 269, 270, 271, 274 | 414, 415, 416, 419 |

The missed count is unchanged at 4, and the lines are the same four statements shifted downward by the docstring and function additions above them: `$entryPointResult = @(Invoke-EpicWorktreeRemovalGateEntryPoint)`, the `if ($entryPointResult.Count -gt 1) {` test, the `Write-Output` pipeline inside it, and the final `exit ([int]$entryPointResult[-1])`. All four sit below the `if ($MyInvocation.InvocationName -eq '.') { return }` guard at line 407 and are therefore unreachable when the suite dot-sources the hook. They are pre-existing, are not lines this change adds, and are counted in the denominator rather than excluded, per the Coverage Exclusion Policy.

## Changed-line coverage — every line added in Phase 2 is covered

The merge-base-anchored diff adds these executable statements inside `Invoke-EpicWorktreeRemovalGateDecision` and the new functions. The added-line set spans the rewritten `.DESCRIPTION` (lines 7-51, comment lines carrying no coverage counters), the new read seam and shared parser (lines 64, 85-130), the new predicate (lines 225-288), and the decision-body rewire (lines 353, 360-365).

Each added **executable** line was checked individually against the coverage report:

| Added line | Statement | `ci` (covered instructions) | `mi` (missed instructions) |
| --- | --- | --- | --- |
| 353 | `$checkpoint = ConvertFrom-EpicWorktreeGateJson -Raw (Get-EpicWorktreeGateCheckpointContent)` | 2 | 0 |
| 360 | `$parallelCheckpoint = ConvertFrom-EpicWorktreeGateJson -Raw (Get-EpicWorktreeGateParallelCheckpointContent)` | 2 | 0 |
| 361 | `if (Test-ParallelCheckpointAllowsWorktreeRemoval -Checkpoint $parallelCheckpoint -WorktreePath $worktreePath) {` | 1 | 0 |
| 362 | `return Get-EpicWorktreeGateAllowDecision` | 1 | 0 |
| 365 | `return Get-EpicWorktreeGateBlockDecision -Reason "EPIC_WORKTREE_REMOVAL_BLOCKED: ..."` | 1 | 0 |

Every one reports `mi=0`. The lines inside the new read seam (85-130 region) and the new predicate (225-288 region) are likewise covered: the file's missed set is exactly `{414, 415, 416, 419}`, and none of the added line numbers appears in it. The intersection of the added-line set with the missed set is **empty**.

**Every line added in Phase 2 is covered: PASS.**

## AC-6 corroboration

Line 353 carries `ci=2`, reflecting that the epic branch's rewired parse is exercised by both the epic-path tests and the parallel-path tests. The epic branch's behaviour is unchanged and remains exercised at its pre-change level, consistent with the 27 pre-existing tests all passing in [P5-T4].

Output Summary: PASS (AC-23). Gate-hook post-change line coverage is **95.70%** (89 covered / 4 missed of 93), at or above the 85% threshold and **not lower** than the [P0-T4] baseline of 94.12% (64 covered / 4 missed of 68) — a gain of 1.58 percentage points. Whole-run line coverage is 94.72% (7236 covered / 403 missed of 7639) against a baseline of 94.71% (7211 covered / 403 missed of 7614). The missed count for the hook is unchanged at 4 and the missed lines are the same pre-existing unreachable entry-point tail, renumbered 269/270/271/274 to 414/415/416/419. Every line added in Phase 2 is covered: each added executable statement reports `mi=0`, and the intersection of the added-line set with the file's missed set is empty. Branch coverage is not recorded because Pester does not measure it and no branch threshold applies to PowerShell.
