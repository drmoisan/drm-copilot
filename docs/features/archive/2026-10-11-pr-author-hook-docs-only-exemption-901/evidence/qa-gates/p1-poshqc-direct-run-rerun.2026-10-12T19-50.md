# P1-T5 re-run: direct PoshQC test run (second invocation)

Timestamp: 2026-10-13T11-28
TIMESTAMP_RECONSTRUCTED: true
TIMESTAMP_ORIGINAL: 2026-10-13T11-32
TIMESTAMP_BOUNDS_UTC: 2026-10-13T11-14 .. 2026-10-13T11-28
TIMESTAMP_DERIVATION: lower: first direct-run XML mtime epoch 1791890071 (2026-10-13T11:14:31Z); upper: re-run XML mtime epoch 1791890931 (2026-10-13T11:28:51Z) recorded in p1-direct-xml-regenerated-rerun.2026-10-12T19-50.md
Command: pwsh -NoProfile -NonInteractive -Command "Import-Module '<WORKTREE_ROOT>/scripts/powershell/PoshQC/PoshQC.psm1'; Invoke-PoshQCTest -Root '<WORKTREE_ROOT>'"
EXIT_CODE: 0
Output Summary: The run used the CI form from .github/workflows/_poshqc.yml lines 41-42. Exit code 0, read from the background completion notification, means Pester completed with no failed test and no thrown error. No figure was taken from console output for acceptance purposes.
RUN_ROUTE: Invoke-PoshQCTest direct (CI form)
INVOCATION: 2 (second invocation)
RERUN_REASON: the first direct run (evidence p1-poshqc-direct-run.2026-10-12T19-50.md) was orphaned when the executing agent exited; its junit root showed tests=10322 failures=0 errors=0 but its process exit code was never observed, so the operator directed one re-run to make the exit code observable.
