# r3 PoshQC Format Baseline (P0-T14)

Timestamp: 2026-10-16T20-50
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $before = @(git status --porcelain); pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r3-baseline-format.log'); $code = $LASTEXITCODE; $after = @(git status --porcelain); ... exit $code' (SCRATCH/issue-953-r3-p0-t14.sh)
EXIT_CODE: 0
Output Summary:
- FORMATTED_LINES=0 (log lines starting with `Formatted: `)
- ALREADY_FORMATTED_LINES=808
- BEFORE_EQUALS_AFTER=True (git status --porcelain unchanged by the formatter)
- Result: PASS (no pre-existing format drift).
