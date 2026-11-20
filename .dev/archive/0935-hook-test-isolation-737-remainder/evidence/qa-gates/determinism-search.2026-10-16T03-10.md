# Determinism Search (P6-T7, AC-25)

Timestamp: 2026-10-16T03-10
Command: grep -n -E -e 'New-TemporaryFile|TestDrive|GetTempFileName|Get-Date|Start-Sleep|Start-Process|ProcessStartInfo' <18 Write-Set code files> (from SCRATCH/935/issue-935/p6-static.sh)
EXIT_CODE: 0

Output Summary: 9 matching lines; none is classified `executable`. No file matches `New-TemporaryFile`, `TestDrive`, `GetTempFileName`, `Get-Date` or `Start-Sleep`. PASS.

| File:line | Text (abridged) | Classification |
| --- | --- | --- |
| tests/scripts/claude-hooks/EpicStateIsolation.HookReference.Helpers.ps1:327 | `Load positions: ... ProcessStartInfo` (comment-based help of `Get-EpicStateIsolationHookReference`) | comment |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1:270 | `$info = [System.Diagnostics.ProcessStartInfo]::new()` inside the `Dynamic spawn` single-quoted here-string `Source` | string fixture |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1:324 | `$info = [System.Diagnostics.ProcessStartInfo]::new()` inside the `$suite` single-quoted here-string of the process-spawning row | string fixture |
| tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1:222 | `process-spawning when its text contains ProcessStartInfo ...` (comment-based help, pre-existing) | comment |
| tests/scripts/claude-hooks/EpicStateIsolation.Discovery.Helpers.ps1:233 | `$SuiteText.Contains('ProcessStartInfo')` (pre-existing) | detection token |
| tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1:232 | `$suite = "BeforeAll { ... [System.Diagnostics.ProcessStartInfo]::new() ..."` (pre-existing AC-5 fixture) | string fixture |
| tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1:23 | `2. \`Start-Process\` whose \`-FilePath\` ...` (header comment, pre-existing) | comment |
| tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1:208 | `Returns the literal target executable of a \`Start-Process\` invocation` (comment-based help, pre-existing) | comment |
| tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1:394 | `$commandName -ieq 'Start-Process'` (pre-existing) | detection token |
