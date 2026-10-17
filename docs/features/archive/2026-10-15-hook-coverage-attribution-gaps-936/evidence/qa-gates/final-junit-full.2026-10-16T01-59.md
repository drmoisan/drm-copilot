# Final full-run row results (P2-T5, AC-6)

Timestamp: 2026-10-16T01-59
Command: poetry run python -I SCRATCH/cov936.py junit SCRATCH/p2-full/pester-junit.xml
EXIT_CODE: 0
Output Summary: TARGETS-PASSED=True; TOTAL=10376 FAILED=0.

TOTAL=10376 FAILED=0
TARGET hook-import-failure-exemptions.FailClosed.Tests.ps1 | H2 codex preimplementation gate denies count=2 passed=2 expected=2
TARGET enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 | ES-D1 count=1 passed=1 expected=1
TARGET enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1 | ES-D2 count=1 passed=1 expected=1
TARGETS-PASSED=True

NEW-FAILURES: none
