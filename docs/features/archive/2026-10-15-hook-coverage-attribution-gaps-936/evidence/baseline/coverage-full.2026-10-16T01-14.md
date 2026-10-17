# Baseline line coverage, full run (P0-T13)

Timestamp: 2026-10-16T01-14
Command: poetry run python -I SCRATCH/cov936.py counter SCRATCH/p0-full/powershell-coverage.xml
EXIT_CODE: 0
Output Summary: REPORT-LINE missed=667 covered=11613 LinePercent=94.57. PowerShell has no branch-coverage gate, so no branch value is recorded.

Supporting command: poetry run python -I SCRATCH/cov936.py lines SCRATCH/p0-full/powershell-coverage.xml
Supporting EXIT_CODE: 1 (REQUIRED-ATTRIBUTED=False in the full run, the issue #936 gap; recorded for reference)
CODEX-PACKAGE-COUNT=1
LINE enforce-orchestration-preimplementation-gate-modes.ps1:41 mi=1 ci=0 UNATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:183 mi=1 ci=0 UNATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:190 mi=1 ci=0 UNATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:191 mi=1 ci=0 UNATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:201 mi=0 ci=1 ATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:206 mi=1 ci=0 UNATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:207 mi=1 ci=0 UNATTRIBUTED
LINE enforce-orchestration-preimplementation-gate-epic-scope.ps1:209 mi=1 ci=0 UNATTRIBUTED
REQUIRED-ATTRIBUTED=False
