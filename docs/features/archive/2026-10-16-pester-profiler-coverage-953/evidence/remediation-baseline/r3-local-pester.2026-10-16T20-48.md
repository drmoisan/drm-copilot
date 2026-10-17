# r3 Local Pester (P0-T2)

Timestamp: 2026-10-16T20-48
Command: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; "RANGE=" + (@(Get-Module -ListAvailable -FullyQualifiedName @{ ModuleName = 'Pester'; ModuleVersion = '5.9.0'; MaximumVersion = '5.99.99' } | ForEach-Object { $_.Version.ToString() }) -join ','); exit $LASTEXITCODE' (SCRATCH/issue-953-r3-p0-t2.sh)
EXIT_CODE: 0
Output Summary:
- RANGE=5.9.0
- Result: PASS (the range list contains 5.9.0).
