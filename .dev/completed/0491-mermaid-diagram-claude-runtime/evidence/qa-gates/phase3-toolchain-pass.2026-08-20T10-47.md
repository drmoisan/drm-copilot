# Phase 3 Toolchain Pass and Coverage Registration Check (issue #491, [P3-T9])

Timestamp: 2026-08-20T10-47

## Stage 1 — format

Command: `mcp__drm-copilot__run_poshqc_format`
EXIT_CODE: 0
Output Summary: ok:true. No file modified on the final pass; the repo and bundled
`pester.runsettings.psd1` copies remained byte-identical afterwards (`cmp` clean).

## Stage 2 — analyze

Command: `mcp__drm-copilot__run_poshqc_analyze`
EXIT_CODE: 0
Output Summary: ok:true — zero PSScriptAnalyzer findings.

## Stage 3 — test (pass/fail gate)

Command: `mcp__drm-copilot__run_poshqc_test`
EXIT_CODE: 0
Output Summary: ok:true.

## Stage 3b — coverage-bearing repo-module run

Command: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root (Get-Location).Path"`
EXIT_CODE: 0
Output Summary: Tests Passed: 3086, Failed: 0, Skipped: 9, Inconclusive: 0. Runtime 162.92s.
"Covered 96.03% / 0%. 8,412 analyzed Commands in 70 Files." Overall LINE coverage recomputed
from `artifacts/pester/powershell-coverage.xml` by the documented JaCoCo method
(`covered / (covered + missed)` summed over `<counter type="LINE">` per `<class sourcefilename>`):
96.19% (5763 covered / 5991 total lines) across 64 distinct source files.

Coverage figures come only from this repo-module run, never from the MCP test tool, whose bundled
runsettings do not consume the repo `CodeCoverage.Path` registration.

## Per-file line coverage, the five files registered by [P3-T6]

| File | Line coverage | Covered / total | >= 85% |
| --- | --- | --- | --- |
| `.claude/lib/mermaid/MermaidGrammar.psm1` | 99.30% | 141 / 142 | YES |
| `.claude/lib/mermaid/MermaidLineScanner.psm1` | 100.00% | 163 / 163 | YES |
| `.claude/lib/mermaid/MermaidMarkdownFences.psm1` | 100.00% | 79 / 79 | YES |
| `.claude/lib/mermaid/MermaidValidation.psm1` | 98.66% | 147 / 149 | YES |
| `.claude/hooks/enforce-mermaid-validation.ps1` | 89.04% | 65 / 73 | YES |

All five appear in the report, confirming the `CodeCoverage.Path` registration took effect on the
repo-module path, and all five clear the uniform 85% line threshold. No branch-coverage gate
applies to Pester.

## Loop restarts recorded

The loop restarted once. The first analyze pass returned ok:false with
"PSScriptAnalyzer reported 2 issue(s)": `PSUseShouldProcessForStateChangingFunctions` against the
`New-WriteToolInput` and `New-EditToolInput` helpers in
`tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1`. Both are pure JSON-assembly
helpers, so they were renamed to `Get-WriteToolInputJson` and `Get-EditToolInputJson` rather than
given a `ShouldProcess` implementation they have no state to guard. The loop restarted at
formatting and all stages then passed.

Two hook defects were found and fixed before this pass, by direct invocation rather than by the
toolchain (no stage would have caught either):

1. The entry point returned an exit code from the same function that emitted the decision JSON, so
   the caller's `exit (...)` consumed the JSON and nothing reached stdout. Every decision was
   silently lost. The entry point now emits only the JSON and the script exits 0 unconditionally.
   The hook file records why in a comment so the pattern is not reintroduced.
2. `Get-MermaidFenceBlock` is defined in `MermaidMarkdownFences.psm1`, a nested module of
   `MermaidValidation.psm1`, so importing only the validation module left the Markdown path calling
   an unresolved command. `MermaidValidation.psm1` now re-exports `Get-MermaidFenceBlock` and
   `Split-MermaidTextLine` explicitly, which is what makes the single documented hook import
   sufficient.
