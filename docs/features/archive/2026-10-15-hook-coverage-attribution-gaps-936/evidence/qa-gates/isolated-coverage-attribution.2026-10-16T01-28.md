# Isolated coverage attribution (P1-T8, AC-4)

Timestamp: 2026-10-16T01-28
Command: poetry run python -I SCRATCH/cov936.py lines SCRATCH/p1-scoped/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: CODEX-PACKAGE-COUNT=1, REQUIRED-ATTRIBUTED=True. Modes line 41 and epic-scope lines 206 and 207 are ci=1 ATTRIBUTED in a coverage run scoped to tests/scripts/codex-hooks. The elements come from the package whose name ends with /.codex/hooks, not the .claude/hooks same-basename entries. The P1-T7 derived EXIT_CODE was 0 with no failing rows (TOTAL=1695 FAILED=0), so there are no failing rows or P0-T11 explanations to record.

CODEX-PACKAGE-COUNT=1
LINE enforce-orchestration-preimplementation-gate-modes.ps1:41 mi=0 ci=1 ATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:183 mi=0 ci=1 ATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:190 mi=0 ci=1 ATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:191 mi=0 ci=1 ATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:201 mi=0 ci=1 ATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:206 mi=0 ci=1 ATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:207 mi=0 ci=1 ATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:209 mi=0 ci=1 ATTRIBUTED
REQUIRED-ATTRIBUTED=True

Contrast (from the Phase 0 full run, coverage-full baseline artifact): in the unscoped full run the same lines 41, 183, 190, 191, 206, 207, and 209 were ci=0 UNATTRIBUTED (REQUIRED-ATTRIBUTED=False), reproducing the issue #936 gap.
