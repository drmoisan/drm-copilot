# Phase 1 — PoshQC Loop (Remediation Cycle 1)

- **Issue:** #415
- **Task:** [P1-T2]
- **Finding:** R1

Timestamp: 2026-07-26T11-41

## Commands (C2 order, `workspace_root = C:\Users\DanMoisan\repos\drm-copilot-wt\2026-07-25T16-53`)

1. Command: `mcp__drm-copilot__run_poshqc_format` — EXIT_CODE: 0 (`ok: true`); files changed: none (verified by `git status --porcelain` immediately after: only the plan checkbox edit, the two runsettings edits from [P1-T1], and the Phase 0 evidence directory).
2. Command: `mcp__drm-copilot__run_poshqc_analyze` — EXIT_CODE: 0 (`ok: true`); 0 errors, 0 warnings, 0 information.
3. Command: `mcp__drm-copilot__run_poshqc_test` — EXIT_CODE: 0 (`ok: true`); `artifacts/pester/pester-junit.xml` reports tests=1429, failures=0, errors=0, disabled=9.

All three stages passed in one uninterrupted pass. No stage failed and no stage modified a file, so no restart was required.

## Supplementary command (recorded deviation — see below)

4. Command: `pwsh -NoProfile -Command "Import-Module './scripts/powershell/PoshQC/PoshQC.psm1' -Force; Invoke-PoshQCTest -Root (Get-Location).Path"` — EXIT_CODE: 0. `Tests Passed: 1420, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0`; `Covered 74.45% / 0%. 4,246 analyzed Commands in 39 Files.`

## DEVIATION: the MCP test tool cannot honour the [P1-T1] runsettings edit

**Observed.** After [P1-T1] added the 8 C5 paths to both workspace `pester.runsettings.psd1` copies, `mcp__drm-copilot__run_poshqc_test` regenerated `artifacts/pester/powershell-coverage.xml` with the measured set UNCHANGED: repo-wide LINE covered=2160 / missed=235 (identical to the [P0-T5] baseline), and the `.codex/hooks` package still contained exactly two sourcefiles (`enforce-completion-consistency.ps1`, `enforce-completion-helpers.ps1`). None of the 8 C5 paths appeared.

**Cause, demonstrated by execution rather than inference.** The MCP tool description states it runs "using bundled extension resources". `.mcp.json` resolves the server as `npx -y @danmoisan/drm-copilot-mcp`; `.codex/config.toml:5` pins `@danmoisan/drm-copilot-mcp@1.0.19`. The npx cache entry for version 1.0.19 is at:

```
C:/Users/DanMoisan/AppData/Local/npm-cache/_npx/51f07f99c58b1170/node_modules/@danmoisan/drm-copilot-mcp
```

and it ships its own PoshQC module at `resources/powershell/PoshQC/`. `scripts/powershell/PoshQC/PoshQC.psm1:3` resolves settings as `$script:PesterSettings = Join-Path $ModuleRoot 'settings/pester.runsettings.psd1'`, i.e. relative to whichever PoshQC module root is loaded — for the MCP server that is the packaged `resources/powershell/PoshQC`, not the workspace copy. `Invoke-PoshQCTest`'s `SettingsPath` defaults to that value and the MCP tool surface exposes no settings parameter (only `workspace_root` and `scan_folders`).

Verification commands and results:

```
grep -n "codex" <npx-cache>/resources/powershell/PoshQC/settings/pester.runsettings.psd1
54:            '.codex/hooks/enforce-completion-consistency.ps1'
55:            '.codex/hooks/enforce-completion-helpers.ps1'

diff <(git show HEAD:extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1) \
     <npx-cache>/resources/powershell/PoshQC/settings/pester.runsettings.psd1
=> IDENTICAL-TO-HEAD-BUNDLE (no differences)
```

The published 1.0.19 runsettings is byte-identical to the repository's pre-remediation bundle copy. The MCP measurement path therefore lags the repository by one release and cannot reflect any `CodeCoverage.Path` edit until the package is republished. This is a property of the tool transport, not a defect in the [P1-T1] edit.

**Resolution adopted (minimum necessary micro-action).** The authoritative CI measurement path imports the WORKSPACE module:

```
.github/workflows/_poshqc.yml:41  Import-Module "${{ github.workspace }}/scripts/powershell/PoshQC/PoshQC.psm1"
.github/workflows/_poshqc.yml:42  Invoke-PoshQCTest -Root "${{ github.workspace }}"
```

Command 4 above reproduces exactly that CI invocation locally. It is the same tool, the same entry function, and the same workspace test corpus; the only difference from the MCP call is which copy of `pester.runsettings.psd1` is loaded — and the workspace copy is the one [P1-T1] edited and the one CI consumes.

For every remaining PoshQC loop task in this plan (P2-T3, P3-T2, P4-T2, P6-T1..T3) the C2 loop is executed in full via the three MCP calls as the plan mandates, and command 4 is executed additionally to produce the coverage XML that the per-file extraction tasks (C4) consume. Both results are recorded. No threshold was changed, no file was removed from measurement, and no denominator was adjusted.

## Output Summary

- **MCP loop:** format 0 / analyze 0 / test 0, one uninterrupted pass. Tests 1429, failures 0, errors 0.
- **Workspace-module run (CI-equivalent):** tests passed 1420, failed 0, skipped 9. 39 files analyzed (up from 31 at baseline — the 8 C5 paths are now measured).
- **Repo-wide line coverage with the expanded measured set:** covered = **2334**, missed = **708**, total instrumented = **3042**, **line coverage = 2334 / 3042 = 76.73%**.
- This is BELOW 85%, which is expected and is explicitly not a failure of this task per the [P1-T2] acceptance text: the denominator grew by 647 instrumented lines (3042 − 2395) while the numerator grew by only 174 (2334 − 2160), because the newly measured hooks are currently driven almost entirely by process-spawn suites that contribute no in-process coverage. The >= 85% gate binds at [P4-T3] and [P6-T3] after the Phase 2–4 gap-closure batches.
- **`artifacts/pester/powershell-coverage.xml` regenerated with the expanded measured set:** confirmed — the `.codex/hooks` package now contains 10 sourcefiles including all 8 C5 paths.
- PowerShell branch coverage remains not separately measurable (no `BRANCH` counter in the JaCoCo output).
