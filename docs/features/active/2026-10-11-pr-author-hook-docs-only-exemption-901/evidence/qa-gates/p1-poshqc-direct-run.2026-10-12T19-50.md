# P1-T5 Direct PoshQC run

Timestamp: 2026-10-13T11-14
TIMESTAMP_RECONSTRUCTED: true
TIMESTAMP_ORIGINAL: 2026-10-13T11-30
TIMESTAMP_BOUNDS_UTC: 2026-10-13T10-51 .. 2026-10-13T11-14
TIMESTAMP_DERIVATION: lower: MCP-run coverage XML mtime epoch 1791888677 (2026-10-13T10:51:17Z); upper: first direct-run XML mtime epoch 1791890071 (2026-10-13T11:14:31Z) recorded in p1-direct-xml-regenerated.2026-10-12T19-50.md
Command: pwsh -NoProfile -NonInteractive -Command "Import-Module '<WORKTREE_ROOT>/scripts/powershell/PoshQC/PoshQC.psm1'; Invoke-PoshQCTest -Root '<WORKTREE_ROOT>'"
EXIT_CODE: NOT_OBSERVED
EXIT_CODE_OBSERVED_IN: p1-poshqc-direct-run-rerun.2026-10-12T19-50.md
Output Summary: The run used the CI form from .github/workflows/_poshqc.yml lines 41-42. The process exit code of this run was not observed because the executing agent exited before the run completed; the observed exit code of the re-run is recorded in p1-poshqc-direct-run-rerun.2026-10-12T19-50.md. No figure was taken from console output.
RUN_ROUTE: Invoke-PoshQCTest direct (CI form)
