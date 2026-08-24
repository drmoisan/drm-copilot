# R2 — PoshQC.ScanConfig.psm1 Coverage Instrumentation (Remediation Cycle 1)

- Issue: #344
- Timestamp: 2026-07-10T20-46
- EXIT_CODE: 0

## Commands

1. PowerShell toolchain via MCP (mandated wrapper), in order:
   - `mcp__drm-copilot__run_poshqc_format` — ok, no file changes to my edited region (workspace/bundled pairs remained byte-identical).
   - `mcp__drm-copilot__run_poshqc_analyze` — ok, no findings.
   - `mcp__drm-copilot__run_poshqc_test` — ok; JUnit reported Tests=1103, Failures=0, Errors=0.
2. Coverage regeneration reflecting the current workspace runsettings:
   - `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -DisableKoverageCopy`
3. Coverage XML parse:
   - `[xml]$x = Get-Content artifacts/pester/powershell-coverage.xml; $x.SelectNodes('//sourcefile') | Where-Object { $_.name -like '*PoshQC.ScanConfig.psm1' }` (per-line `ci` count aggregation)

## Output Summary

- Pester result (authoritative workspace run): Tests Passed 1094, Failed 0, Skipped 9 (total 1103). 0 failures.
- Overall coverage: 89.03% across 27 instrumented files.
- `PoshQC.ScanConfig.psm1` now appears as an instrumented coverage sourcefile.
  - Covered lines: 44; Total instrumented lines: 46; **Line coverage = 95.65%** (>= 85% threshold: PASS).
  - Branch data: not emitted. The Pester `CoverageGutters` output format is command/line-based and emits no branch counters. Per the plan Conventions, this is the authorized line-based-instrument limitation note; it is not a skip. The recorded line figure is the threshold value.
- Total sourcefiles in the regenerated coverage denominator: 27 (previously 16; the workspace runsettings now includes `PoshQC.ScanConfig.psm1` and the other current `CodeCoverage.Path` entries).

## Note on the MCP Wrapper vs. the Regenerated Artifact

The `mcp__drm-copilot__run_poshqc_test` wrapper executes from the currently-running MCP server's frozen bundled resources (`resources/templates/run-poshqc-test.ps1` imports PoshQC via `$PSScriptRoot\..\powershell\PoshQC`). That bundled snapshot predates this cycle's `CodeCoverage.Path` addition, so the wrapper-produced coverage XML listed only 16 sourcefiles and omitted `PoshQC.ScanConfig.psm1`. This is a frozen-bundle tooling-state limitation of the installed MCP server, not a breakpoint-binding failure.

The R2 contingency (breakpoints fail to bind after the AST refactor) did NOT trigger. A controlled Pester coverage run against the workspace path confirmed the AST-based `[Parser]::ParseFile(...).GetScriptBlock()` dot-sourcing lets breakpoints bind (CommandsAnalyzed=53, CommandsExecuted=49, 92.45% in the focused-test run; 95.65% line coverage in the full-suite run). The workspace `Invoke-PoshQCTest` invoked above performs the identical underlying operation the wrapper runs, but against the live workspace resources that contain the current runsettings, producing the authoritative `artifacts/pester/powershell-coverage.xml` (mtime 2026-07-10T20:31:17).

The installed extension/MCP-server bundle converges on the reconciled resources only at the next packaged release (FR2.5 residual limitation, carried into the PR description).
