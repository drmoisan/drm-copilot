# QA Gate — Final PowerShell Analysis — [P8-T7]

Timestamp: 2026-08-23T03-54

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T7]

Command: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` set to the worktree root and no
`scan_folders` argument, so the analyzer runs over the full configured scope.

EXIT_CODE: 0

## Tool summary, verbatim

```json
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-22T22-50","summary":"Ran bundled PoshQC analyze against 'C:\\Users\\DanMoisan\\repos\\drm-copilot-wt\\2026-08-22T22-50'."}
```

The tool reports `ok: true`. **PASS.**

## Why the ok flag is the gate

The measured return shape carries exactly four fields — an ok flag, a tool name, a workspace root,
and a one-sentence summary. It carries no diagnostic count and no severity breakdown at any scope,
and the analyzer writes no report file, so unlike the Pester surface there is nowhere to read a count
from. The ok flag is therefore the only available signal and is the gate. An acceptance demanding a
zero-diagnostic count would name a value the tool never emits, and would be unsatisfiable rather than
strict.

The ok flag is the gate here rather than a snapshot pair — the form [P8-T6] uses for the formatter —
because the analyzer is read-only and so reports its own outcome faithfully. A write-mode tool cannot
do that, which is the whole reason the formatter needs the pair.

## Sensitivity of this gate, demonstrated during execution

The ok flag is not a constant. The analyzer returned `ok: false` with
`PSScriptAnalyzer reported 1 issue(s).` earlier in this run, when
`tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` was first created carrying a
single non-ASCII character with no byte-order mark, which triggered `PSUseBOMForUnicodeEncodedFile`.
That failure is recorded at
`evidence/regression-testing/powershell-classifier-marker-fail-before.md`. The file was corrected to
pure ASCII and the analyzer was re-run to a clean pass. The incident establishes that this gate does
discriminate on this repository's PowerShell surface rather than reporting ok unconditionally.

## Scope

The run covers the full configured PoshQC scan scope, which includes all four PowerShell-family files
this item changed or created and the two `.psd1` runsettings files:

- `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` (new)
- `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` (changed)
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` (new)
- `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusExtraction.psm1` (changed)
- `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` (new)
- `tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1` (changed)
- `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` (changed)
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` (changed)
- `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` (changed)

## Output Summary

The analyzer reports ok over the full configured scope with the summary recorded verbatim. No
PSScriptAnalyzer debt was created by this item, and the gate is demonstrably sensitive: it failed
earlier in this same run on a real diagnostic and was returned to a clean pass by fixing the cause.
