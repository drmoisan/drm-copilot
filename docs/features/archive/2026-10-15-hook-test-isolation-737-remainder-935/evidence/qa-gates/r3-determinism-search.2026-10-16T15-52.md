# R3 Determinism Search (P4-T10)

Timestamp: 2026-10-16T15-52
Command: grep -n -E -e 'New-TemporaryFile|TestDrive|GetTempFileName|Get-Date|Start-Sleep|Start-Process|ProcessStartInfo' <the nine U4 paths>
EXIT_CODE: 0
Output Summary: 6 matching lines; none is classified `executable`.

| Match | Classification | Basis |
|---|---|---|
| `tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1:395` `Load positions: ... ProcessStartInfo` | comment | inside the comment-based help of `Get-EpicStateIsolationHookReference` |
| `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1:270` `$info = [System.Diagnostics.ProcessStartInfo]::new()` | string fixture | inside the `Dynamic spawn` `Source = @' ... '@` here-string (parsed to AST, not executed) |
| `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1:324` `$info = [System.Diagnostics.ProcessStartInfo]::new()` | string fixture | inside the `$suite = @' ... '@` here-string of row `F-3 process-spawning report includes a variable-built hook path` |
| `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1:226` `process-spawning when its text contains ProcessStartInfo ...` | comment | comment-based help of the spawning detector |
| `tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1:237` `$SuiteText.Contains('ProcessStartInfo') ...` | detection token | string literal searched for in suite text; no type is constructed |
| `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1:232` `$suite = "BeforeAll { ... ProcessStartInfo]::new() ..."` | string fixture | expandable string assigned to `$suite`, parsed as fixture text |

Line numbers were derived at task time by the command above.
