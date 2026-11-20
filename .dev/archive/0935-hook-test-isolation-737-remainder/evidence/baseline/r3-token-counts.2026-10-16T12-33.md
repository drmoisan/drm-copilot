# R3 Token and Line-Count Baseline (P0-T4)

Timestamp: 2026-10-16T12-33
Command: grep -c -F -e / grep -c -E -e / awk 'END { print NR }' per line below (run from the worktree root through `sh SCRATCH/p0t4-counts.sh <worktree root>`, which prints each command and its output)
EXIT_CODE: 0
Output Summary: every count equals its plan-stated value; every line count is at or below 500. No stop condition.

## P_HRH
- grep -c -F -e '$seen =[' tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1 -> 1 (expected 1)
- grep -c -F -e '$seen = [System.Collections.Generic.HashSet[string]]' tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1 -> 0 (expected 0)
- grep -c -F -e 'Test-EpicStateIsolationExcludedHookName' tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1 -> 3 (expected 3)

## P_DH
- grep -c -F -e 'Test-EpicStateIsolationExcludedHookName' tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 -> 0 (expected 0)
- grep -c -F -e "StartsWith('EpicStateIsolation." tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 -> 1 (expected 1)
- grep -c -F -e "EndsWith('.Tests.ps1'" tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 -> 1 (expected 1)
- grep -c -F -e 'before calling either function (issue #935).' tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 -> 1 (expected 1)
- grep -c -F -e 'EpicStateVariableHookLoadCache' tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 -> 0 (expected 0)
- grep -c -F -e 'return [string[]]$names.ToArray()' tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 -> 2 (expected 2)
- grep -c -F -e '$script:EpicStateParseCache = @{}' tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 -> 1 (expected 1)
- grep -c -F -e '$literal = @(Get-EpicStateHookLiteral -SuiteText $SuiteText)' tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 -> 1 (expected 1)
- grep -c -F -e 'is deterministic, keyed by source text, and lives for one test session only (#737 F-6).' tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 -> 1 (expected 1)

## ERE `^ *[.] [(]Join-Path .PSScriptRoot .EpicStateIsolation[.]` and `GetScriptBlock`
| File | ERE count (expected) | GetScriptBlock count (expected) |
|---|---|---|
| tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 | 1 (1) | 0 (0) |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1 | 3 (3) | 0 (0) |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | 6 (6) | 0 (0) |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | 1 (1) | 0 (0) |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | 1 (1) | 0 (0) |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | 1 (1) | 0 (0) |

## Line counts (`awk 'END { print NR }' <path>`)
| Path | Lines |
|---|---|
| tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1 (P_HRH) | 448 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1 (P_HRS) | 454 |
| tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 (P_H) | 433 |
| tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 (P_DH) | 293 |
| tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1 (P_CH) | 224 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 (P_DS) | 356 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 (P_LGS) | 362 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 (P_BRS) | 335 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 (P_PRS) | 288 |
