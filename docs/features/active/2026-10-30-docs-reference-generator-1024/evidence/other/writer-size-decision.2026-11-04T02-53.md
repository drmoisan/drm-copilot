# Writer Size Decision (issue 1024)

Timestamp: 2026-11-04T02-53
Task: [P6-T2]
Command: wc -l .claude/lib/docs/DocsReferenceWriter.psm1 .claude/lib/docs/DocsReferenceReport.psm1 (each file ends with one LF, so the wc count equals the logical line count)
EXIT_CODE: 0
Output Summary: DocsReferenceWriter.psm1 measured 542 logical lines after [P6-T1], which is at or above 500, so the contingency was applied. After the move the writer has 377 logical lines and DocsReferenceReport.psm1 has 191; both are below 500.

CONTINGENCY: applied

## Measurements

| File | Logical lines | When |
|---|---|---|
| `.claude/lib/docs/DocsReferenceWriter.psm1` | 542 | after [P6-T1], before the move |
| `.claude/lib/docs/DocsReferenceWriter.psm1` | 377 | after the move |
| `.claude/lib/docs/DocsReferenceReport.psm1` | 191 | after the move (new) |

## Change

- Moved `Format-DocsReferenceDiff`, `ConvertTo-DocsReferenceResult` and `Get-DocsReferenceReportLine`, with their private page-ordering helper `Get-DocsReferenceOrderedPage`, to the new module `.claude/lib/docs/DocsReferenceReport.psm1` (pure; no sibling import). The moved function bodies are byte-identical to the [P6-T1] text.
- `DocsReferenceWriter.psm1` imports `DocsReferenceReport.psm1` with `-ErrorAction Stop` and exports `Get-DocsReferenceGeneration` and `Invoke-DocsGenerateReferenceCommand`. The write loop iterates `Get-DocsReferenceGeneration` pages directly, which are already in ordinal path order.
- `DocsReferenceReport.psm1` exports `ConvertTo-DocsReferenceResult`, `Format-DocsReferenceDiff` and `Get-DocsReferenceReportLine` (confirmed by a PowerShell 7 import listing `ExportedFunctions`).
- NEW-MODULES now includes `LIB/DocsReferenceReport.psm1` (plan `## Terms`), so [P8-T1], [P8-T2], [P9-T3] and [P9-T6] cover it.

## Verification

- Direct `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1` over both modules: Error 0, Warning 0, Information 0; the read-only `Invoke-Formatter` comparison reports 0 files that would change.
- An in-memory end-to-end probe under SCRATCH (dry run, `-Json` dry run, `-Write`, and a second `-Write`) gave exit 0 on each run, with two `create` pages, two recorded writes, and action `none` on the second write run, both before and after the move.
