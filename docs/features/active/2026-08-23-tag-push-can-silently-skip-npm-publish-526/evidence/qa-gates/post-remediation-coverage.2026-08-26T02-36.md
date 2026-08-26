# Post-Remediation Coverage — Cycle 2026-08-26T02-36

Timestamp: 2026-08-26T04-08

> Filename-stamp substitution note: the filename carries the fixed cycle stamp `2026-08-26T02-36`
> required by the plan's "Evidence filename timestamps" section, because the plan's acceptance
> conditions assert exact filenames. The `Timestamp:` field records the actual execution stamp,
> `2026-08-26T04-08`. Same convention as Phases 0 through 3 of this cycle.

Command: `pwsh -NoProfile -Command 'Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path'`

EXIT_CODE: 0

## Output Summary

### Measurement route

Coverage was read from the direct self-hosted PoshQC invocation named above, not from the MCP test
tool. The MCP runner resolves its Pester runsettings from the installed VS Code extension bundle,
which carries no `CodeCoverage.Path` entry for the newly registered
`scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1`, so it emits no coverage row for that file
at all. Per-file rows below were parsed from `artifacts/pester/powershell-coverage.xml` by keying on
the enclosing `package` element (the full directory path) and then selecting the `sourcefile` by name
within it, never on the bare `sourcefile` name alone.

### Suite result

- Tests passed: **3646**
- Tests failed: **0**
- Tests skipped: 9
- Suite exit code: 0

### Repository-wide line coverage

| Metric | Value |
|---|---|
| Lines covered | 6794 |
| Lines missed | 279 |
| Lines measured | 7073 |
| **Line coverage** | **96.0554 percent** |

Repository-wide line coverage of 96.0554 percent is **at or above the 85.0 percent floor**
(`.claude/rules/quality-tiers.md`, uniform across T1 through T4).

### Per-file line coverage

| File | Covered | Missed | Measured | Line coverage | At or above 85.0 |
|---|---|---|---|---|---|
| `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | 56 | 9 | 65 | **86.1538 percent** | yes |
| `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` | 29 | **0** | 29 | **100 percent** | yes |
| `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` | 75 | 2 | 77 | **97.4026 percent** | yes |

The missed-line count for `scripts/dev-tools/Invoke-ReleaseVerificationHelpers.ps1` is **exactly 0**,
as required: all four relocated pure functions are fully covered by
`tests/scripts/dev-tools/Invoke-ReleaseVerificationHelpers.Tests.ps1`.

The nine missed lines of `scripts/dev-tools/Invoke-ReleaseVerification.ps1` are 69, 70, 86, 87, 104,
403, 418, 419, and 420. Every one of them lies inside a wrapper-seam body or the dot-source-guarded
entry-point block, and all nine are uncoverable under AC21 (no real external process) and AC22 (no
`Start-Sleep`). The line-by-line classification is recorded in
`evidence/qa-gates/uncovered-line-classification.2026-08-26T02-36.md`.

### Comparison basis

Every figure above is compared against an **absolute constant** — the uniform 85.0 percent line
floor, and a missed-line count of exactly 0 for the helpers file. No post-split figure is compared
against any pre-split figure. The re-partitioning of the coverage denominator caused by the module
split is recorded separately in
`evidence/qa-gates/coverage-denominator-repartition.2026-08-26T02-36.md`.

### Related file, recorded for completeness

`scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` measured 24 covered of 27, 88.8889 percent, with
missed lines 163, 164, and 165 (the host-bound entry-point block). This file is not named by the
P6-T1 acceptance condition; it is recorded because
`evidence/other/get-reconciliation-report-deviation.2026-08-26T02-36.md` cites its coverage history.
