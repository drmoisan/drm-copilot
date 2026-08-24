# Final QA Gate: Pester with Coverage (issue #491, [P7-T4])

Timestamp: 2026-08-20T11-40

Type checking is not applicable to PowerShell, so the loop is format, lint, test.

Command: `pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root (Get-Location).Path"`
EXIT_CODE: 0
Output Summary: `Tests Passed: 3086, Failed: 0, Skipped: 9, Inconclusive: 0, NotRun: 0`, completed in
166.47s. Runner coverage line: "Covered 96.03% / 0%. 8,412 analyzed Commands in 70 Files." (that
96.03% is command coverage and the 0% is the configured `CoveragePercentTarget`, not a measurement).

Numeric LINE-coverage headline recomputed from `artifacts/pester/powershell-coverage.xml` by the
documented JaCoCo method — `covered / (covered + missed)` summed over `<counter type="LINE">`
elements per `<class sourcefilename>` — because that report format carries no `line-rate` attribute:

- **overall line coverage: 96.19%** (5763 covered / 5991 total lines) across 64 distinct source
  files.

The recorded command is the repo-module run. The MCP `run_poshqc_test` gate was also run and
returned ok:true, but no coverage figure in this feature comes from it: the MCP-published PoshQC
resolves its own bundled `settings/pester.runsettings.psd1` and does not consume the repo
`CodeCoverage.Path` registration (recorded at
`docs/features/potential/2026-08-19-mcp-poshqc-test-ignores-repo-runsettings-coverage.md`, verified
at [P0-T11]).

Per-file line coverage for the five files registered by [P3-T6]:

| File | Line coverage | Covered / total |
| --- | --- | --- |
| `.claude/lib/mermaid/MermaidGrammar.psm1` | 99.30% | 141 / 142 |
| `.claude/lib/mermaid/MermaidLineScanner.psm1` | 100.00% | 163 / 163 |
| `.claude/lib/mermaid/MermaidMarkdownFences.psm1` | 100.00% | 79 / 79 |
| `.claude/lib/mermaid/MermaidValidation.psm1` | 98.66% | 147 / 149 |
| `.claude/hooks/enforce-mermaid-validation.ps1` | 89.04% | 65 / 73 |

The 9 skipped tests are pre-existing skips in unrelated suites; the baseline run at [P0-T5] recorded
the same skip count, so this change introduced none.
