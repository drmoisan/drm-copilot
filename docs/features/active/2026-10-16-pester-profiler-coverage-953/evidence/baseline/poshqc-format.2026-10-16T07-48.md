# PoshQC Format Baseline (issue #953, P0-T20)

Timestamp: 2026-10-16T07-48
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $before = (git status --porcelain) -join "`n"; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-baseline-format.log'); $exit = $LASTEXITCODE; $after = (git status --porcelain) -join "`n"; ...count lines starting with "Formatted: " and "Already formatted:"...; exit $exit' (script SCRATCH/issue-953-p0-t20.sh, run with sh)
EXIT_CODE: 0
Output Summary: Formatter exited 0. Log lines starting with "Formatted: ": 0. Log lines starting with "Already formatted:": 782 (of 782 log lines). git status --porcelain before equals after: True. No pre-existing format drift.

PRE_EXISTING_FORMAT_DRIFT: none
