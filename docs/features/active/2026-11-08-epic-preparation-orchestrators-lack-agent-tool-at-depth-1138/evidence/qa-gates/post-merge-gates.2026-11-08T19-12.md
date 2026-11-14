# Post-merge gates (#1138)

Timestamp: 2026-11-08T19-12
Command: sh SCRATCH/issue-1138-gates.sh (env -u VIRTUAL_ENV poetry run pytest -n auto --cov --cov-branch --cov-report=json; then Import-Module scripts/powershell/PoshQC/PoshQC.psd1 and Invoke-PoshQCParallelTest)
EXIT_CODE: 0
Output Summary:
- Head: merge commit 1db21f006 (origin/main merged; PINNED_FROZEN_SURFACE_HASHES conflict with #1136 resolved).
- pytest -n auto: 16560 passed, 6 skipped, 0 failed; line 97.11% (34296/35317), branch 94.37% (12649/13404); equal to the Phase 0 baseline.
- Invoke-PoshQCParallelTest: ExitCode 0, 8 workers; JUnit tests=20293, failures=0; repo-wide line coverage 95.66% (baseline 95.62%).
- .claude/hooks/epic-invocation-nesting-depth.ps1: 100.00% (19/19). .claude/hooks/enforce-epic-invocation-origin.ps1: 90.79% (69/76), baseline 90.41%.
- Pre-commit static check on the resolved file: ruff check and black --check clean.
