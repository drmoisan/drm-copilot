# Task Check — [P1-T3]

Timestamp: 2026-11-14T04-56
Changed files: `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.Tests.ps1`, Describe `Invoke-RegenerationPath seam defaults (AST)`:
- the process `-Invoker` (h) test now pins exactly two commands (`Resolve-RegenerationExecutable`, `Get-RegenerationProcessStartSpec`) with no invocation operator, `-ComSpec` bound to `$env:ComSpec`, one `ProcessStartInfo` construction from `$spec.FileName`, one `Process.Start`, one `$info.ArgumentList.Add` inside the one loop over `$spec.ArgumentList`, `UseShellExecute` `$false`, both redirects `$true`, two `ReadToEndAsync`, one `WaitForExit`, two `[Console]::Error` writes, and one `ExitCode` read on `$process`;
- new (h) test for the `-Resolver` default of `Resolve-RegenerationExecutable` (one `Get-Command`, `-Name` bound to `$Name`, `-CommandType` `Application`, no command other than `Get-Command` and `Select-Object`);
- `(h) no seam default writes to the success or host stream` now includes the `-Resolver` default.
Selection: the changed test file. Rule: a changed test file runs itself.
Command: sh SCRATCH/issue-1156-static.sh (check-only Invoke-Formatter and Invoke-ScriptAnalyzer); sh SCRATCH/issue-1156-pester.sh (New-PesterConfiguration, Run.Path = the file, Run.Exit = $true)
EXIT_CODE: 0
Output Summary: formatter differences 0, analyzer findings 0, 602 logical lines; Pester 123 passed, 0 failed, 0 skipped.
