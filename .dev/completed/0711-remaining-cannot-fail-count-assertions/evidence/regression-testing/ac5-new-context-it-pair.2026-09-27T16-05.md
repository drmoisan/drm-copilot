Timestamp: 2026-09-27T16-05

Edit: added a new sibling `Context 'Non-vacuity floor for the registration count'` with one `It`
block (`documents that the legacy expression @($null).Count -gt 0 evaluates to $true while the
filtered form is $false`) after the existing `It 'leaves no Codex batch-budget state behind'` block
in `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` (net +7 lines).

Command: sh <scratchpad>/run-ps.sh <scratchpad>/select-string-count.ps1 -Path tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 -Pattern 'Non-vacuity floor for the registration count'
EXIT_CODE: 0
Output: 1

Command: sh <scratchpad>/run-ps.sh <scratchpad>/pester-counts.ps1 -Path tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 -FullNameFilter '*Non-vacuity floor for the registration count*'
EXIT_CODE: 0
Output: TotalCount=7, PassedCount=1, FailedCount=0 (Discovery found all 7 tests in the file; the FullNameFilter narrowed execution to the 1 matching new test, which passed.)

Command: sh <scratchpad>/run-ps.sh <scratchpad>/line-counts.ps1 tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1
EXIT_CODE: 0
Output: tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1 LineCount=210

Output Summary: new Context/It literal present (count 1), the new test's isolated filtered run reports PassedCount=1/FailedCount=0, and the file's line count is 210 = 203 (P0-T23 baseline) + 7 exactly. AC-5's new documentation Context/It pair is complete and verified.
