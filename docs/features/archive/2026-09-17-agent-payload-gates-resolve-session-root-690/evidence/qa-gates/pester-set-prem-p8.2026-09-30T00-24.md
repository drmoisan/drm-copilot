# Phase 8 SET-PREM (P8-T11)

Timestamp: 2026-09-30T00-24
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path <SET-PREM including G6, repository-relative paths>
EXIT_CODE: 0
Output Summary:
- TotalCount=151
- PassedCount=151
- FailedCount=0
- BASE_PREM 145 plus 6 = 151; no FAILED line.
- A first invocation with absolute /c/... paths reported TotalCount=49 because only the first comma-separated element was path-converted; that run was a command-line defect, not a suite result, and is superseded by this run.
