# Phase 0 — Baseline self-hosted per-file line coverage (issue #545)

Timestamp: 2026-08-25T13-37

Task: [P0-T8]

Command:

```powershell
Import-Module "./scripts/powershell/PoshQC/PoshQC.psd1" -Force
Invoke-PoshQCTest -Root (Get-Location).ProviderPath `
  -SettingsPath "scripts/powershell/PoshQC/settings/pester.runsettings.psd1"
```

EXIT_CODE: 0

## Why the self-hosted route rather than the MCP runner

`mcp__drm-copilot__run_poshqc_test` instruments coverage from the installed VS Code extension's
copy of the runsettings, not from either in-repo copy. A `CodeCoverage.Path` entry added later in
this plan by [P5-T8] and [P5-T9] would therefore produce no coverage row through the MCP runner —
the file would be silently absent from the JaCoCo report rather than reported at zero. Importing
`scripts/powershell/PoshQC/PoshQC.psd1` and passing `-SettingsPath` explicitly makes the in-repo
settings file authoritative, so the entries this plan adds are measurable.

## Freshness

`artifacts/pester/powershell-coverage.xml`, `powershell-coverage.koverage.xml`, and
`pester-junit.xml` were deleted before this run and reappeared during it. The regenerated report
carries `<report name="Pester (08/25/2026 13:37:48)">`. This is a re-run performed from scratch;
no earlier output was reused.

## Run headline

```text
Tests completed in 200.72s
Tests Passed: 3583, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0
Processing code coverage result.
Covered 95.65% / 0%. 9,568 analyzed Commands in 82 Files.
```

The `95.65%` figure in the console line is Pester's **command** coverage, not line coverage. Line
coverage is computed separately below from the JaCoCo `counter` elements, per the result-artifact
extraction contract.

## Extraction method

Each percentage is read from the `counter` element whose `type` attribute is `LINE`, on the
`sourcefile` element whose `name` attribute equals the bare filename, selected **within the
enclosing `package` element** whose `name` attribute ends with that file's directory. A bare
filename lookup is not used: `enforce-orchestration-preimplementation-gate.ps1` and
`enforce-promotion-mcp-only.ps1` each appear under both the `.claude/hooks` and the `.codex/hooks`
package, so a filename-only selection would be ambiguous and would silently return the wrong side.

The report carries 12 `package` elements. The two relevant ones are:

- `…/agent-adcd2df193c6616e5/.claude/hooks`
- `…/agent-adcd2df193c6616e5/.codex/hooks`

## Output Summary — five numeric baseline percentages

| # | File | Package element selected | missed | covered | Baseline line coverage |
| --- | --- | --- | --- | --- | --- |
| 1 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | `…/.claude/hooks` | 11 | 102 | **90.2655%** |
| 2 | `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `…/.codex/hooks` | 1 | 124 | **99.2000%** |
| 3 | `.claude/hooks/enforce-promotion-mcp-only.ps1` | `…/.claude/hooks` | 4 | 47 | **92.1569%** |
| 4 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | `…/.claude/hooks` | 3 | 61 | **95.3125%** |
| 5 | `.claude/hooks/enforce-pr-author-skill.ps1` | `…/.claude/hooks` | 4 | 46 | **92.0000%** |

Each percentage is `covered / (covered + missed)` on the file's `sourcefile`-level
`counter[@type='LINE']`, selected within the package element named in the third column.

File 5 is included because [P8-T2] modifies it and it is already in the coverage denominator at
baseline; [P11-T7] needs this figure to compute an honest delta rather than reporting a new file.

## Explicit absent-from-denominator entry

- `.codex/hooks/enforce-promotion-mcp-only.ps1` — `no baseline percentage — outside the
  CodeCoverage.Path list until [P5-T8] and [P5-T9]`

Verified directly against the settings file: `Import-PowerShellDataFile` on
`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` returns an 83-entry
`CodeCoverage.Path` list in which `.codex/hooks/enforce-promotion-mcp-only.ps1` occurs **0** times.
The report accordingly contains no `sourcefile` element for it under the `.codex/hooks` package.
[P11-T7] must therefore record this file's baseline column as `no baseline — newly in the
denominator` and compute no delta, rather than comparing against a fabricated zero.

## Overall figure, recorded for information only

Report-level `counter[@type='LINE']`: missed = 267, covered = 6656, giving **96.1433%** overall
line coverage across the 82 measured files. No threshold is asserted against this figure.
