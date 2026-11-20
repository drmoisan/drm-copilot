# DEC header-token baseline (P0-T6) [expect-fail]

Timestamp: 2026-10-16T00-27
Command: poetry run python -I SCRATCH/cov936.py header decision tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Decision.Tests.ps1
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: HEADER-TOKENS=INCOMPLETE, FILE-LINES=97. One token present (the epic-scope path), fifteen absent (expected before the change).

FILE-LINES=97
TOKEN-ABSENT #936
TOKEN-PRESENT .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1
TOKEN-ABSENT 183
TOKEN-ABSENT 190
TOKEN-ABSENT 191
TOKEN-ABSENT 206
TOKEN-ABSENT 207
TOKEN-ABSENT 209
TOKEN-ABSENT ES-D1
TOKEN-ABSENT ES-D2
TOKEN-ABSENT exact-reason
TOKEN-ABSENT Pester
TOKEN-ABSENT 5.x
TOKEN-ABSENT breakpoint
TOKEN-ABSENT compiled
TOKEN-ABSENT recompilation
HEADER-TOKENS=INCOMPLETE
