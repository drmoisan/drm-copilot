# Documentation Example Validation (issue #491, [P4-T7])

Timestamp: 2026-08-20T11-08

Every fenced mermaid block embedded in the new rule, SKILL.md, and the nine reference files was
extracted with `Get-MermaidFenceBlock` and validated with `Test-MermaidDiagram`, using the same
library the hook uses and the same file-relative line offset.

Command: `pwsh -NoProfile -File <scratchpad>/docblocks.ps1` (imports
`./.claude/lib/mermaid/MermaidValidation.psm1`, walks `.claude/rules/mermaid.md`,
`.claude/skills/mermaid-diagram/SKILL.md`, and `.claude/skills/mermaid-diagram/references/*.md`)
EXIT_CODE: 0
Output Summary: 13 mermaid fences found across 13 files scanned; all 13 verdicts `Valid`; zero
invalid blocks and therefore zero blocks needing the D3 opt-out marker.

| File | Fence opens at line | Verdict | Diagram type |
| --- | --- | --- | --- |
| `.claude/rules/mermaid.md` | 134 | Valid | flowchart |
| `.claude/skills/mermaid-diagram/SKILL.md` | 174 | Valid | flowchart |
| `.claude/skills/mermaid-diagram/references/c4.md` | 35 | Valid | c4 |
| `.claude/skills/mermaid-diagram/references/class.md` | 42 | Valid | class |
| `.claude/skills/mermaid-diagram/references/er.md` | 36 | Valid | er |
| `.claude/skills/mermaid-diagram/references/flowchart.md` | 55 | Valid | flowchart |
| `.claude/skills/mermaid-diagram/references/gantt.md` | 38 | Valid | gantt |
| `.claude/skills/mermaid-diagram/references/other-types.md` | 56 | Valid | gitgraph |
| `.claude/skills/mermaid-diagram/references/other-types.md` | 66 | Valid | timeline |
| `.claude/skills/mermaid-diagram/references/other-types.md` | 73 | Valid | journey |
| `.claude/skills/mermaid-diagram/references/pie.md` | 25 | Valid | pie |
| `.claude/skills/mermaid-diagram/references/sequence.md` | 45 | Valid | sequence |
| `.claude/skills/mermaid-diagram/references/state.md` | 31 | Valid | state |

INVALID_UNMARKED_BLOCKS: 0

Notes on non-mermaid fences in the same files, which the extractor correctly ignored: the `yaml`
fence carrying the `id:` example and the two `text` fences carrying the opt-out marker are not
mermaid fences, so no diagram verdict applies to them. The `powershell` fence in SKILL.md is
likewise not a diagram. The marker text inside those `text` fences does not act as an opt-out
marker for anything, because no mermaid fence immediately follows it.
