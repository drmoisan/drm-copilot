# r2 PoshQC format baseline (P0-T14)

Timestamp: 2026-10-16T15-37
Command: sh "SCRATCH/issue-953-r2-p0-t14.sh" (pwsh text: $before = (git status --porcelain) -join "`n"; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r2-baseline-format.log'); $code = $LASTEXITCODE; $after = (git status --porcelain) -join "`n"; counts of 'Formatted: ' and 'Already formatted:' log lines; $before -ceq $after; exit $code)
EXIT_CODE: 0
Output Summary: FORMAT_EXIT=0; FORMATTED_LINES=0 (lines starting with "Formatted: "); ALREADY_FORMATTED_LINES=808; BEFORE_EQUALS_AFTER=True. No pre-existing format drift.
