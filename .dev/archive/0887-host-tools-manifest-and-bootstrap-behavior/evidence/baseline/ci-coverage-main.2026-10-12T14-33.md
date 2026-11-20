# Baseline CI Coverage from main (Issue 887)

Timestamp: 2026-10-12T14-32
Timestamp note: the filename timestamp 2026-10-12T14-33 was estimated rather than read from the system clock; 2026-10-12T14-32 is the file modification time recorded when the artifact was written.
Supplied-By: parallel-orchestrator
Run id: 38286041896 (https://github.com/drmoisan/drm-copilot/actions/runs/38286041896)
headSha: 88946d10a47911a426abec906b2b2163814f5950
Glob match (pattern `SCRATCH/887/ci-main-887/**/powershell-coverage.xml`): `SCRATCH/887/ci-main-887/powershell-coverage.xml` (exactly one match)
Command: poetry run python SCRATCH/887/coverage_perfile_887.py SCRATCH/887/ci-main-887/powershell-coverage.xml HostTooling.psm1 HostBootstrapWorkspace.psm1 HostBootstrap.psm1 publish-sideloaded-extension.ps1
EXIT_CODE: 0
Output Summary:
- FILE HostTooling.psm1 covered=36 missed=2 pct=94.74
- FILE HostBootstrapWorkspace.psm1 covered=70 missed=0 pct=100.00
- FILE HostBootstrap.psm1 covered=155 missed=0 pct=100.00
- FILE publish-sideloaded-extension.ps1 covered=24 missed=0 pct=100.00
- Four FILE lines, no MISSING line; package selected by suffix `scripts/dev-tools`.
