# PowerShell Pester Coverage Baseline

Timestamp: 2026-09-02T21-23
Command: `mcp__drm_copilot__run_poshqc_test({"workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-31T07-29"})`
EXIT_CODE: 0

Runsettings: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
Configured CodeCoverage.Path: 89 ordered entries; UTF-8 newline-joined SHA-256 `1658a31cf9f270595e76152da781cd2a5750951ab80034efffc694a4f3df5d78`
Configured TestResult.OutputPath: `artifacts/pester/pester-junit.xml`
Configured CodeCoverage.OutputPath: `artifacts/pester/powershell-coverage.xml`
Invocation Scope: `scan_folders` omitted; repository `config/poshqc-scan.json` resolved `scripts`, `tests/powershell`, and `tests/scripts`.

Output Summary: The MCP call returned `ok: true`. The repository JUnit result recorded 3,932/3,932 tests passing, 0 errors, 0 failures, and 9 disabled tests. The repository CoverageGutters result recorded 94.763% line coverage (7,437/7,848), exceeding the 85% line threshold. Pester does not measure branch coverage, so the repository PowerShell branch-coverage exemption applies; production paths remain in the configured line-coverage denominator.
