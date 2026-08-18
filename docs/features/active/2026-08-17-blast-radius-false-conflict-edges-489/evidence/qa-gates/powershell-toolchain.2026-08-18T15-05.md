# PowerShell Final QA Gates (Issue #489)

Timestamp: 2026-08-18T15-05

Loop note: this loop was restarted once. The first analyze pass reported three
findings — `PSUseShouldProcessForStateChangingFunctions` twice against
`Remove-MandateRead` (a pure function carrying a state-changing verb) and
`PSUseBOMForUnicodeEncodedFile` against `BlastRadius.Tests.ps1` (a scripted edit
earlier in this feature dropped the file's pre-existing BOM while the file still
carries an em-dash). The function was renamed to `Get-NonMandateReadEntry`,
matching the sibling filter `Get-ConcreteEntry`, the BOM was restored, the
bundled mirrors were re-synced, and the loop was restarted from formatting. The
figures below are the final clean pass.

## P8-T6 Formatting

Timestamp: 2026-08-18T15-05
Command: MCP tool `mcp__drm-copilot__run_poshqc_format` with
`workspace_root: C:\Users\DanMoisan\repos\drm-copilot`
EXIT_CODE: 0
Output Summary: `{"ok":true,...,"summary":"Ran bundled PoshQC format against
'C:\\Users\\DanMoisan\\repos\\drm-copilot'."}`. No residual formatting change on
the final iteration; the restored BOM on `BlastRadius.Tests.ps1` survived the
formatter (verified byte-wise after the run).

## P8-T7 Analysis

Timestamp: 2026-08-18T15-05
Command: MCP tool `mcp__drm-copilot__run_poshqc_analyze` with
`workspace_root: C:\Users\DanMoisan\repos\drm-copilot`
EXIT_CODE: 0
Output Summary: `{"ok":true,...,"summary":"Ran bundled PoshQC analyze against
'C:\\Users\\DanMoisan\\repos\\drm-copilot'."}`. Zero diagnostics. No
`SuppressMessageAttribute` was added anywhere on this branch.

## P8-T8 Tests With Coverage

Timestamp: 2026-08-18T15-05
Command: MCP tool `mcp__drm-copilot__run_poshqc_test` with
`workspace_root: C:\Users\DanMoisan\repos\drm-copilot`
EXIT_CODE: 0
Output Summary: `{"ok":true,...,"summary":"Ran bundled PoshQC test against
'C:\\Users\\DanMoisan\\repos\\drm-copilot'."}`. This is the mandated gate and it
passed.

### Known issue B13 — supplementary worktree-resolved run

`mcp__drm-copilot__run_poshqc_test` resolves `pester.runsettings.psd1` from the
INSTALLED MCP package (`@danmoisan/drm-copilot-mcp` v1.0.26), which bundles only
the five pre-#489 blast-radius entries. `BlastRadiusNormalization.psm1` is
therefore ABSENT from the MCP run's package list rather than reported at 0%.
That absence is a package-staleness artefact, not a coverage failure, and no
remediation is required for it. The per-file figure below comes from a
supplementary run that resolves the runsettings from the worktree.

Timestamp: 2026-08-18T15-05
Command: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"`
EXIT_CODE: 0
Output Summary: `Tests completed in 154.36s. Tests Passed: 2786, Failed: 0,
Skipped: 9, Inconclusive: 0, NotRun: 0.` Coverage tail line:
`Covered 95.83% / 0%. 7,555 analyzed Commands in 65 Files.`

Declared-set confirmation before the figure was trusted: the worktree
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` declares 66
`CodeCoverage.Path` entries and all 66 resolve to an existing file
(`declared=66`, `existing=66`). All six blast-radius modules appear in the
emitted report `artifacts/pester/powershell-coverage.xml`, confirming the
worktree-resolved run measured the post-#489 set rather than the packaged one.

Numeric line coverage: 95.83% overall, above the 85% threshold. Branch coverage
is not measured by Pester and PowerShell is exempt from the branch threshold per
`.claude/rules/quality-tiers.md`; the tool's `/ 0%` second figure is that
unmeasured dimension, not a failing branch score.

Per-file line coverage for the blast-radius library (AC-H2 PowerShell half):

| Module | Covered/Total | Line |
| --- | --- | --- |
| `.claude/lib/blast-radius/BlastRadius.psm1` | 109/109 | 100.00% |
| `.claude/lib/blast-radius/BlastRadiusConfig.psm1` | 80/80 | 100.00% |
| `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | 93/93 | 100.00% |
| `.claude/lib/blast-radius/BlastRadiusGlob.psm1` | 69/69 | 100.00% |
| `.claude/lib/blast-radius/BlastRadiusNormalization.psm1` | 50/50 | 100.00% |
| `.claude/lib/blast-radius/BlastRadiusValidation.psm1` | 96/99 | 96.97% |

`BlastRadiusNormalization.psm1` measures 100%, confirming the relocated
functions `Get-ContractIdentifier` and `Resolve-BlastRadiusModule` remain in the
coverage denominator after the P4-T1 split.

Baseline comparison: the Phase 0 PowerShell baseline recorded the same suite
green; the post-change run adds this feature's new cases and raises overall
coverage from 95.58% (7,486 commands) to 95.83% (7,555 commands). No regression.

## P8-T9 Byte-Copy Parity and Frozen Diff

Timestamp: 2026-08-18T15-05
Command: `pwsh -NoProfile -Command 'foreach ($n in @("BlastRadius.psm1","BlastRadiusExtraction.psm1","BlastRadiusConfig.psm1","BlastRadiusValidation.psm1","BlastRadiusGlob.psm1","BlastRadiusNormalization.psm1")) { $a=(Get-FileHash ".claude/lib/blast-radius/$n").Hash; $b=(Get-FileHash "extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/$n").Hash; "$n $($a -eq $b)" }'` then `git diff main -- .claude/lib/blast-radius/BlastRadiusGlob.psm1`
EXIT_CODE: 0
Output Summary: all six hash pairs report `True` on the final pass. The frozen
`BlastRadiusGlob.psm1` diff prints nothing, so the formatter did not touch it and
the AC-C1 zero-diff constraint holds after the format step.
