# Final QA Gate: 500-Line File Limit (issue #491, [P7-T12])

Timestamp: 2026-08-20T11-45

Command: `wc -l` over every new or modified PowerShell file of this change
EXIT_CODE: 0
Output Summary: every file is at or under the 500-line hard limit in
`.claude/rules/general-code-change.md`. Files over the limit: 0.

## Production files (five)

| File | Lines | Limit |
| --- | --- | --- |
| `.claude/hooks/enforce-mermaid-validation.ps1` | 390 | PASS |
| `.claude/lib/mermaid/MermaidGrammar.psm1` | 491 | PASS |
| `.claude/lib/mermaid/MermaidLineScanner.psm1` | 488 | PASS |
| `.claude/lib/mermaid/MermaidMarkdownFences.psm1` | 298 | PASS |
| `.claude/lib/mermaid/MermaidValidation.psm1` | 496 | PASS |

## Test files (six new, one modified)

| File | Lines | Limit |
| --- | --- | --- |
| `tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1` | 375 | PASS |
| `tests/scripts/claude-lib/mermaid/MermaidLineScanner.Tests.ps1` | 323 | PASS |
| `tests/scripts/claude-lib/mermaid/MermaidMarkdownFences.Tests.ps1` | 348 | PASS |
| `tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1` | 488 | PASS |
| `tests/scripts/claude-lib/mermaid/MermaidValidationAcceptMatrix.Tests.ps1` | 234 | PASS |
| `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1` | 389 | PASS |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (modified) | 151 | PASS |

## Modified data file

| File | Lines | Limit |
| --- | --- | --- |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | 194 | PASS |

## Corrections made during execution to satisfy this limit

- `MermaidGrammar.psm1` arrived from the interrupted run at 563 lines, over the limit. It was
  brought to 491 by compacting the data representation rather than by splitting the module: the 27
  keyword-accept diagram types moved into two compact name-to-keywords maps expanded by one loop,
  the five deep entries were reflowed, the export list was reflowed from a backtick continuation to
  an array, and single-return guard blocks were collapsed to the repo's existing one-line form. No
  grammar data was lost, so the "five production files" count that [P3-T6], the [P5] mirror
  batches, the `core.json` entries, and [P7-T5] all depend on is unchanged.
- `MermaidValidation.Tests.ps1` was first written at 534 lines. It was brought to 488 by inlining
  each here-string into its `Test-MermaidDiagram` call (removing a separate assignment line per
  case), tightening the header, and dropping five fixture lines that carried no assertion. No test
  case was removed.

The four `.claude` Markdown surfaces are exempt from the 500-line limit as documentation, and the
largest of them (`.claude/skills/mermaid-diagram/SKILL.md`, 184 lines) is well under the
skill-template's own 500-line body ceiling. `.claude/rules/mermaid.md` is 142 lines; the nine
`references/*.md` files range from 32 to 82 lines (verified by `wc -l`).
