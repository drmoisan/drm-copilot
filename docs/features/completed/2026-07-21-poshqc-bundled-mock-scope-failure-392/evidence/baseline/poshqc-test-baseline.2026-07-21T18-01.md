# PoshQC Test + Coverage Baseline (Issue #392)

Timestamp: 2026-07-21T18-01
Command: `mcp__drm-copilot__run_poshqc_test` (bundled entry point; scan folders resolved from `config/poshqc-scan.json`)
EXIT_CODE: 31
Output Summary:
- This is the fail-before defect baseline. The bundled entry point produces the reported failures.
- Test counts (from `artifacts/pester/pester-junit.xml`): tests=1338, failures=31, disabled(skipped)=9, errors=0. Passed = 1338 - 31 - 9 = 1298.
- Matches issue #392 report (1298 passed, 31 failed, 9 skipped). Every failure carries `RuntimeException: Mock data are not setup for this scope, what happened?`.
- Aggregate coverage (from `artifacts/pester/powershell-coverage.xml`, JaCoCo counters): LINE = 89.41% (covered=1849, missed=219, total=2068); INSTRUCTION = 89.02%; METHOD = 85.64%.
- Note: `scripts/powershell/PoshQC/PoshQC.Testing.psm1` is not yet in the coverage `Path` list; it is added in Phase 2 so the fix produces changed-line coverage evidence.
