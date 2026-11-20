# PoshQC Pester Test Baseline Evidence

- Timestamp: 2026-06-21T12-06
- Issue: #221
- Task: [P0-T5]

## Command

```
mcp__drm-copilot__run_poshqc_test
```

- Scan folders: scripts/dev-tools, tests/scripts/dev-tools
- EXIT_CODE: 0

Supplemental targeted coverage measurement (per-file numeric coverage for the in-scope production file; the MCP gate above remains authoritative for pass/fail):

```
Invoke-Pester -Configuration (CodeCoverage.Path = scripts/dev-tools/Invoke-FullRelease.ps1; Run.Path = tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1; OutputFormat = JaCoCo)
```

- EXIT_CODE: 0
- JaCoCo output: artifacts/pester/fullrelease-baseline-coverage.xml

## Output Summary

- MCP test run: `ok: true`. All tests passed. Full suite: 318 tests, 0 failures, 0 errors. Invoke-FullRelease suite: 21 tests, 0 failures, 0 errors.
- Per-file baseline coverage for `scripts/dev-tools/Invoke-FullRelease.ps1`:
  - LINE coverage: 91.67% (covered 66, missed 6, total 72).
  - INSTRUCTION coverage: 88.54% (covered 85, missed 11, total 96).
  - METHOD coverage: 62.50% (covered 5, missed 3, total 8).
- Branch coverage: Pester's coverage model (used by the PoshQC MCP toolchain) does not emit a distinct JaCoCo BRANCH counter. Line coverage and instruction coverage are the available numeric metrics. Instruction coverage (88.54%) is the closest decision-path-discriminating metric reported. Line coverage 91.67% exceeds the >= 85% threshold.

## Notes on Coverage Scope

The bundled PoshQC MCP test tool emits aggregate coverage artifacts (`artifacts/pester/powershell-coverage.xml`, `.koverage.xml`) scoped to `.claude/hooks` in this batch, so they do not contain per-file numbers for `Invoke-FullRelease.ps1`. To satisfy the plan's per-file numeric coverage requirement, a targeted Pester coverage run scoped to the single in-scope production file was executed for measurement only. The MCP toolchain remains the authoritative quality gate and reported `ok: true` with all tests passing.
