# r3 PoshQC Analyze Baseline (P0-T15)

Timestamp: 2026-10-16T20-52
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r3-baseline-analyze.log'); $code = $LASTEXITCODE; Get-Content -LiteralPath (Join-Path $S 'issue-953-r3-baseline-analyze.log'); "ANALYZE_EXIT=$code"; exit $code' (SCRATCH/issue-953-r3-p0-t15.sh)
EXIT_CODE: 0
Output Summary:
- Log: `PSScriptAnalyzer passed: no findings under <worktree root>`
- Result: PASS (zero findings).
