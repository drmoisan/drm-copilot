# PowerShell Static Gate (P9-T7, restart)

Timestamp: 2026-11-17T11-20
Command: sh SCRATCH/issue-1035-p9t78-rerun.sh, static part: sh SCRATCH/issue-1035-p9t7-run.sh and sh SCRATCH/issue-1035-p9t7-format-log.sh (the same forms as powershell-static.2026-11-17T10-30.md)
EXIT_CODE: 0
Output Summary: Restart of the PowerShell loop from formatting after the P9-T8 coverage comparison added tests to three Pester suites (powershell-tests.2026-11-17T11-20.md records why). The earlier record powershell-static.2026-11-17T10-30.md stands for the tree before that change. One pass, no finding.

| Step | Observation | Findings |
| --- | --- | --- |
| Format check (no-op `-WriteFile`) | 1802 files; 1802 log lines, every one `Already formatted:`; 0 `Formatted:` lines | 0 |
| Analyzer (pssa.settings.psd1) | 1802 files; Invoke-PoshQCAnalyze logged 1 retry message (its built-in NullReferenceException retry) and completed without a throw | 0 total: Error 0, Warning 0, Information 0 |
