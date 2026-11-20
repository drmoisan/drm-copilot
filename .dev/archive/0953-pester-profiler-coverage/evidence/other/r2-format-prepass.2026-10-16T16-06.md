# r2 PoshQC format pre-pass (P4-T1)

Timestamp: 2026-10-16T16-06
Command: sh "SCRATCH/issue-953-r2-p4-t1.sh" (pwsh text: $before = (git status --porcelain) -join "`n"; pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCFormat -Root (Get-Location).Path" *> (Join-Path $S 'issue-953-r2-prepass-format.log'); $code = $LASTEXITCODE; $after = (git status --porcelain) -join "`n"; counts; exit $code)
EXIT_CODE: 0
Output Summary: FORMAT_EXIT=0; FORMATTED_LINES=0 (no log line starts with "Formatted: ", so no file was reformatted and no path needs to be listed); ALREADY_FORMATTED_LINES=808; BEFORE_EQUALS_AFTER=True.
