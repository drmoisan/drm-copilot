# r2 local Pester precondition (P0-T2)

Timestamp: 2026-10-16T15-32
Command: sh "SCRATCH/issue-953-r2-p0-t2.sh" (body: export MSYS_NO_PATHCONV=1; pwsh -NoProfile -Command '$S = "SCRATCH"; "RANGE=" + (@(Get-Module -ListAvailable -FullyQualifiedName @{ ModuleName = '\''Pester'\''; ModuleVersion = '\''5.9.0'\''; MaximumVersion = '\''5.99.99'\'' } | ForEach-Object { $_.Version.ToString() }) -join '\'','\'')')
EXIT_CODE: 0
Output Summary: RANGE=5.9.0 (non-empty; an in-range Pester 5.9.0 to 5.99.99 is installed, so the default EnsureModule seam used by FULL_RUN is satisfied).
