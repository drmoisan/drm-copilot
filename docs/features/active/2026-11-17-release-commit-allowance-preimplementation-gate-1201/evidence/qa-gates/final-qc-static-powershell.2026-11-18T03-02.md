# Final QC static - PowerShell (remediation cycle 1, loop restart after the leaker supplement)

Timestamp: 2026-11-18T02-53
Command: sh SCRATCH/issue-1201-ps-static.sh <the 19 test files changed in cycle 1>; sh SCRATCH/issue-1201-leak-scan.sh
EXIT_CODE: 0
Output Summary: format 0 drift, PSScriptAnalyzer 0 findings, and leak scan 0 failures over 19 changed files. The loop restarted because three leaker suites were added after the 2026-11-18T02-37 artifact.

| Step | Command | EXIT_CODE | Finding count |
|---|---|---|---|
| 1. Format (check-only in-memory Invoke-Formatter compare, repository settings; no file written) | sh SCRATCH/issue-1201-ps-static.sh <19 files> | 0 | 0 ("format_drift=0") |
| 2. PSScriptAnalyzer (repository settings) | same script | 0 | 0 ("pssa_findings=0") |
| 3. Invoke-PoshQCLeakScan | sh SCRATCH/issue-1201-leak-scan.sh | 0 | 0 failures ("865 files, 78 findings, 76 exempt, 2 allowlisted, 0 failures") |
| Type checking | not applicable to PowerShell | - | - |

The formatter would change no file.

Physical line counts: the 16 files listed in final-qc-static-powershell.2026-11-18T02-37.md are unchanged since that run, and the three added files are hook-dependency-failure.Claude.Tests.ps1 226, hook-dependency-failure.SpecialCases.Tests.ps1 298, and subagentstop-uncaught-error.Tests.ps1 165. Deviation (non-blocking): hook-import-failure-exemptions.FailClosed.Tests.ps1 is 539 lines (536 before cycle 1), which is above the 500-line guidance tier and below the 700 advisory and 800 hard limits. All other files are below 500.
