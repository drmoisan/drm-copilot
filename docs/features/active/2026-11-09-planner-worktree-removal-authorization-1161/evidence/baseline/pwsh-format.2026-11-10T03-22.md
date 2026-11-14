# PowerShell format baseline ([P0-T1])

Timestamp: 2026-11-10T03-22
Command: sh SCRATCH/issue-1161-pwsh-static.sh (PowerShell 7; for every .ps1, .psm1, .psd1 under `.claude/hooks` and `.codex/hooks`, compares the file text with `Invoke-Formatter -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1` output; check mode, writes nothing)
EXIT_CODE: 0
Output Summary: 157 files checked; 0 files would change. Finding count 0.
