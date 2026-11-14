# PowerShell Final QC Static Loop — remediation cycle 2, [P2-T1]

Timestamp: 2026-11-14T07-22
Command: sh SCRATCH/issue-1156-static.sh (check-only Invoke-Formatter comparison and Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 over the adapter, its bundle copy, `Invoke-RegenerationPath.ProcessStart.Tests.ps1`, and `regeneration-path-skill-contract.Tests.ps1`); sh SCRATCH/issue-1156-leak.sh (Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCLeakScan -Root <item worktree root>)
EXIT_CODE: 0
Output Summary:
- Step 1, format (check-only): exit 0; 4 files, 0 formatter differences.
- Step 2, analyze (PSScriptAnalyzer): exit 0; 0 findings across the 4 files.
- Step 3, type check: not applicable (PowerShell).
- Step 4, leak scan: exit 0; `Leak scan: 802 files, 75 findings, 73 exempt, 2 allowlisted, 0 failures.` (one configuration warning: scan folder `tests/powershell` does not exist and is skipped).
- Adapter 792 logical lines; the four files are unchanged by the loop (check-only).
- No Python or TypeScript source changed in this cycle, so no Python or TypeScript static artifact applies.
