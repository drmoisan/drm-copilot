# core.json Reference-File Entry Verification (issue #491, [P5-T10])

Timestamp: 2026-08-20T11-22

Skill `references/*.md` files are enumerated by NEITHER completeness suite (confirmed empirically at
[P5-T8]: neither failing list named a single reference file). They therefore need explicit manifest
entries or they are silently dropped from pack-scoped push-downs. Precedent for the manual listing:
`.claude/skills/human-exception-runbook/example.runbook.md` at `core.json:82`.

File edited: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`
`paths` length: 136 before, 152 after (16 added: 7 from [P5-T9], 9 reference files from this task).

Command: `python -c "import json; json.load(open(...))"`
EXIT_CODE: 0
Output Summary: JSON valid, 152 paths. The diff is 17 insertions and 1 deletion, the deletion being
the previous last entry acquiring a trailing comma; no other line was reformatted.

## Per-entry search verification

Each of the nine entries was confirmed by an exact-string search of the manifest, one search per
path.

Command per row: `grep -c '"\.claude/skills/mermaid-diagram/references/<name>\.md"' extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`

| Entry | Occurrences found |
| --- | --- |
| `.claude/skills/mermaid-diagram/references/flowchart.md` | 1 |
| `.claude/skills/mermaid-diagram/references/sequence.md` | 1 |
| `.claude/skills/mermaid-diagram/references/class.md` | 1 |
| `.claude/skills/mermaid-diagram/references/state.md` | 1 |
| `.claude/skills/mermaid-diagram/references/er.md` | 1 |
| `.claude/skills/mermaid-diagram/references/c4.md` | 1 |
| `.claude/skills/mermaid-diagram/references/gantt.md` | 1 |
| `.claude/skills/mermaid-diagram/references/pie.md` | 1 |
| `.claude/skills/mermaid-diagram/references/other-types.md` | 1 |

Nine of nine present, exactly once each. The on-disk reference directory contains nine `.md` files,
so the manifest and the directory agree in both directions.

## The seven [P5-T9] entries

| Entry | Present |
| --- | --- |
| `.claude/hooks/enforce-mermaid-validation.ps1` | yes |
| `.claude/rules/mermaid.md` | yes |
| `.claude/skills/mermaid-diagram/SKILL.md` | yes |
| `.claude/lib/mermaid/MermaidGrammar.psm1` | yes |
| `.claude/lib/mermaid/MermaidLineScanner.psm1` | yes |
| `.claude/lib/mermaid/MermaidMarkdownFences.psm1` | yes |
| `.claude/lib/mermaid/MermaidValidation.psm1` | yes |

AC-20 satisfied for the manifest half; the suite half is recorded at [P5-T11], [P7-T6], and
[P7-T8].
