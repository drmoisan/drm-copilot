# R4 Determinism Search (P5-T10, issue #935)

Timestamp: 2026-10-17T01-42
Command: grep -n -E -e 'New-TemporaryFile|TestDrive|GetTempFileName|Get-Date|Start-Sleep|Start-Process|ProcessStartInfo' over the eight CODE8 paths (tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1, tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1, tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1, tests/scripts/claude-hooks/EpicStateIsolation.Helpers.ps1, tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1, tests/scripts/claude-hooks/EpicStateIsolation.Compliance.Helpers.ps1, tests/scripts/claude-hooks/enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1, tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1)
EXIT_CODE: 0

Output Summary (six matching lines, each classified as defined by main-plan P6-T7):

| File | Line | Text (abridged) | Classification |
|---|---|---|---|
| EpicStateIsolation.HookReference.Helpers.ps1 | 402 | `Load positions: the argument of a . or & invocation; Import-Module path arguments; ProcessStartInfo` | comment (help block of `Get-EpicStateIsolationHookReference`) |
| enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1 | 282 | `$info = [System.Diagnostics.ProcessStartInfo]::new()` | string fixture (inside the `Dynamic spawn` here-string, lines 277-287) |
| enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1 | 336 | `$info = [System.Diagnostics.ProcessStartInfo]::new()` | string fixture (inside the `$suite = @'` here-string, lines 332-341) |
| EpicStateIsolation.Discovery.Helpers.ps1 | 306 | `process-spawning when its text contains ProcessStartInfo or the process-start cmdlet` | comment (help block of `Get-EpicStateProcessSpawningHook`) |
| EpicStateIsolation.Discovery.Helpers.ps1 | 317 | `$spawns = $SuiteText.Contains('ProcessStartInfo') -or ...` | detection token (string literal compared against the suite text) |
| enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1 | 242 | `$suite = "BeforeAll { ... [System.Diagnostics.ProcessStartInfo]::new() ... }"` | string fixture (double-quoted fixture string of the row `AC-5 process-spawning fixture is reported and does not fail`) |

Result: no match is classified `executable`. The distribution equals the planning expectation (two in P_HRS, two in P_DH, one in P_HRH, one in P_DS); this cycle added none (the Phase 4 code reads no clock; the Stopwatch of D-PERF-TIME is in a command, not in a file).
