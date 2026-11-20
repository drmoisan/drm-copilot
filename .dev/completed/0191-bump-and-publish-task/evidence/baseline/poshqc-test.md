# Baseline — PoshQC Test (Pester) with Coverage

Timestamp: 2026-06-16T20-33
Command: mcp__drm-copilot__run_poshqc_test (workspace root c:\Users\DanMoisan\repos\drm-copilot)
EXIT_CODE: 0

Output Summary:
- Pester result (artifacts/pester/pester-junit.xml): tests=601, failures=0, errors=0, disabled=9. All tests pass.
- Coverage (artifacts/pester/powershell-coverage.xml, JaCoCo/CoverageGutters format, report-level counters):
  - LINE: covered=275, missed=9, total=284 -> line coverage = 96.83%.
  - INSTRUCTION: covered=420, missed=13, total=433 -> 96.99%.
  - METHOD: covered=18, missed=0. CLASS: covered=5, missed=0.
  - BRANCH counter: not emitted at report level by the current CoverageGutters output (count of BRANCH counters = 0). Branch coverage is therefore not represented in the repo-wide coverage artifact for this baseline.

Coverage Scope Note:
The repo-wide PoshQC coverage scope is pinned in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (CodeCoverage.Path) to five hook files:
`.claude/hooks/validate-bash.ps1`, `check-python-test-purity.ps1`, `check-powershell-test-purity.ps1`, `enforce-python-batch-budget.ps1`, `enforce-powershell-batch-budget.ps1`.
The new production file `scripts/dev-tools/Invoke-FullRelease.ps1` is outside this pinned coverage scope. The pinned scope is repository policy (the runsettings file) and is not modified by this feature. New/changed-code coverage for `Invoke-FullRelease.ps1` is measured separately via a targeted Pester coverage run in Phase 2 (P2-T3 / P2-T4) so the coverage-delta evidence reports a numeric new-code coverage value as required.
