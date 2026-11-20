# Scoped baseline failing set (P0-T11)

Timestamp: 2026-10-16T00-32
Command: poetry run python -I SCRATCH/cov936.py junit SCRATCH/p0-scoped/pester-junit.xml
EXIT_CODE: 0
Output Summary: TOTAL=1695 FAILED=0; TARGETS-PASSED=True.

BASE-SCOPED-FAILS
none

No row failed in this scoped run, so no ambient-state cause applies (the caller's earlier ambient preparation-mode checkpoint failures did not recur on this worktree).

TOTAL=1695 FAILED=0
TARGET hook-import-failure-exemptions.FailClosed.Tests.ps1 | H2 codex preimplementation gate denies count=2 passed=2 expected=2
TARGET enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 | ES-D1 count=1 passed=1 expected=1
TARGET enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 | ES-D2 count=1 passed=1 expected=1
TARGETS-PASSED=True
