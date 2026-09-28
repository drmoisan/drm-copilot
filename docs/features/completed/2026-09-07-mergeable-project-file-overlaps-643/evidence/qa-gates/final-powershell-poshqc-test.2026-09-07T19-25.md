# Final QA — PowerShell tests with coverage (PoshQC test)

Timestamp: 2026-09-07T19-25

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` = `C:\Users\DanMoisan\repos\drm-copilot-wt\2026-09-07T08-09`, then `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`

EXIT_CODE: 0

## Output Summary

MCP result `ok`: `true`
MCP `summary`: `Ran bundled PoshQC test against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-09-07T08-09'.`

Both invocations are recorded because `.claude/rules/powershell.md` requires the MCP call while the
MCP payload carries only `ok`, `tool`, `workspace_root`, and `summary`; the numeric coverage values
are read from the self-hosted run, following the precedent at
`docs/features/completed/2026-08-28-conflictresult-truthiness-always-true-576/evidence/qa-gates/final-powershell-test.2026-08-28T12-46.md`.

Verbatim `Tests Passed:` line from the self-hosted run (ANSI colour codes stripped):

```text
Tests Passed: 3998, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
```

Verbatim `Covered` line:

```text
Covered 94.13% / 0%. 11,390 analyzed Commands in 92 Files.
```

The first figure is command (instruction) coverage; the second is `0%` because Pester measures no
branch coverage.

### Passed-count check

The [P0-T14] baseline recorded `Tests Passed: 3921, Failed: 0, Skipped: 9, Inconclusive: 0,
NotRun: 0`. The required floor is that count plus 45, that is 3966. The observed count is 3998,
which clears the floor by 32. `Failed: 0` holds.

### JaCoCo report `artifacts/pester/powershell-coverage.xml`

Report-level `LINE` counter:

- `covered` = 7757
- `missed` = 418
- derived line coverage = `7757 / (7757 + 418) * 100` = **94.89%**

At or above 85, and not below the [P0-T14] value of 94.80% (it is 0.09 points higher), so the
no-more-than-0.5-point regression bound holds.

Per-`sourcefile` `LINE` counters and derived percentages for the five PowerShell production files of
this plan:

| File | covered | missed | line coverage |
| --- | --- | --- | --- |
| `BlastRadius.psm1` | 97 | 0 | **100.00%** |
| `BlastRadiusConflict.psm1` | 42 | 1 | **97.67%** |
| `ProjectFileMergeGrammar.psm1` | 121 | 1 | **99.18%** |
| `ProjectFileMerge.psm1` | 124 | 0 | **100.00%** |
| `Resolve-MergeableConflict.ps1` | 56 | 9 | **86.15%** |

Each of the five is at or above 85. `BlastRadius.psm1` is at 100.00%, not below its [P0-T14] per-file
value of 100.00%.

### Branch coverage statement

Pester measures no branch coverage. Its output reports command (instruction) coverage and line
coverage only, and the JaCoCo report carries no `BRANCH` counter for these sources. No
branch-coverage threshold therefore applies to PowerShell, per `.claude/rules/powershell.md` and
`.claude/rules/quality-tiers.md`. This is a threshold exemption only: PowerShell production files
remain in the coverage denominator under the Coverage Exclusion Policy.

## Loop iteration and restart cause

This run is the test step of PowerShell loop iteration 4. On iteration 3 this step reported
`Resolve-MergeableConflict.ps1` at 55 covered / 10 missed = 84.62%, below the 85 floor. The fix and
the restart are recorded in `final-powershell-poshqc-format.2026-09-07T19-20.md`. No source file
changed after the iteration-4 format step, so the values above observe the final tree.
