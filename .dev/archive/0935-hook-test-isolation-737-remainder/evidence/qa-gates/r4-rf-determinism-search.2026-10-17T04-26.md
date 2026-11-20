# R4 Phase 6 determinism search (P6-T28)

Timestamp: 2026-10-17T04-26
Command: grep -n -E -e 'New-TemporaryFile|TestDrive|GetTempFileName|Get-Date|Start-Sleep|Start-Process|ProcessStartInfo' over the nine CODE9 paths (tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Branches.Tests.ps1, EpicStateIsolation.HookReference.Helpers.ps1, enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1, EpicStateIsolation.Helpers.ps1, EpicStateIsolation.Discovery.Helpers.ps1, EpicStateIsolation.Compliance.Helpers.ps1, enforce-epic-worktree-removal-gate.ManifestBranch.Tests.ps1, enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1, enforce-gate-suites.EpicStateIsolation.Memo.Tests.ps1)
EXIT_CODE: 0
Output Summary: six matches, none classified executable; none in the Memo suite; Phase 6 adds none.

| File:line | Match | Classification |
|---|---|---|
| EpicStateIsolation.HookReference.Helpers.ps1:402 | `Load positions: ... ProcessStartInfo` (help text) | comment |
| enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1:294 | `$info = [System.Diagnostics.ProcessStartInfo]::new()` inside the `Dynamic spawn` here-string fixture (`Source = @'` ... `'@`) | string fixture |
| enforce-gate-suites.EpicStateIsolation.HookReference.Tests.ps1:348 | `$info = [System.Diagnostics.ProcessStartInfo]::new()` inside the here-string `$suite = @'` ... `'@` of row `F-3 process-spawning report includes a variable-built hook path` | string fixture |
| EpicStateIsolation.Discovery.Helpers.ps1:314 | `process-spawning when its text contains ProcessStartInfo ...` (help text) | comment |
| EpicStateIsolation.Discovery.Helpers.ps1:325 | `$SuiteText.Contains('ProcessStartInfo')` (string literal compared against suite text) | detection token |
| enforce-gate-suites.EpicStateIsolation.Discovery.Tests.ps1:244 | `ProcessStartInfo` inside the double-quoted fixture string of row `AC-5 process-spawning fixture is reported and does not fail` | string fixture |
