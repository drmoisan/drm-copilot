# PowerShell Pester Coverage Baseline

Timestamp: 2026-07-09T09-59
Command: mcp__drm-copilot__run_poshqc_test (workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-09T09-18)
EXIT_CODE: 0
Output Summary:
- Pester results (artifacts/pester/pester-junit.xml): tests=1073, errors=0, failures=0, disabled=9, time=50.833s. All passing.
- Coverage (artifacts/pester/powershell-coverage.xml JaCoCo report-level aggregate):
  - LINE: covered=1006, missed=68 -> 93.67% line coverage.
  - INSTRUCTION: covered=1399, missed=112 -> 92.59%.
  - METHOD: covered=91, missed=10.
  - CLASS: covered=15, missed=0.
- Note: the JaCoCo report format emitted by PoshQC does not include a BRANCH counter;
  line coverage is the authoritative numeric headline. Baseline exceeds the 85% line gate.
