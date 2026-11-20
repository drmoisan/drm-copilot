# QA PSScriptAnalyzer - Issue #1021

Timestamp: 2026-11-03T23-36
Task: [P6-T2]
Command: `sh SCRATCH/issue-1021-pssa.sh` (PowerShell 7: `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over every `.ps1`, `.psm1` and `.psd1` file under `.claude/lib/docs` and `tests/scripts/claude-lib/docs`, recursive; a `NullReferenceException` from the analyzer is retried up to five times)
EXIT_CODE: 0
Output Summary: final run (after format pass 4): 40 files analyzed, 0 findings (Error 0, Warning 0, Information 0, ParseError 0); no retry was needed.

## Loop history

- First run (after format pass 2): 8 warnings, fixed as recorded in `qa-pssa.2026-11-03T23-28.md` (a justified suppression on the specification-fixed name `ConvertFrom-DocsPageBytes`, ASCII-only `DocsPageLinks.psm1` and `DocsPageLinks.Tests.ps1`, the test helper parameter `Profile` renamed `DocsProfile`, and the fixture-factory ShouldProcess suppressions).
- Second run (after format pass 3): 0 findings (one transient analyzer retry).
- Final run (after format pass 4, following the `DocsPageCheck.Tests.ps1` size trim): 0 findings.
