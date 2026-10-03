# P0-T11 Baseline format (check-only)

Timestamp: 2026-10-03T09-39
Command: pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path -WriteFile { param([string] $Path, [string] $Content) }' *> "SCRATCH/format-baseline.log"; $LASTEXITCODE; then Select-String counts of '^Formatted: ' and '^Already formatted: '
EXIT_CODE: 0
Output Summary:
- Format run exit code: 0
- 'Formatted: ' count: 0
- 'Already formatted: ' count: 614
- Result: PASS (no pre-existing format drift; no-op -WriteFile injected, nothing rewritten)
