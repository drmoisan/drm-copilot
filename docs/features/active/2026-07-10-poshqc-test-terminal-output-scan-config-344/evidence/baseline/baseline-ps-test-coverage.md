# Baseline — PowerShell Pester Test + Coverage

- Timestamp: 2026-07-10T17-46
- Command: MCP tool `mcp__drm-copilot__run_poshqc_test` (workspace_root = repo root)
- EXIT_CODE: 0

## Output Summary

- Pester result (`artifacts/pester/pester-junit.xml`): tests=1087, failures=0, errors=0, disabled=9. All executed tests passed.
- Coverage report (`artifacts/pester/powershell-coverage.xml`, JaCoCo format), report-level totals:
  - LINE: covered=1039, missed=73, total=1112 → line coverage = 93.44%
  - (Pester breakpoint coverage is line-based; no branch counter is emitted by the Pester coverage report.)

Baseline PowerShell line coverage 93.44% exceeds the 85% line threshold. No PowerShell production changes at baseline.
