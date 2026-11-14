# Coverage Delta (Issue #1080, P2-T5)

Timestamp: 2026-11-04T20-57
Command: sh SCRATCH/issue-1080-probe.sh (reads the P2-T4 file artifacts/pester/powershell-coverage.xml and prints every line of scripts/dev-tools/Get-EpicProgressReport.ps1 with missed instructions, with its source text)
EXIT_CODE: 0

## Baseline, final, and new-code coverage

| File | Baseline (P0-T7) | Final (P2-T4) | New-code coverage |
|---|---|---|---|
| scripts/dev-tools/Get-EpicProgressReport.ps1 | COVERAGE-ABSENT (new file) | 90.82% (89 of 98 lines) | 90.82% (every line is new) |
| scripts/dev-tools/Get-EpicProgressReport.Logic.ps1 | COVERAGE-ABSENT (new file) | 100% (210 of 210 lines) | 100% (every line is new) |

## Uncovered lines of Get-EpicProgressReport.ps1 (9 lines, no partial lines counted as missed)

| Line | Block | Source |
|---|---|---|
| 196 | `Invoke-GitExe` executable wrapper | `& git @GitArgs 2>$null` |
| 210 | `Invoke-GhExe` executable wrapper | `& gh @GhArgs 2>$null` |
| 224 | `Invoke-CswapExe` executable wrapper | `& cswap @CswapArgs 2>$null` |
| 297 | `Get-EpicProgressUtcNow` clock seam | `return [datetime]::UtcNow` |
| 443 | entry-point block | `$entryRoot = $RepositoryRoot` |
| 444 | entry-point block | `if ([string]::IsNullOrWhiteSpace($entryRoot)) { ... }` |
| 445 | entry-point block | `Push-Location -LiteralPath $entryRoot` |
| 447 | entry-point block | `Invoke-EpicProgressReport @PSBoundParameters` |
| 449 | entry-point block | `Pop-Location` |

Partly covered line (counted as covered): 285 in the `Write-EpicProgressState` seam; the `ShouldProcess` test runs under `-WhatIf` (P1-T6), so the `Set-Content` command on that line is not executed by any test.

Every uncovered line is in one of the three executable wrappers, the clock seam, or the entry-point block, as the plan's Pre-Mortem `Coverage` bullet anticipates. No uncovered line lies elsewhere, so no additional test and no loop restart is needed. Get-EpicProgressReport.Logic.ps1 has no uncovered line.

Output Summary: baseline COVERAGE-ABSENT for both new files; final and new-code line coverage 90.82% (Get-EpicProgressReport.ps1) and 100% (Get-EpicProgressReport.Logic.ps1); the 9 uncovered lines are the git, gh, and cswap wrappers, the clock seam, and the entry point.
