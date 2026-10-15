# P1-T5 Direct PoshQC run

Timestamp: 2026-10-13T11-30
Command: pwsh -NoProfile -NonInteractive -Command "Import-Module '<WORKTREE_ROOT>/scripts/powershell/PoshQC/PoshQC.psm1'; Invoke-PoshQCTest -Root '<WORKTREE_ROOT>'"
EXIT_CODE: 0
Output Summary: The run used the CI form from .github/workflows/_poshqc.yml lines 41-42. Exit code 0 means Pester completed with no failed test and no thrown error. No figure was taken from console output.
RUN_ROUTE: Invoke-PoshQCTest direct (CI form)
