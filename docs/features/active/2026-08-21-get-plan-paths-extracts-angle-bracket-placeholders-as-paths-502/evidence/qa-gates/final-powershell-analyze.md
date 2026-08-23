# QA Gate — Final PowerShell Analysis — [P8-T7]

Timestamp: 2026-08-23T05-22

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P8-T7]
Run: revision-6 re-run.

Command: `mcp__drm-copilot__run_poshqc_analyze` with `workspace_root` set to the worktree root and no
`scan_folders` argument, so the analyzer runs over the full configured scope.

EXIT_CODE: 0

## Tool summary, verbatim

```json
{"ok":true,"tool":"run_poshqc_analyze","workspace_root":"C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-22T22-50","summary":"Ran bundled PoshQC analyze against 'C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-22T22-50'."}
```

The tool reports `ok: true`. **PASS.**

## Why the ok flag is the gate

The measured return shape carries exactly four fields: an ok flag, a tool name, a workspace root, and
a one-sentence summary. It carries no diagnostic count and no severity breakdown at any scope, and the
analyzer writes no report file, so unlike the Pester surface there is nowhere to read a count from.
The ok flag is therefore the only available signal and is the gate. An acceptance demanding a
zero-diagnostic count would name a value the tool never emits, and would be unsatisfiable rather than
strict.

The ok flag is the gate here rather than a snapshot pair — the form [P8-T6] uses for the formatter —
because the analyzer is read-only and so reports its own outcome faithfully. A write-mode tool cannot
do that, which is the whole reason the formatter needs the pair.

## Sensitivity of this gate, demonstrated during execution

The ok flag is not a constant. The analyzer returned `ok: false` with
`PSScriptAnalyzer reported 1 issue(s).` earlier in this item's execution, when
`tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` was first created carrying a
single non-ASCII character with no byte-order mark, which triggered `PSUseBOMForUnicodeEncodedFile`.
That failure is recorded at
`evidence/regression-testing/powershell-classifier-marker-fail-before.md`. The file was corrected to
pure ASCII and the analyzer re-run to a clean pass. The incident establishes that this gate
discriminates on this repository's PowerShell surface rather than reporting ok unconditionally.

The [P5-T3] test block added on this run was likewise written pure-ASCII and single-quoted throughout,
verified by a fixed-string count of zero double-quoted strings and an empty non-ASCII character set in
the appended block.

## Scope

The run covers the full configured PoshQC scan scope, which includes every PowerShell-family file this
item changed or created:

- `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` (new)
- `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` (changed)
- both bundled mirrors of the two files above
- `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` (new)
- `tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1` (changed, including this run's [P5-T3] addition)
- `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1` (changed)
- both copies of `pester.runsettings.psd1`

## Output Summary

The analyzer reports ok over the full configured scope with the summary recorded verbatim. No
PSScriptAnalyzer debt was created by this item or by the [P5-T3] addition, and the gate is
demonstrably sensitive: it failed earlier in this item's execution on a real diagnostic and was
returned to a clean pass by fixing the cause.
