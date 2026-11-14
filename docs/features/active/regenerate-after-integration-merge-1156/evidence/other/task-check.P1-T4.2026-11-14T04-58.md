# Task Check — [P1-T4]

Timestamp: 2026-11-14T04-58
Changed files: new `tests/scripts/claude-lib/regeneration/Invoke-RegenerationPath.ProcessStart.Tests.ps1` (dot-sources the adapter; injected `-Resolver` scriptblocks and literal `-ComSpec` values only; no process, file, PATH read, or environment write).
Selection: the new test file. Rule: a changed test file runs itself.
Command: sh SCRATCH/issue-1156-static.sh (check-only Invoke-Formatter and Invoke-ScriptAnalyzer); sh SCRATCH/issue-1156-pester.sh (New-PesterConfiguration, Run.Path = the file, Run.Exit = $true)
EXIT_CODE: 0
Output Summary:
- First pass: one analyzer finding (PSReviewUnusedParameter on a resolver stub); fixed with the file-level suppression the sibling suite carries; re-run: formatter differences 0, analyzer findings 0, 113 logical lines.
- Pester: 17 passed, 0 failed, 0 skipped (at least 12 required).
- Cases: `.exe` and extensionless paths start directly with arguments unchanged; an empty argument list stays empty; `.cmd` and `.BAT` route through the given ComSpec with `/d`, `/c`, the path, then each argument in order; a batch path holding a space stays one item; null and empty ComSpec throw; batch arguments holding a space, a double quote, or `&` throw; the resolver's path is returned; Name reaches the resolver unchanged; null and empty resolver results throw `cannot be resolved`; `Invoke-RegenerationProcessStep` returns `Started = $false` with a null `ExitCode` when `Resolve-RegenerationExecutable` is mocked to throw (the spec is never called), and when `Get-RegenerationProcessStartSpec` is mocked to throw (extra case; it also covers the spec line of the default invoker).
