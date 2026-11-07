# QA Gate: PowerShell Analyze (loop pass 2) — Issue #1093

Timestamp: 2026-11-07T01-02
Command: sh SCRATCH/issue-1093-qc.sh Analyze <19 files> (PowerShell 7: `Invoke-ScriptAnalyzer -Path <file> -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 -Severity Error, Warning, Information` per file, over the 14 files of P6-T1 and the five bundle script copies)
EXIT_CODE: 0
Output Summary: 0 findings in each of the 19 files; TOTAL_FINDINGS: 0. This pass follows the P6-T13 self-review fix (entry suite state-write cases and the forwarder `.NOTES` section).
