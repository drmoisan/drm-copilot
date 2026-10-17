# R1 Pre-Edit Token Counts (P0-T4)

Timestamp: 2026-10-16T04-38
Command: grep -c -F -e '<token>' <file> (ERE: grep -c -E -e '<pattern>' <file>); awk 'length($0) > 180 { n++ } END { print n+0 }' <file>; run from tests/scripts/claude-hooks through a helper script under SCRATCH (one grep per token)
EXIT_CODE: 0
Output Summary: every count equals its stated value; no mismatch.

| File | Token | Expected | Observed |
|---|---|---|---|
| EpicStateIsolation.HookReference.Helpers.ps1 | `$isLiteral = {` | 4 | 4 |
| EpicStateIsolation.HookReference.Helpers.ps1 | `[A-Za-z0-9_-])hooks/` | 2 | 2 |
| EpicStateIsolation.HookReference.Helpers.ps1 | `(?!.*` | 2 | 2 |
| EpicStateIsolation.HookReference.Helpers.ps1 | `hooks[` | 3 | 3 |
| EpicStateIsolation.HookReference.Helpers.ps1 | `[A-Za-z_][A-Za-z0-9_]*(:` | 2 | 2 |
| EpicStateIsolation.HookReference.Helpers.ps1 | `$isAssignment = {` | 2 | 2 |
| EpicStateIsolation.HookReference.Helpers.ps1 | `$isHashtable = {` | 2 | 2 |
| EpicStateIsolation.HookReference.Helpers.ps1 | `Get-EpicStateIsolationVariableBinding -SuiteAst $SuiteAst -Key $Key` | 2 | 2 |
| EpicStateIsolation.HookReference.Helpers.ps1 | `$match.Index + 5` | 1 | 1 |
| EpicStateIsolation.HookReference.Helpers.ps1 | `Test-EpicStateIsolationSeparateValue` | 0 | 0 |
| EpicStateIsolation.HookReference.Helpers.ps1 | `[CmdletBinding()]` | 0 | 0 |
| EpicStateIsolation.Discovery.Helpers.ps1 | `defined in EpicStateIsolation.HookReference.Helpers.ps1` | 0 | 0 |
| EpicStateIsolation.Helpers.ps1 | `$Node, [Parameter(Mandatory)]` | 1 | 1 |
| EpicStateIsolation.Helpers.ps1 | awk lines longer than 180 | 1 | 1 |
| enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | ERE `^[$]script:UnderTest` | 6 | 6 |
| enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | ERE `^        [$]script:UnderTest = Join-Path` | 5 | 5 |
| enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | `hooks/enforce-x.ps1'` | 12 | 12 |
| enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | ERE `^[$]script:UnderTest` | 8 | 8 |
| enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | ERE `^        [$]script:UnderTest = Join-Path` | 2 | 2 |
| enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | `hooks/enforce-x.ps1'` | 10 | 10 |
| enforce-gate-suites.EpicStateIsolation.Tests.ps1 | ERE `^[$]script:UnderTest` | 12 | 12 |
| enforce-gate-suites.EpicStateIsolation.Tests.ps1 | ERE `^        [$]script:UnderTest = Join-Path` | 0 | 0 |
| enforce-gate-suites.EpicStateIsolation.Tests.ps1 | `hooks/enforce-x.ps1'` | 12 | 12 |

All files are under `tests/scripts/claude-hooks/`.
