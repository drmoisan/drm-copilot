# r3 Formatter Prepass (P4-T6)

Timestamp: 2026-10-16T22-03
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; $before = @(git status --porcelain); pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r3-prepass-format.log'); $code = $LASTEXITCODE; $after = @(git status --porcelain); ... exit $code' (SCRATCH/issue-953-r3-p4-t6.sh)
EXIT_CODE: 0
Output Summary:
- FORMATTED_LINES=0 (no log line starts with `Formatted: `; none to list)
- ALREADY_FORMATTED_LINES=808
- BEFORE_EQUALS_AFTER=True
- Result: PASS (no file was reformatted, so no path lies outside PS_CYCLE_FILES).
