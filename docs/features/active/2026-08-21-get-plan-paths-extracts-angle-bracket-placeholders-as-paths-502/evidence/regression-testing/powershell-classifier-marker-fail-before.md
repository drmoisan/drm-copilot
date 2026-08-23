# Fail-Before — PowerShell Classifier Marker Rejection — [P1-T4]

Timestamp: 2026-08-23T01-38

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P1-T4] [expect-fail]
State captured: PRE-FIX, after the test file was created and before the guard exists

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and
`scan_folders` set to `["tests/scripts/claude-lib/blast-radius"]`.

EXIT_CODE: 5

ExpectedExitCode: 1

## Exit-code note

The tool reports `ok: false` with the summary `Command exited with code 5.` Pester's exit code is
the failed-test count when `Exit = $true`, so 5 is the five failing cases rather than an
independent status value. The declared expectation of 1 records that a *non-zero* exit is the
expected outcome for this `[expect-fail]` task; the observed 5 is the failure count and is
consistent with it. The authoritative per-test evidence is the JUnit file, read below.

## Why the tool takes a folder rather than a file

The MCP test tool accepts scan folders, not individual files. The new test file is auto-discovered
because the configured Pester scan folders in
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` already include the `tests/scripts`
tree, so no registration step was required to make the new file run.

## Test names and outcomes, read from `artifacts/pester/pester-junit.xml`

The tool returns only an ok flag and a short summary, so every name and outcome below is read from
the JUnit file, not from the tool's return value.

Root element:

```xml
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="382" errors="0" failures="5" disabled="0" time="35.326">
```

### The five classifier-level cases, failing, by test name

| Test name | Outcome |
| --- | --- |
| `Get-PathTokenKind placeholder-marker rejection (issue #502).Classifier-level rejection, one case per marker.rejects a token carrying the angle-open marker` | FAILED |
| `Get-PathTokenKind placeholder-marker rejection (issue #502).Classifier-level rejection, one case per marker.rejects a token carrying the angle-close marker` | FAILED |
| `Get-PathTokenKind placeholder-marker rejection (issue #502).Classifier-level rejection, one case per marker.rejects a token carrying the delimited-variable interpolation marker` | FAILED |
| `Get-PathTokenKind placeholder-marker rejection (issue #502).Classifier-level rejection, one case per marker.rejects a token carrying the subexpression interpolation marker` | FAILED |
| `Get-PathTokenKind placeholder-marker rejection (issue #502).Classifier-level rejection, one case per marker.rejects a token carrying the percent marker` | FAILED |

All five failures are in the new file, one per marker. Each case's literal-content assertions
(ordinal `IndexOf` for its own marker, plus an exact character-length assertion) passed before the
classification assertion failed, so every failure is a genuine classifier result on the intended
token and not a probe that was silently expanded.

### No other test in the folder regressed

Per-suite counts read from the same JUnit file:

| Suite | Tests | Errors | Failures |
| --- | --- | --- | --- |
| `BlastRadius.Conflict.Tests.ps1` | 27 | 0 | 0 |
| `BlastRadius.Manifest.Tests.ps1` | 4 | 0 | 0 |
| `BlastRadius.Parity.Tests.ps1` | 70 | 0 | 0 |
| `BlastRadius.Tests.ps1` | 39 | 0 | 0 |
| `BlastRadius.TruthTable.Tests.ps1` | 14 | 0 | 0 |
| `BlastRadius.Validation.Tests.ps1` | 31 | 0 | 0 |
| `BlastRadiusConfig.Tests.ps1` | 49 | 0 | 0 |
| `BlastRadiusExtraction.Path.Tests.ps1` | 61 | 0 | 0 |
| `BlastRadiusExtraction.Tests.ps1` | 21 | 0 | 0 |
| `BlastRadiusGlob.Tests.ps1` | 49 | 0 | 0 |
| `BlastRadiusNormalization.Tests.ps1` | 12 | 0 | 0 |
| `BlastRadiusTokenShape.Tests.ps1` (new) | 5 | 0 | **5** |

Every pre-existing suite in the folder reports zero failures and zero errors. The 5 failures in the
run's total of 382 tests are exactly the 5 new cases.

## Toolchain stages for this task

The `[expect-fail]` tag applies to the test stage only.

| Stage | Command | Result |
| --- | --- | --- |
| format | `mcp__drm-copilot__run_poshqc_format` scoped to the folder | ok |
| analyze | `mcp__drm-copilot__run_poshqc_analyze` scoped to the folder | ok |

The analyzer initially reported one issue, `PSUseBOMForUnicodeEncodedFile`, because the file
contained a single non-ASCII character (an em dash, U+2014) with no byte-order mark. The character
was replaced with ASCII text rather than adding a byte-order mark, so the file is now pure ASCII.
That choice keeps the file's encoding uniform with the two production modules this item creates,
which the [P4-T1] byte-identical mirror comparison depends on. The formatter and analyzer were both
re-run to a clean pass afterwards, per the restart clause of the PowerShell toolchain order.

## Output Summary

Fail-before evidence established for the PowerShell runtime. All five classifier-level marker cases
fail, recorded by test name from `artifacts/pester/pester-junit.xml`. Every pre-existing suite in
`tests/scripts/claude-lib/blast-radius` reports zero failures and zero errors, so no other test in
the folder regressed. Format and analyze are clean.
