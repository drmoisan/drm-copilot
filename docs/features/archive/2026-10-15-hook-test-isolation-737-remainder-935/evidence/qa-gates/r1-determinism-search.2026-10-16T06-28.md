# R1 Determinism Search (P4-T7)

Timestamp: 2026-10-16T06-28
Command: grep -n -E -e 'New-TemporaryFile|TestDrive|GetTempFileName|Get-Date|Start-Sleep|Start-Process|ProcessStartInfo' over the seven edited code files (all under tests/scripts/claude-hooks/), at HEAD 78e5f6d4e
EXIT_CODE: 0
Output Summary: 5 matching lines; none is classified `executable`. Classifications follow main-plan P6-T7 (`string fixture`, `detection token`, `comment`, `executable`).

| File:line | Text | Classification |
|---|---|---|
| `EpicStateIsolation.HookReference.Helpers.ps1:356` | `Load positions: the argument of a . or & invocation; Import-Module path arguments; ProcessStartInfo` | comment (inside the `Get-EpicStateIsolationHookReference` doc comment) |
| `EpicStateIsolation.Discovery.Helpers.ps1:227` | `process-spawning when its text contains ProcessStartInfo or the process-start cmdlet` | comment (doc comment) |
| `EpicStateIsolation.Discovery.Helpers.ps1:238` | `$spawns = $SuiteText.Contains('ProcessStartInfo') -or $SuiteText.Contains($cmdlet) -or` | detection token (string compared against suite text; constructs no type) |
| `enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1:270` | `$info = [System.Diagnostics.ProcessStartInfo]::new()` | string fixture (inside the `Dynamic spawn` here-string, lines 265-275) |
| `enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1:324` | `$info = [System.Diagnostics.ProcessStartInfo]::new()` | string fixture (inside the `$suite = @'...'@` here-string, lines 320-329) |

No `New-TemporaryFile`, `TestDrive`, `GetTempFileName`, `Get-Date`, `Start-Sleep` or `Start-Process` match exists in the seven files. The CR-N3 rows compose the process-start cmdlet name at run time from `__SPAWN__` and only parse the fixture; they start no process.
