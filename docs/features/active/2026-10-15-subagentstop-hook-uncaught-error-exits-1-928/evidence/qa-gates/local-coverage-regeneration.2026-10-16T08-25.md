# Local coverage report regeneration at the final code head (Issue #928)

Timestamp: 2026-10-16T08-25
Command: mcp__drm-copilot__run_poshqc_test (no scan_folders; configured scan set); poetry run pytest --cov --cov-branch --cov-report=term -q -p no:cacheprovider
EXIT_CODE: 0

Output Summary:
- Head: 6c2c717c30bb78a4c72456aedb61d9362f742e12 (origin/main merged; no item file changed by the merge).
- Purpose: answer cycle 3 re-audit findings F1/F2 (remediation-inputs.2026-10-16T07-53.md), which concern the gitignored local reports `artifacts/pester/powershell-coverage.xml` (previously from a partial two-folder run, 52.00%) and `artifacts/python/lcov.info` (previously absent). No tracked file changed.
- PowerShell (`artifacts/pester/powershell-coverage.xml`, MCP_DISPOSITION: ok, MTIME_UTC 2026-10-16T08-20): REPORT LINE missed 667 covered 11632 (94.58% repo-wide). Changed hooks present locally: validate-discovery-artifact-gate.ps1 100.00, validate-orchestrator-output.ps1 99.10, validate-planner-output.ps1 99.50, enforce-epic-wave-barrier.ps1 98.96; aggregate over those four 99.36 (469/472). Six changed hooks are absent from the local report (MATCHED 0) because the MCP runner reads the installed-extension coverage configuration; their PR-head CI figures (98.08-100.00) are recorded in s9-ci-coverage.2026-10-16T07-48.md.
- Python (`artifacts/python/lcov.info` written): 7110 passed, 6 skipped, 0 failed. TOTAL statements 17638, missed 1094, branches 6368, partial 505: line coverage 93.80% (16544/17638); branch coverage 88.11% (5611/6368, from artifacts/python/lcov.info BRH/BRF; corrected from an earlier 92.07% that misread the partial-branch column as missed branches, per review finding CR5-N2). The only changed Python file (tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py) is test support and outside the coverage denominator; changed production Python lines: 0.
- Thresholds: PowerShell line >= 85% met; Python line >= 85% and branch >= 75% met.
