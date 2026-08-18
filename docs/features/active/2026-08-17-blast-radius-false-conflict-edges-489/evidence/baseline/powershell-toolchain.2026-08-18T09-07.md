# P0-T9..T10 — PowerShell Toolchain Baseline

Timestamp: 2026-08-18T09-07

## P0-T9 Analyzer
Command: MCP tool `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root=c:\Users\DanMoisan\repos\drm-copilot`
EXIT_CODE: 0
Output Summary: `{"ok":true,...,"summary":"Ran bundled PoshQC analyze against 'c:\Users\DanMoisan\repos\drm-copilot'."}` — completed without reported findings.

## P0-T10 Tests and Coverage
Command: MCP tool `mcp__drm-copilot__run_poshqc_test` with `workspace_root=c:\Users\DanMoisan\repos\drm-copilot`
EXIT_CODE: 0
Output Summary: 2740 tests, 0 errors, 0 failures, 9 disabled, 137.46s
(`artifacts/pester/pester-junit.xml`, run stamped 2026-08-18 09:13:37).
Numeric coverage headline from the JaCoCo report `artifacts/pester/powershell-coverage.xml`
report-level counters: LINE covered 5098, missed 217 => **95.92% line coverage**
(INSTRUCTION covered 7144, missed 315 => 95.78%).
Branch coverage is NOT measured by Pester; per `.claude/rules/quality-tiers.md` PowerShell is
exempt from the branch threshold and only the >= 85% line threshold applies. Line coverage is
above threshold.
