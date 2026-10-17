# Existing Codex Batch-Budget Tests After Fix (#769, P5-T6)

Timestamp: 2026-09-29T14-39
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1
EXIT_CODE: 0
Output Summary:
TotalCount=41
PassedCount=41
FailedCount=0
41 = 48 (P0-T16) minus the 7 PowerShell cap cases moved to the Python-only Context (17 shared cases x 2 rows + 7 Python-only cases).
P5-T7: pair-hashes over the XHOOK bundle pair printed `PAIR-SUMMARY pairs=1 unequal=0`.
