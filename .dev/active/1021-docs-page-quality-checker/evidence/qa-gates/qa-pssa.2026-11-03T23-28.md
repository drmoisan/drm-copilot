# QA PSScriptAnalyzer - Issue #1021

Timestamp: 2026-11-03T23-28
Task: [P6-T2]
Command: `sh SCRATCH/issue-1021-pssa.sh` (PowerShell 7: `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` over every `.ps1`, `.psm1` and `.psd1` file under `.claude/lib/docs` and `tests/scripts/claude-lib/docs`, recursive; a `NullReferenceException` from the analyzer is retried up to five times)
EXIT_CODE: 0
Output Summary: final run: 40 files analyzed, 0 findings (Error 0, Warning 0, Information 0, ParseError 0). One transient analyzer `NullReferenceException` on `DocsAnalyzerRegistry.psm1` was retried once and the retry was clean (a known host behavior of the analyzer, not a finding).

## Loop history

The first run (after format pass 2) reported 8 warnings, all fixed before the final run:

| Rule | File | Fix |
|---|---|---|
| `PSUseSingularNouns` | `.claude/lib/docs/DocsPageCheck.psm1` (`ConvertFrom-DocsPageBytes`) | `SuppressMessageAttribute` with a justification: the exported name is fixed by the specification (`### DocsPageCheck.psm1`) |
| `PSUseBOMForUnicodeEncodedFile` | `.claude/lib/docs/DocsPageLinks.psm1` | the related-path pattern held literal U+2028 and U+2029 characters; it now builds them from their code points, so the file is ASCII |
| `PSUseBOMForUnicodeEncodedFile` | `tests/scripts/claude-lib/docs/DocsPageLinks.Tests.ps1` | three non-ASCII test literals are now built from code points |
| `PSAvoidAssignmentToAutomaticVariable` | `tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1` (`Invoke-TestCheck`) | the helper parameter `Profile` is renamed `DocsProfile` and its four callers updated |
| `PSUseShouldProcessForStateChangingFunctions` (4) | `tests/scripts/claude-lib/docs/DocsPageCheck.Tests.ps1` (`New-TestProfile`, `New-TestPage`, `New-TestPageSet`, `New-TestCommandContext`) | the in-memory fixture-factory suppression used by the 1020 suites |

After the fixes [P5-T1] was re-run and the loop restarted from [P6-T1] (`qa-poshqc-format.2026-11-03T23-28.md`, identical listings).
