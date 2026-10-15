# Coverage Exclusion Check (Issue 887)

Timestamp: 2026-10-12T14-51
Command: git diff --name-only origin/main...HEAD -- config scripts/powershell/PoshQC/settings; git status --porcelain -- config scripts/powershell/PoshQC/settings
EXIT_CODE: 0
Output Summary:
- git diff --name-only origin/main...HEAD -- config scripts/powershell/PoshQC/settings: no output (exit 0).
- git status --porcelain -- config scripts/powershell/PoshQC/settings: no output (exit 0).
- No coverage configuration or PoshQC settings file was changed, committed or uncommitted; no coverage exclusion was added (AC-17, exclusion clause only; the numeric coverage clause is verified by P2-T11).
