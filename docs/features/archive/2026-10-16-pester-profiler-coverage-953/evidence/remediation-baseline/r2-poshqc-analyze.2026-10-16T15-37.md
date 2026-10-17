# r2 PoshQC analyze baseline (P0-T15)

Timestamp: 2026-10-16T15-37
Command: sh "SCRATCH/issue-953-r2-p0-t15.sh" (pwsh text: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r2-baseline-analyze.log'); $code = $LASTEXITCODE; exit $code)
EXIT_CODE: 0
Output Summary: ANALYZE_EXIT=0; the log contains the literal "PSScriptAnalyzer passed: no findings under" once (zero findings).
