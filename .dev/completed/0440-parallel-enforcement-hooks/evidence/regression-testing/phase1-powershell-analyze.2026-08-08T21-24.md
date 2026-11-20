# Phase 1 — PowerShell Lint (PoshQC / PSScriptAnalyzer) — Issue #440

Timestamp: 2026-08-08T21-24

Task: [P1-T6]

Command: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root=C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a0b28ae2f972ac0ee`

EXIT_CODE: 0

## Final (Clean) Result

```json
{
  "ok": true,
  "tool": "run_poshqc_analyze",
  "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a0b28ae2f972ac0ee",
  "summary": "Ran bundled PoshQC analyze against 'C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a0b28ae2f972ac0ee'."
}
```

## First Pass — Three Findings, Fixed, Loop Restarted

The first invocation exited 1:

```json
{
  "ok": false,
  "tool": "run_poshqc_analyze",
  "workspace_root": "C:\\Users\\DanMoisan\\repos\\drm-copilot\\.claude\\worktrees\\agent-a0b28ae2f972ac0ee",
  "summary": "Command exited with code 1.",
  "stderr_excerpt": "Exception: PSScriptAnalyzer reported 3 issue(s)."
}
```

All three findings were in `.claude/hooks/enforce-parallel-cohort-barrier.ps1`. They were localized with a per-file run against the repository settings file:

`pwsh -NoProfile -Command '@("<the four Phase 1 files>") | ForEach-Object { Invoke-ScriptAnalyzer -Path $_ -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 } | Format-List RuleName,Severity,ScriptName,Line,Message'`

| # | Rule | Severity | Line | Function | Message |
| --- | --- | --- | --- | --- | --- |
| 1 | `PSUseOutputTypeCorrectly` | Information | 279 | `Find-ParallelCohortBarrierCohortIndex` | returns an object of type `System.Int32` but this type is not declared in the OutputType attribute |
| 2 | `PSUseOutputTypeCorrectly` | Information | 309 | `Get-ParallelCohortBarrierConflictNeighborList` | returns an object of type `System.Object[]` but this type is not declared in the OutputType attribute |
| 3 | `PSUseOutputTypeCorrectly` | Information | 313 | `Get-ParallelCohortBarrierConflictNeighborList` | returns an object of type `System.Object[]` but this type is not declared in the OutputType attribute |

`scripts/powershell/PoshQC/settings/pssa.settings.psd1` sets `Severity = @('Error', 'Warning', 'Information')`, so Information-severity findings fail the gate and had to be resolved rather than accepted.

### Fixes Applied

1. Added `[OutputType([int])]` to `Find-ParallelCohortBarrierCohortIndex`. The function returns a cohort index or `$null`; the attribute now declares the value type it produces. Behavior is unchanged — `OutputType` is metadata only.
2. Declared `[OutputType([object[]])]` on `Get-ParallelCohortBarrierConflictNeighborList` and left the accumulator as `$neighborList = @()`. An interim attempt typed the accumulator as `[string[]]` while keeping `[OutputType([string[]])]`; the analyzer's static inference does not track the variable's type constraint at the two early-return sites, so findings 2 and 3 persisted. Declaring the type the analyzer actually infers at every return site (`System.Object[]`) resolves both deterministically. The list's runtime contents are unchanged — each element is an item key rendered as a string via `[string]$edge.a` / `[string]$edge.b` — and the `.OUTPUTS` documentation block was updated to state that explicitly.

### Restart and Re-verification

Per plan Binding Constraint 9 and the P1-T6 task text, the loop was restarted from P1-T5 after the fix: format re-ran clean (recorded as the second pass in `phase1-powershell-format.2026-08-08T21-24.md`), then this analyzer run returned `ok: true`. A targeted confirmation run over the four Phase 1 files produced zero findings:

```
---ANALYZE-DONE---
```

(no finding lines emitted before the sentinel).

Both new Pester suites were re-executed after the production-file edit to confirm the fix is behavior-neutral: `COHORT passed=56 failed=0`, `WORKTREE passed=40 failed=0`.

Output Summary: PASS after one mandated loop restart. The first `mcp__drm-copilot__run_poshqc_analyze` run exited 1 with three `PSUseOutputTypeCorrectly` Information findings, all in `.claude/hooks/enforce-parallel-cohort-barrier.ps1`: a missing `[OutputType([int])]` on `Find-ParallelCohortBarrierCohortIndex` (line 279) and two undeclared `System.Object[]` return sites in `Get-ParallelCohortBarrierConflictNeighborList` (lines 309 and 313). Because the repository analyzer settings treat Information as failing, both were fixed — the missing attribute was added, and the neighbor-list function now declares `[OutputType([object[]])]`, the type the analyzer infers at every return site. The loop was then restarted from P1-T5: format re-ran clean and this analyzer run returned `ok: true` (EXIT_CODE 0), with a targeted per-file confirmation run over all four Phase 1 files emitting zero findings. The two new Pester suites were re-run after the edit and still report 56 of 56 and 40 of 40 passing, confirming the fix is behavior-neutral.
