# Codex Python Routing Tests After the Fix (P6-T5)

Timestamp: 2026-09-29T20-18
Command: sh SCRATCH/run-ps.sh SCRATCH/pester-counts.ps1 -Path tests/scripts/codex-hooks/codex-python-batch-budget-routing.Tests.ps1
EXIT_CODE: 0
Output Summary:
TotalCount=34
PassedCount=34
FailedCount=0
All 34 Appendix B8 cases pass (13 direct-mode including D3 and the nine-row fallback table, 5 large-path L1-L3, 3 test-path, 4 override, 6 seam including S3, 3 entry-point E1-E3). The same 34 cases failed before the fix (codex-python-routing-before-fix.2026-09-29T20-10.md).
