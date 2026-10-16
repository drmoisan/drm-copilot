# R3 Line Counts (P4-T8)

Timestamp: 2026-10-16T15-51
Command: awk 'END { print NR }' <path> for each of the nine U4 paths
EXIT_CODE: 0
Output Summary: every count is at or below 500 (maximum 454).

| Path | Lines |
|---|---|
| tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1 | 448 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1 | 454 |
| tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1 | 433 |
| tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1 | 292 |
| tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1 | 224 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | 356 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1 | 362 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1 | 335 |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Predicate.Tests.ps1 | 288 |
