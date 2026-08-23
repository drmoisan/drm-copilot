# QA Gate — Final PowerShell Tests with Coverage — [P8-T8]

Timestamp: 2026-08-23T04-04

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T8]
Status: **PARTIAL — three of four acceptance conditions pass on the gate command. The fourth cannot
be observed through the MCP tool for a structural reason recorded below, and is established instead
by direct measurement against the allow-list this item edited.**

Command: `mcp__drm-copilot__run_poshqc_test` with `workspace_root` set to the worktree root and no
`scan_folders` argument, so the run covers the full configured scan scope.

EXIT_CODE: 0

Tool return, verbatim:

```json
{"ok":true,"tool":"run_poshqc_test","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-22T22-50","summary":"Ran bundled PoshQC test against 'C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-22T22-50'."}
```

The tool returns only an ok flag and a short summary, so every number below is read from the run's
own output files.

## Condition 1 — exit code 0

The tool reports `ok: true`. **PASS.**

## Condition 2 — zero failures in the JUnit output

Read from `artifacts/pester/pester-junit.xml`:

```xml
<testsuites xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="junit_schema_4.xsd" name="Pester" tests="3388" errors="0" failures="0" disabled="9" time="138.053">
```

| Metric | Baseline ([P0-T8]) | Post-change | Change |
| --- | --- | --- | --- |
| tests | 3364 | **3388** | +24 |
| failures | 0 | **0** | 0 |
| errors | 0 | **0** | 0 |
| disabled | 9 | 9 | 0 |

Zero failures and zero errors. **PASS.** The 24 additional tests are the 16 in the new
`BlastRadiusTokenShape.Tests.ps1`, 2 in `BlastRadiusNormalization.Tests.ps1`, and 6 parity cases from
the three new fixtures across the radius and findings channels.

## Condition 3 — line coverage at or above 85%

Report-level counters read from `artifacts/pester/powershell-coverage.xml`:

```xml
  <counter type="INSTRUCTION" missed="331" covered="8061" />
  <counter type="LINE" missed="211" covered="5750" />
  <counter type="METHOD" missed="25" covered="492" />
  <counter type="CLASS" missed="0" covered="70" />
```

| Figure | Derivation | Value | Threshold |
| --- | --- | --- | --- |
| **line coverage** | 5750 / (5750 + 211) | **96.46%** | >= 85% |
| instruction coverage | 8061 / (8061 + 331) | 96.06% | not gated |

**PASS**, with a wide margin. No branch-coverage threshold applies: Pester does not measure branch
coverage and the coverage XML contains no `BRANCH` counter.

| Metric | Baseline ([P0-T8]) | Post-change | Delta |
| --- | --- | --- | --- |
| line coverage | 96.47% | **96.46%** | -0.01 pp |

## Condition 4 — the coverage XML must list the new module in the measured file set

**Not satisfied by the MCP run.** The measured set contains six blast-radius modules and not the
seventh:

```text
$ grep -o 'sourcefilename="BlastRadius[^"]*"' artifacts/pester/powershell-coverage.xml | sort -u
sourcefilename="BlastRadius.psm1"
sourcefilename="BlastRadiusConfig.psm1"
sourcefilename="BlastRadiusExtraction.psm1"
sourcefilename="BlastRadiusGlob.psm1"
sourcefilename="BlastRadiusNormalization.psm1"
sourcefilename="BlastRadiusValidation.psm1"
```

### Root cause: the MCP tool reads a published allow-list, not the repository allow-list

The cause is not a missing or malformed registration. Both in-repository allow-lists carry the entry,
verified by loading the data file rather than by reading it:

```text
$ pwsh -NoProfile -Command "$s = Import-PowerShellDataFile -Path 'scripts/powershell/PoshQC/settings/pester.runsettings.psd1'; ..."
allow-list count: 81
  .claude/lib/blast-radius/BlastRadiusExtraction.psm1  exists=True
  .claude/lib/blast-radius/BlastRadiusGlob.psm1  exists=True
  .claude/lib/blast-radius/BlastRadiusConfig.psm1  exists=True
  .claude/lib/blast-radius/BlastRadiusValidation.psm1  exists=True
  .claude/lib/blast-radius/BlastRadius.psm1  exists=True
  .claude/lib/blast-radius/BlastRadiusNormalization.psm1  exists=True
  .claude/lib/blast-radius/BlastRadiusTokenShape.psm1  exists=True
```

Seven entries, all resolving on disk. The bundled mirror is byte-identical to it, verified at
[P4-T5] and [P4-T6].

The MCP server does not read either of those files. `.mcp.json` configures the server as
`npx -y @danmoisan/drm-copilot-mcp`, so it executes from the **published npm package**, and that
package carries its own copy of the runsettings inside the npx cache. A survey of the cached package
copies shows the newest carries seven `blast-radius` lines and **zero** `BlastRadiusTokenShape`
lines — that is, six module entries plus the section comment, frozen at whatever the last publish
contained. Only two `pester.runsettings.psd1` files exist inside this repository and both carry the
new entry; the file the MCP run actually consumed is outside the repository.

This is a pre-existing structural property of the toolchain, not a defect introduced here: an
in-repository allow-list addition cannot take effect in an MCP-driven coverage run until a new MCP
package is published. The same would be true of any file added to that allow-list by any change.

### The condition established by direct measurement

The substance of the condition — that the new production module is in the coverage denominator under
the allow-list this item edited — was measured directly, with the three relevant modules named in
`CodeCoverage.Path` and the same test folder as the run scope:

```text
tests=401 failed=0
BlastRadiusExtraction.psm1:  LINE missed=0 covered=85  -> 100.00%   INSTRUCTION missed=0 covered=98
BlastRadiusGlob.psm1:        LINE missed=0 covered=69  -> 100.00%   INSTRUCTION missed=0 covered=83
BlastRadiusTokenShape.psm1:  LINE missed=0 covered=19  -> 100.00%   INSTRUCTION missed=0 covered=22
```

`.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` **is** present in the measured file set, with
**19 of 19 lines covered and zero missed**, i.e. 100% line coverage and 100% instruction coverage.
The changed extraction module is likewise at 100% on both.

This direct run is a diagnostic, not a substitute for the gate: the MCP tool was run and is the gate
command, and its three observable conditions pass. The direct run isolates the one remaining
condition to the published-package boundary and answers it against the configuration this item
actually changed. It is not a VS Code task wrapper, so the PowerShell toolchain rule's prohibition on
substituting one for the MCP functions is not engaged.

### Consequence for the Coverage Exclusion Policy

The policy requires that no production file be excluded from coverage measurement. That requirement
is met by the registration: both allow-lists name the file, and the file is measured whenever the
allow-list that names it is the one in force. Nothing in this item excludes it. The MCP runtime will
pick it up at the next publish of the MCP package with no further change.

## Output Summary

Three of four conditions pass on the gate command: the tool reports ok, the JUnit output records 3388
tests with **0 failures and 0 errors**, and line coverage is **96.46%**, above the 85% threshold and
within 0.01 pp of the 96.47% baseline. The fourth condition — the new module appearing in the
measured file set — is not observable through the MCP tool, because that tool executes from a
published npm package whose bundled allow-list predates this change; both in-repository allow-lists
carry the entry, and a direct measurement against the repository allow-list shows the module measured
at **100% line coverage (19 of 19 lines, 0 missed)**.
