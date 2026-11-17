# P0-T6 PowerShell Static Baseline

Timestamp: 2026-11-16T00-53
Command: sh SCRATCH/issue-1035-ps-static.sh (PowerShell 7: Import-Module scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCFormat -Root . -WriteFile { no-op } -Logger { capture }; then Invoke-ScriptAnalyzer -Settings scripts/powershell/PoshQC/settings/pssa.settings.psd1 over each file of Get-PoshQCFileList -Root .)
EXIT_CODE: 0
Output Summary: Format: 1793 files logged, 0 `Formatted:` log lines (no file needs formatting; no file rewritten, because the -WriteFile block is a no-op). Analyzer: 1793 files, 0 findings (Error 0, Warning 0, Information 0).

Note: a first analyzer attempt that recursed from the repository root into node_modules was stopped and replaced by the per-file run over the PoshQC file list; only the completed run is recorded here.
