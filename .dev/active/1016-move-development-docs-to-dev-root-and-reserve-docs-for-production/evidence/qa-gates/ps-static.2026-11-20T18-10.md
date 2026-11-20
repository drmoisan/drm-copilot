# Final QC Static: PowerShell ([P5-T1], stage B)

Timestamp: 2026-11-20T18-10
Command: sh SCRATCH/issue-1016-psstatic2.sh SCRATCH/p5e-ps (pwsh: Invoke-PoshQCFormat from scripts/powershell/PoshQC/PoshQC.psd1 with a non-writing -WriteFile seam; Invoke-ScriptAnalyzer run directly per file with scripts/powershell/PoshQC/settings/pssa.settings.psd1, retrying a file once when the analyzer throws), pass 5 of the final QA loop
EXIT_CODE: 0
Output Summary: Formatter over 1866 files, 0 `Formatted:` lines (formatted_drift=0); analyzer over 1866 files, 0 findings, 0 retries, 0 failures. Type checking is not applicable to PowerShell.

| Step | Command | Exit | Findings |
| --- | --- | --- | --- |
| Format | Invoke-PoshQCFormat, non-writing seam | 0 | 0 `Formatted:` lines of 1866 files |
| Lint | Invoke-ScriptAnalyzer per file | 0 | 0 findings, 0 retried, 0 failed |
| Type check | n/a | n/a | not applicable |

The analyzer step retries a file once on an analyzer exception because passes 1 and 3 aborted on a NullReferenceException thrown by `Invoke-ScriptAnalyzer` with no file change in between, while pass 2 and a per-file diagnostic run analyzed every file with 0 errors (`evidence/other/final-qa-loop.2026-11-20T18-10.md`). In this pass no file needed the retry.
