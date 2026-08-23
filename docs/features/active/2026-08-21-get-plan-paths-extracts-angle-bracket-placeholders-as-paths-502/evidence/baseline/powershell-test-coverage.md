# Baseline — PowerShell Tests with Coverage — [P0-T8]

Timestamp: 2026-08-23T00-45

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P0-T8]
State captured: PRE-CHANGE baseline

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and no
`scan_folders` argument, so the scan set resolves from the configured Pester scan folders
(`scripts`, `tests/powershell`, `tests/scripts`).

EXIT_CODE: 0

## Why the numbers are read from the run's output files, not from the return value

The MCP tool returns only `ok`, `tool`, `workspace_root`, and a one-sentence `summary`. It carries
no test count, no failure count, and no coverage percentage. Every number below is therefore read
from the run's own output files:

- `artifacts/pester/pester-junit.xml` — test and failure counts.
- `artifacts/pester/powershell-coverage.xml` — coverage counters (JaCoCo shape, CoverageGutters
  format, absolute `sourcefilename` values).

The converted sibling `artifacts/pester/powershell-coverage.koverage.xml` carries the same
counters with repository-relative package and class names; both files record the same report
generation timestamp, confirming they describe the same run.

Tool return, verbatim:

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-22T22-50","summary":"Ran bundled PoshQC test against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-22T22-50'."}
```

## Test counts, read from `artifacts/pester/pester-junit.xml`

Root element, verbatim:

```xml
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="3364" errors="0" failures="0" disabled="9" time="161.520">
```

| Metric | Count | Source attribute |
| --- | --- | --- |
| tests | 3364 | `tests` |
| failures | 0 | `failures` |
| errors | 0 | `errors` |
| disabled (skipped) | 9 | `disabled` |

## Line coverage, read from `artifacts/pester/powershell-coverage.xml`

Report-level counters, verbatim:

```xml
  <counter type="INSTRUCTION" missed="331" covered="8071" />
  <counter type="LINE" missed="211" covered="5758" />
  <counter type="METHOD" missed="25" covered="493" />
  <counter type="CLASS" missed="0" covered="70" />
```

| Figure | Derivation | Value |
| --- | --- | --- |
| **line coverage** | covered / (covered + missed) = 5758 / (5758 + 211) | **96.47%** |
| instruction (command) coverage | 8071 / (8071 + 331) | 96.06% |

Line coverage is the figure the uniform >= 85% threshold applies to. Instruction coverage is
recorded for information only; `.claude/rules/powershell.md` attaches no threshold to it.

## No branch-coverage threshold applies

Pester does not measure branch coverage. A fixed-string search for the token `BRANCH` in
`artifacts/pester/powershell-coverage.xml` returns zero matches:

```text
$ grep -c 'BRANCH' artifacts/pester/powershell-coverage.xml
0
```

Per `.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md`, PowerShell is
exempt from the branch-coverage threshold because the tooling cannot measure it. The exemption is
a capability limit on an unevaluable threshold and is not a licence to exclude files from
measurement.

## Coverage scope note

`CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` is an explicit
per-file allow-list, and `CoveragePercentTarget` is 0, so PoshQC does not fail the run on
coverage and the zero exit code is not by itself coverage evidence. That allow-list is why
[P4-T4] must register the new module: without registration, the new production file would sit
outside the coverage denominator, which the Coverage Exclusion Policy forbids.

## Output Summary

Baseline PowerShell suite is green: 3364 tests, 0 failures, 0 errors, 9 disabled, read from
`artifacts/pester/pester-junit.xml`. Baseline line coverage is 96.47% (LINE covered 5758, missed
211), read from `artifacts/pester/powershell-coverage.xml`. No branch-coverage threshold applies
to Pester; the coverage XML contains no `BRANCH` counter.
