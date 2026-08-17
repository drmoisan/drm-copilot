# Final PowerShell Tests (Issue #479, [P7-T11])

Timestamp: 2026-08-17T02-57

Command: `mcp__drm-copilot__run_poshqc_test` with
`workspace_root: c:\Users\DanMoisan\repos\drm-copilot` (no `scan_folders`, so the scan set
resolves from `config/poshqc-scan.json` `test.scanFolders`)

EXIT_CODE: 0 (`{"ok": true, "tool": "run_poshqc_test", ...}`)

## Output Summary

Numeric values read from the run's emitted artifacts, since the MCP dispatcher returns a status
envelope rather than the console transcript.

### Pester counts (`artifacts/pester/pester-junit.xml`, root `<testsuites>`)

| Metric | Value | Baseline |
|---|---|---|
| tests | **2740** | 2740 |
| failures | **0** | 0 |
| errors | **0** | 0 |
| disabled (skipped) | 9 | 9 |
| wall time | 113.512 s | 118.507 s |

Identical to baseline in every count, as expected for a surface this feature does not touch.

### Layer-1 cohort-barrier hook suite (AC14 Layer-1 half)

`tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.Tests.ps1`:
**56 tests, 0 failures, 0 errors, 0 skipped**, run UNMODIFIED (the file does not appear in
`git diff --name-only` against the merge base). The Layer-1 hook already implements the
per-edge rule this feature documents, so its passing unmodified is the evidence that D1 moved
the prose to the enforcement layers rather than the reverse.

### Line coverage (`artifacts/pester/powershell-coverage.koverage.xml`, root JaCoCo counters)

| Counter | Covered | Missed | Percent |
|---|---|---|---|
| LINE | 4090 | 209 | **95.14%** |
| INSTRUCTION | 5593 | 301 | 94.89% |
| METHOD | 341 | 24 | 93.42% |
| CLASS | 52 | 0 | 100.00% |

Line coverage of **95.14%** is unchanged from baseline and above the uniform 85% line
threshold.

Branch coverage: `N/A — Pester does not measure branch coverage`. PowerShell is exempt from the
branch threshold only, per `.claude/rules/quality-tiers.md`; it remains in the line-coverage
denominator.
