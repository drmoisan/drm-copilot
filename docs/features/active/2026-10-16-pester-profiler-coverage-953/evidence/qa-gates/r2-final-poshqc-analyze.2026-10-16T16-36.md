# r2 final PoshQC analyze (P5-T2, loop pass 2)

Timestamp: 2026-10-16T16-36
Command: sh "SCRATCH/issue-953-r2-p5-t2.sh" (pwsh text: pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCAnalyze -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r2-final-analyze.log'); $code = $LASTEXITCODE; exit $code)
EXIT_CODE: 0
Output Summary: ANALYZE_EXIT=0; the log contains "PSScriptAnalyzer passed: no findings under" once (AC-07: zero findings). Loop pass 2.
