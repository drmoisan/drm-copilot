# Baseline — Pester (with coverage)

- Timestamp: 2026-06-24T15-35
- Issue: #231

Command (suite run via MCP): `mcp__drm-copilot__run_poshqc_test` (scan_folders: `tests/scripts/claude-hooks`)
Command (targeted coverage): `Invoke-Pester` with `CodeCoverage.Path = .claude/hooks/enforce-pr-author-skill.ps1` over `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1`

EXIT_CODE: 0

## Output Summary

- enforce-pr-author-skill suite: 29 tests, 0 failures, 0 errors (from `artifacts/pester/pester-junit.xml`).
- Full repository suite: 261 tests, 0 failures, 0 errors.
- Targeted line/command coverage on `enforce-pr-author-skill.ps1`: 42 of 49 commands executed = 85.71% (baseline).
- Branch coverage: Pester's bundled coverage reports command/line coverage only; it does not emit a separate branch-coverage metric for PowerShell. Branch-completeness is verified by scenario enumeration in the test suite (Cases A/B/C plus the new D/E/F/malformed/valid scenarios added in Phase 1).

## Note on bundled coverage scope

The bundled PoshQC `run_poshqc_test` coverage configuration (`artifacts/pester/powershell-coverage.xml`) instruments only a fixed subset of hook/script files and does NOT include `enforce-pr-author-skill.ps1`. Numeric coverage for this hook is therefore obtained via a targeted `Invoke-Pester` `CodeCoverage.Path` run, as recorded above.
