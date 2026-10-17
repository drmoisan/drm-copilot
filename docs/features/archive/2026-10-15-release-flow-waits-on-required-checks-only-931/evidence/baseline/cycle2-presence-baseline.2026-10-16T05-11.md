# Cycle 2 Presence and Absence Baseline (Issue #931)

Timestamp: 2026-10-16T05-11
Command: Glob `**/Invoke-FullReleaseFlow.CheckHelpers*.ps1` in `<worktree>`; Grep tool count-mode searches listed below
EXIT_CODE: 0
Output Summary: Both CheckHelpers files absent. Script counts: OutputType hashtable 2, OutputType pscustomobject 3, null guard 1, helper function definitions 2. New literals absent from scripts and tests (0, 0). It counts: Tests 15, ChecksWait 19, CheckClassification 18, AdditionalFailurePaths 2. All match the plan.

## Absence (Glob tool)

- `scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.ps1`: absent
- `tests/scripts/dev-tools/Invoke-FullReleaseFlow.CheckHelpers.Tests.ps1`: absent
- Glob pattern `**/Invoke-FullReleaseFlow.CheckHelpers*.ps1` returned no files.

## Grep counts on `scripts/dev-tools/Invoke-FullReleaseFlow.ps1`

| Regex | Count |
|---|---|
| `OutputType\(\[hashtable\]\)` | 2 |
| `OutputType\(\[pscustomobject\]\)` | 3 |
| `\$null -eq \$check` | 1 |
| `^function (ConvertFrom-CheckPollOutput\|Get-CheckSetVerdict) ` | 2 |

## Grep counts in `scripts` and `tests`

Searched with the alternation regex `Test-UnregisteredCheckPollOutput|Could not query the checks` (neither literal contains a metacharacter); zero total matches in each directory, so each literal has count 0.

| Literal | scripts | tests |
|---|---|---|
| `Test-UnregisteredCheckPollOutput` | 0 | 0 |
| `Could not query the checks` | 0 | 0 |

## `It` counts (regex `^\s+It "`)

| Suite | Count |
|---|---|
| `Invoke-FullReleaseFlow.Tests.ps1` | 15 |
| `Invoke-FullReleaseFlow.ChecksWait.Tests.ps1` | 19 |
| `Invoke-FullReleaseFlow.CheckClassification.Tests.ps1` | 18 |
| `Invoke-FullReleaseFlow.AdditionalFailurePaths.Tests.ps1` | 2 |
