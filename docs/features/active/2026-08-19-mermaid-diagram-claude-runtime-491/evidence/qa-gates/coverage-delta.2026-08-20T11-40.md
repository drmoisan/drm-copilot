# Final QA Gate: Coverage Delta (issue #491, [P7-T5])

Timestamp: 2026-08-20T11-40

Both compared runs use the SAME command, the repo-module run:
`pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psm1; Invoke-PoshQCTest -Root (Get-Location).Path"`

- Baseline report: `evidence/baseline/powershell-coverage.baseline.2026-08-19T10-23.xml`, the copy
  preserved by [P0-T5]. The live report path `artifacts/pester/powershell-coverage.xml` is
  overwritten by every run and `artifacts/` is gitignored, so the preserved copy is the only
  baseline that still exists.
- Post-change report: `artifacts/pester/powershell-coverage.xml`, written by the [P7-T4] run.

Extraction method for every figure below: JaCoCo `<counter type="LINE">` elements summed per
`<class sourcefilename>`, then `covered / (covered + missed)`. No `line-rate` attribute exists in
this report format.

## Headline figures

| Measurement | Baseline | Post-change |
| --- | --- | --- |
| Overall line coverage | 95.97% | 96.19% |
| Covered / total lines | 5168 / 5385 | 5763 / 5991 |
| Distinct source files measured | 59 | 64 |
| Tests passed / failed / skipped | 2786 / 0 / 9 | 3086 / 0 / 9 |

The overall headline moved by +0.22 percentage points. That difference is NOT a regression signal in
either direction and must not be read as one: the post-change run measures a different denominator,
because the final `CodeCoverage.Path` set equals the baseline set plus exactly the five files
registered by [P3-T6]. The measured-file count differs by exactly 5, which confirms the two sets
differ by that registration and by nothing else.

The test count grew by exactly 300, which equals the tests this feature adds: 271 in
`tests/scripts/claude-lib/mermaid/`, 28 in
`tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1`, and 1 added to
`tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`. The skip count is unchanged at 9,
so this change introduced no skipped test.

## No-regression check, performed per file over the common set

| Check | Result |
| --- | --- |
| Files common to both reports | 59 |
| Files present in the baseline but absent from the final report | 0 |
| Files whose line coverage decreased | **0** |
| Files new in the final report | 5 |

Zero per-file regressions. Because no baseline file dropped out of the final report, the common set
is the entire baseline set, so the check covers every previously-measured file rather than a subset.

## New-file threshold check (>= 85% line coverage)

| File | Line coverage | Covered / total | Threshold |
| --- | --- | --- | --- |
| `.claude/lib/mermaid/MermaidGrammar.psm1` | 99.30% | 141 / 142 | PASS |
| `.claude/lib/mermaid/MermaidLineScanner.psm1` | 100.00% | 163 / 163 | PASS |
| `.claude/lib/mermaid/MermaidMarkdownFences.psm1` | 100.00% | 79 / 79 | PASS |
| `.claude/lib/mermaid/MermaidValidation.psm1` | 98.66% | 147 / 149 | PASS |
| `.claude/hooks/enforce-mermaid-validation.ps1` | 89.04% | 65 / 73 | PASS |

All five clear the uniform 85% line threshold. No branch-coverage gate applies: Pester does not
measure branch coverage, and per `.claude/rules/quality-tiers.md` the branch threshold is not
applied to PowerShell. Command coverage is reported by the runner for information only and carries
no threshold.

Every value above is a measured number; no placeholder appears in this artifact. AC-22 satisfied.
