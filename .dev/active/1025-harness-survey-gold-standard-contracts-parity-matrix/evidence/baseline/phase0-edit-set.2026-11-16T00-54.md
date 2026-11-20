# Phase 0 Edit Set and Configuration (X3)

Timestamp: 2026-11-16T00-54
Command: pwsh -NoProfile -File SCRATCH/issue-1025-entry.ps1 (git ls-tree -r --name-only origin/main; ConvertFrom-Json of config/poshqc-scan.json and config/poshqc-coverage.json; read of quality-tiers.yml; git ls-files for the two local-scope settings files)
EXIT_CODE: 0
Output Summary: 9 of 9 asserted checks hold.

| Check | Result |
| --- | --- |
| origin/main: config/harness-parity-matrix.json absent | PASS |
| origin/main: config/harness-parity-matrix.schema.json absent | PASS |
| origin/main: no path under scripts/harness/ | PASS |
| origin/main: no path under tests/scripts/harness/ | PASS |
| origin/main: no path under .agents/skills/*/references/ | PASS |
| config/poshqc-scan.json test.scanFolders holds tests/scripts | PASS |
| config/poshqc-coverage.json roots holds scripts | PASS |
| quality-tiers.yml has no scripts/harness entry | PASS |
| quality-tiers.yml last projects entry is scripts/ci (observed: scripts/ci) | PASS |

Information (Q5): .claude/settings.local.json tracked=True; .vscode/settings.json tracked=True; both excluded from the inventory either way.

EditSet: PASS
