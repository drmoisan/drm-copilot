# QA Gate — Final PowerShell Tests with Coverage — [P8-T8]

Timestamp: 2026-08-23T05-24

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T8]
Run: revision-6 re-run.
Status: **PARTIAL — three of four acceptance conditions pass on the gate command. The fourth cannot be
observed through the MCP tool for a structural reason recorded below, and is established instead by
direct measurement against the allow-list this item edited.**

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and no
`scan_folders` argument, so the run covers the full configured scan scope.

EXIT_CODE: 0

Tool return, verbatim:

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-22T22-50","summary":"Ran bundled PoshQC test against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-22T22-50'."}
```

The tool returns only an ok flag and a short summary, so every number below is read from the run's own
output files.

## Condition 1 — exit code 0

The tool reports `ok: true`. **PASS.**

## Condition 2 — zero failures in the JUnit output

Read from `artifacts/pester/pester-junit.xml`:

```xml
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="3389" errors="0" failures="0" disabled="9" time="137.338">
```

| Metric | Baseline ([P0-T8]) | Previous run | This run | Change vs baseline |
| --- | --- | --- | --- | --- |
| tests | 3364 | 3388 | **3389** | +25 |
| failures | 0 | 0 | **0** | 0 |
| errors | 0 | 0 | **0** | 0 |
| disabled | 9 | 9 | 9 | 0 |

Zero failures and zero errors. **PASS.** The single additional test over the previous run is
[P5-T3]'s `conflicts before normalization and stops conflicting after it`; the test count moving is the
independent confirmation that the new case ran.

## Condition 3 — line coverage at or above 85%

Report-level counters read from `artifacts/pester/powershell-coverage.xml`:

```text
INSTRUCTION: missed=331 covered=8061 -> 96.06%
LINE:        missed=211 covered=5750 -> 96.46%
```

| Figure | Derivation | Value | Threshold |
| --- | --- | --- | --- |
| **line coverage** | 5750 / (5750 + 211) | **96.46%** | >= 85% |
| instruction coverage | 8061 / (8061 + 331) | 96.06% | not gated |

**PASS**, with a wide margin. No branch-coverage threshold applies: Pester does not measure branch
coverage and a fixed-string count of `BRANCH` in the coverage XML returns **0**.

| Metric | Baseline ([P0-T8]) | This run | Delta |
| --- | --- | --- | --- |
| line coverage | 96.47% | **96.46%** | -0.01 pp |

## Condition 4 — the coverage XML must list the new module in the measured file set

**Not satisfied by the MCP run**, for the same structural reason as the previous run, re-verified here
rather than carried forward on assertion.

### Root cause: the MCP tool reads a published allow-list, not the repository allow-list

The cause is not a missing or malformed registration. Both in-repository allow-lists carry the entry,
verified by loading the data file rather than reading it: `Import-PowerShellDataFile` reports 81
`CodeCoverage.Path` entries including `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1`, and all
seven blast-radius entries resolve on disk. The bundled mirror is byte-identical, verified at [P4-T5]
and [P4-T6].

The MCP server does not read either of those files. `.mcp.json` configures it as
`npx -y @danmoisan/drm-copilot-mcp`, so it executes from the **published npm package**, which carries
its own copy of the runsettings inside the npx cache. That copy carries six blast-radius module
entries and **zero** `BlastRadiusTokenShape` entries, frozen at whatever the last publish contained.
Only two `pester.runsettings.psd1` files exist inside this repository and both carry the new entry;
the file the MCP run actually consumed is outside the repository.

This is a pre-existing structural property of the toolchain, not a defect introduced here: an
in-repository allow-list addition cannot take effect in an MCP-driven coverage run until a new MCP
package is published. The same would be true of any file added to that allow-list by any change.

### The condition established by direct measurement

Re-measured on this tree, with the two relevant modules named in `CodeCoverage.Path` and the
blast-radius test folder as the run scope:

```text
tests=402 failed=0
BlastRadiusExtraction.psm1:  LINE missed=0 covered=85  -> 100.00%   INSTRUCTION missed=0 covered=98
BlastRadiusTokenShape.psm1:  LINE missed=0 covered=19  -> 100.00%   INSTRUCTION missed=0 covered=22
```

`.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` **is** present in the measured file set, with
**19 of 19 lines covered and zero missed**: 100% line and 100% instruction coverage. The changed
extraction module is likewise at 100% on both.

This direct run is a diagnostic, not a substitute for the gate. The MCP tool was run and is the gate
command, and its three observable conditions pass. The direct run isolates the remaining condition to
the published-package boundary and answers it against the configuration this item actually changed. It
is not a VS Code task wrapper, so the PowerShell toolchain rule's prohibition on substituting one for
the MCP functions is not engaged.

### Consequence for the Coverage Exclusion Policy

The policy requires that no production file be excluded from coverage measurement. That requirement is
met by the registration: both allow-lists name the file, and the file is measured whenever the
allow-list that names it is in force. Nothing in this item excludes it. The MCP runtime picks it up at
the next publish with no further change.

## Output Summary

Three of four conditions pass on the gate command: the tool reports ok, the JUnit output records
**3389 tests with 0 failures and 0 errors**, and line coverage is **96.46%**, above the 85% threshold
and within 0.01 pp of the 96.47% baseline. The fourth condition is not observable through the MCP tool,
which executes from a published npm package whose bundled allow-list predates this change; both
in-repository allow-lists carry the entry, and a direct measurement on this tree shows the module at
**100% line coverage (19 of 19 lines, 0 missed)**.
