# Scope Baseline (P0-T2)

Timestamp: 2026-11-03T23-07
Command: git fetch origin main; git merge-base origin/main HEAD; git branch --show-current; wc -l tests/scripts/dev-tools/run-actionlint.Tests.ps1; ls tests/scripts/dev-tools/run-actionlint.EnvironmentIsolation.Tests.ps1
EXIT_CODE: 0
Output Summary:
- MERGE_BASE: fe522d2cb05f2729f97fb189acc13259008d06a4
- Branch: bug/test-path-leak-run-actionlint
- TARGET physical line count: 523 (under 690)
- GUARD exists: no (ls reports no such file)
- DEVLIST size before P1-T1: 37 files directly under tests/scripts/dev-tools
