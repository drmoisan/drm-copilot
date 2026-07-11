# PowerShell Test Coverage — R2 Closure Gate (Remediation Cycle 1)

- Issue: #344
- Timestamp: 2026-07-10T20-46
- EXIT_CODE: 0

## Commands

1. `mcp__drm-copilot__run_poshqc_test` (mandated MCP wrapper) — `ok: true`; JUnit reported Tests=1103, Failures=0, Errors=0.
2. Authoritative coverage regeneration reflecting the current workspace runsettings:
   `Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path -DisableKoverageCopy`
3. Coverage XML parse: `[xml]$x = Get-Content artifacts/pester/powershell-coverage.xml` filtered to `*PoshQC.ScanConfig.psm1`, per-line `ci` aggregation.

## Output Summary

- Pester result (authoritative workspace run): Tests Passed 1094, Failed 0, Skipped 9 (total 1103). 0 failures. This confirms the 1103-test authoritative PoshQC gate is not regressed by the R2 refactor.
- Overall coverage: 89.03% across 27 instrumented files.
- `PoshQC.ScanConfig.psm1` per-file line coverage: **44/46 = 95.65%** (>= 85% threshold: PASS).
- Branch coverage: not emitted. Pester `CoverageGutters` output is command/line-based and emits no branch counters. Per the plan Conventions, this is the authorized line-based-instrument limitation note (not a skip); the recorded line figure is the threshold value.
- Coverage XML mtime: 2026-07-10T20:39:40.

## MCP Wrapper vs. Authoritative Artifact (same as P1-T4)

The MCP wrapper runs from the installed server's frozen bundled resources, whose runsettings predate this cycle's `CodeCoverage.Path` addition; its coverage XML lists only 16 sourcefiles and omits `PoshQC.ScanConfig.psm1`. This is a frozen-bundle tooling-state limitation, not a breakpoint-binding failure (R2 contingency did not trigger). The workspace `Invoke-PoshQCTest` performs the identical underlying operation against the live workspace runsettings, producing the authoritative XML that includes `PoshQC.ScanConfig.psm1` at 95.65% line coverage. The installed bundle converges at the next packaged release (FR2.5 residual, carried into the PR description).
