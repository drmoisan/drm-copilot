# Main Script Repository Constraints (Issue #1080, P1-T8)

Timestamp: 2026-11-04T20-53
Command: sh SCRATCH/issue-1080-run.sh issue-1080-p1t8.log -1 tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1
EXIT_CODE: 0

## Change

Added `Describe 'Get-EpicProgressReport.ps1 repository constraints'` to `tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1`. It parses both production files with `[System.Management.Automation.Language.Parser]::ParseFile`, collects every `CommandAst` with its enclosing function, and reads the comment-based help with `Get-Help -Full`:

- file writes: of `Set-Content`, `Add-Content`, `Out-File`, `New-Item`, `Remove-Item`, `Copy-Item`, `Move-Item`, exactly one command appears (`Set-Content`), inside `Write-EpicProgressState`;
- native commands: exactly three `git`, `gh`, `cswap` invocations, each inside `Invoke-GitExe`, `Invoke-GhExe`, `Invoke-CswapExe` respectively;
- hardcoded values: neither production file contains `documentation-estate-tooling`, `1019`, `/workspaces`, or `2026-11-04T13:55`, or matches `(?<![A-Za-z])[A-Za-z]:[\\/]`;
- help: all 13 `param` entries have a non-empty help description, plus a synopsis and description; at least one example, whose code uses `-EpicFolder example-epic`.

## Result

TOTAL Tests=29 Passed=29 Failed=0 Skipped=0 NotRun=0
FILE tests/scripts/dev-tools/Get-EpicProgressReport.Tests.ps1 tests=29 failed=0

## Plan-named It blocks (5, all passed)

- confines file writes to Write-EpicProgressState
- confines native commands to their wrappers
- contains no recovered hardcoded value
- documents every parameter in comment-based help
- carries at least one example

Output Summary: 29 tests in Get-EpicProgressReport.Tests.ps1 (24 earlier plus 5), Failed=0; all five plan-named constraint It blocks pass.
