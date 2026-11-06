# Main Script Settings and Seams (Issue #1080, P1-T6)

Timestamp: 2026-11-04T20-48
Command: sh SCRATCH/issue-1080-run.sh issue-1080-p1t6.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1
EXIT_CODE: 0

## Change

- Created `scripts/dev-tools/Get-EpicProgressReport.ps1` with comment-based help (synopsis, description, one `.PARAMETER` per parameter stating its default, two `.EXAMPLE` entries using the placeholder epic folder `example-epic`), the `[CmdletBinding()]` `param` block (`-EpicFolder` and `-StartUtc` mandatory; `-Mode` `[ValidateSet('TLDR', 'Full')]` default `Full`; remaining defaults as in AC3), the logic dot-source through `Join-Path -Path $PSScriptRoot`, the pure `Resolve-EpicProgressSetting`, and the eight seams `Invoke-GitExe`, `Invoke-GhExe`, `Invoke-CswapExe`, `Test-EpicProgressCommand`, `Test-EpicProgressPath`, `Read-EpicProgressFile`, `Write-EpicProgressState` (`SupportsShouldProcess`), and `Get-EpicProgressUtcNow`.
- Created `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`, which dot-sources the script with `-EpicFolder` and `-StartUtc` bound. The state-path test passes a fixture `-TempRoot` string and names no temp-path API.

## Result

TOTAL Tests=9 Passed=9 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 tests=9 failed=0

The `-WhatIf` test printed one `What if: Performing the operation "Write epic progress state"` line, and no file was created (`git status --porcelain` lists only the two new tracked-candidate files).

## Plan-named It blocks (9, all passed)

- defaults the integration branch from the epic folder
- defaults the kickoff path from the epic folder
- defaults the checkpoint path under the repository root
- defaults the state path under the temporary root and outside the repository
- keeps explicit values over defaults
- returns false for an absent command name
- returns false for an absent path
- reads the raw text of an existing file
- writes nothing when the state write runs with WhatIf

Output Summary: 9 tests, Failed=0 for Get-EpicProgressReport.Tests.ps1; all nine plan-named It blocks pass and the WhatIf write created no file.
