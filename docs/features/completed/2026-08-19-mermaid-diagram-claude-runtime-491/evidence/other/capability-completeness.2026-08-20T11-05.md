# Capability Completeness Cross-Check (issue #491, [P4-T6])

Timestamp: 2026-08-20T11-05

Source walked end to end: `.github/instructions/mermaid.instructions.md` (81 lines, frontmatter
`applyTo: "**"`). Every mechanism it names appears below exactly once, with its disposition. A
mechanism is either PORTED by a named delivered surface or OUT OF SCOPE with the reason recorded in
delivered text. There are no silent drops.

Delivered surfaces referenced by name:

- **HOOK** — `.claude/hooks/enforce-mermaid-validation.ps1`, registered in the `Write|Edit` matcher
  of `.claude/settings.json`.
- **LIB** — `.claude/lib/mermaid/*.psm1` (grammar, line scanner, fence tracker, validation).
- **RULE** — `.claude/rules/mermaid.md`.
- **SKILL** — `.claude/skills/mermaid-diagram/SKILL.md` plus `references/*.md`.

## Workflow section (four steps)

| Copilot step | Disposition | Where |
| --- | --- | --- |
| 1. Determine the diagram type and generate Mermaid syntax | PORTED | SKILL "Workflow: Generate, Validate, Render" steps 1-2; per-type keyword forms in each `references/*.md` |
| 2. Write the diagram to a `.mmd` file in the project | PORTED and widened | SKILL step 3; RULE "Diagram File Conventions". Widened by decision D2 to fenced Markdown blocks, because the repository contains zero `.mmd` files and a gate scoped to `.mmd` only could never fire |
| 3. Validate syntax: first-line keyword, arrow types, balanced brackets | PORTED | HOOK plus LIB. All three named defect classes are checked, plus frontmatter, empty body, unterminated quote, and `subgraph`/`end`. RULE "Validation Mandate" lists what is checked and, explicitly, what is not |
| 4. Preview via the Mermaid extension (auto-preview or `mermaidChart.preview`) | OUT OF SCOPE, replaced | SKILL "Rendering" gives the three conditional paths (`Artifact`, `SendUserFile display: render`, then state-the-path with the VS Code and GitHub routes). RULE out-of-scope table row 2 records the reason |

## LM tools (three)

| Tool | Disposition | Where |
| --- | --- | --- |
| `mermaid-diagram-validator` | OUT OF SCOPE, replaced by substitution | HOOK plus LIB. RULE out-of-scope row 1. The replacement is weaker than a real parse, and both RULE and SKILL say so in the "what validated means" text, so the weaker guarantee is not overclaimed |
| `mermaid-diagram-preview` | OUT OF SCOPE, replaced | SKILL "Rendering"; RULE out-of-scope row 2 |
| `get-syntax-docs-mermaid` | OUT OF SCOPE, replaced by substitution | SKILL "Syntax References": nine bundled per-type references pinned to 11.17.0, plus the documented `WebFetch` fallback to the pinned pages. RULE out-of-scope row 3 |

## VS Code command IDs (sixteen)

All sixteen require the VS Code command API, an active editor, and the extension host. All are OUT
OF SCOPE, recorded in RULE out-of-scope rows 4 through 9 and summarized in SKILL "Out of Scope".
The portable capability behind each is listed here.

| Command ID | Capability disposition |
| --- | --- |
| `mermaidChart.preview` | Replaced by SKILL "Rendering" |
| `mermaidChart.createMermaidFile` | Replaced: creating a diagram file is an ordinary `Write` (RULE "Diagram File Conventions") |
| `mermaidChart.repairDiagram` | Replaced: the gate's defect class plus line number, and ordinary editing. No Mermaid AI credit path exists on this surface |
| `mermaidChart.improveDiagram` | Replaced: layout and styling guidance is in SKILL recipes and the `references/*.md` structural conventions |
| `mermaidChart.generateDiagramFromCode` | Replaced by SKILL recipe 1 |
| `mermaidChart.generateCloudDiagram` | Replaced by SKILL recipe 4 |
| `mermaidChart.generateERDiagram` | Replaced by SKILL recipe 3 |
| `mermaidChart.generateDockerDiagram` | Replaced by SKILL recipe 5 |
| `mermaidChart.openCopilotChat` | Not applicable: no Copilot Chat surface exists in a Claude session |
| `mermaidChart.login` | OUT OF SCOPE: interactive OAuth; a human step in VS Code |
| `mermaidChart.logout` | OUT OF SCOPE: same |
| `mermaidChart.connectDiagramToMermaidChart` | OUT OF SCOPE for the action; its RESULT is recognized: the `id:` frontmatter marker drives the managed-diagram guard |
| `mermaidChart.syncDiagramWithMermaid` | OUT OF SCOPE for the action; the automatable half is delivered as the managed-diagram guard, and the deny reason names the sync workflow as the corrective route |
| `mermaidChart.reviewAppCommits` | OUT OF SCOPE: extension review UI; named in RULE as the human step |
| `mermaidChart.regenerateDiagramWithMermaidAI` | OUT OF SCOPE: Mermaid AI plus extension UI |
| `mermaidChart.installAiSkills` | OUT OF SCOPE: the Copilot-surface distribution mechanism. The Claude equivalent is the bundled resources mirror plus the `pack-manifests/core.json` entry, which this feature delivers |

## `@mermaid-chart` slash commands (eight)

The participant mechanism is OUT OF SCOPE (Copilot Chat participants do not exist on the Claude
surface; RULE out-of-scope row 5). All eight generation intents are PORTED as SKILL recipe sections.

| Slash command | SKILL recipe |
| --- | --- |
| `/generate_diagram_from_code` | 1. Diagram from code |
| `/generate_execution_sequence` | 2. Execution sequence |
| `/generate_er_diagram` | 3. ER diagram |
| `/generate_cloud_architecture_diagram` | 4. Cloud or CI/CD architecture |
| `/generate_docker_diagram` | 5. Docker architecture |
| `/generate_c4_topdown_architecture` | 6. C4 top-down architecture |
| `/analyze_code_ownership` | 7. Code ownership |
| `/generate_dependency_diagram` | 8. Dependency or security visualisation |

## Rules section (seven)

| Copilot rule | Disposition | Where |
| --- | --- | --- |
| 1. Always call `mermaid-diagram-validator` before showing any diagram | PORTED, made deterministic | HOOK runs on every in-scope `Write`; it is enforcement rather than instruction, so it does not depend on the agent remembering. RULE "Validation Mandate" |
| 2. Always call `mermaid-diagram-preview` after generating | OUT OF SCOPE as a mandate; delivered as a conditional | SKILL "Rendering". D6: `Artifact` and `SendUserFile` are harness-dependent and absent from some sessions, so an unconditional preview mandate is not portable. The hook performs no rendering, which SKILL states explicitly |
| 3. Use `get-syntax-docs-mermaid` before an unfamiliar type | PORTED by substitution | SKILL workflow step 1 plus "Syntax References" and the `WebFetch` fallback |
| 4. Prefer `@mermaid-chart` slash commands for complex generation | OUT OF SCOPE; capability retained | The eight recipes replace the participant. SKILL "Generation Recipes" |
| 5. Write diagrams to `.mmd` files; never return unvalidated Mermaid syntax | PORTED | RULE "Diagram File Conventions" plus the HOOK. The "never unvalidated" half is enforced for writes; SKILL step 4 gives the pre-write `Test-MermaidDiagram` call for content that is shown before being written |
| 6. Warn the user before Repair (Mermaid AI credits) | NOT APPLICABLE, recorded | No credit-consuming path exists on this surface, so there is nothing to warn about. RULE out-of-scope row 6 states this rather than dropping the rule silently |
| 7. Cooperate with the Sync workflow; do not manually regenerate managed diagrams | PORTED, made deterministic | The managed-diagram guard: HOOK denies `Write` and `Edit` on a diagram file whose on-disk frontmatter carries a non-empty `id:`, reason token `MERMAID_MANAGED_DIAGRAM_BLOCKED:`. RULE "Managed Diagrams: Do Not Hand-Edit" |

## Remaining named items

| Item | Disposition |
| --- | --- |
| The `id:` frontmatter example in the Sync Diagram section | PORTED as the managed-diagram detector `Test-MermaidManagedDiagram`, and quoted in RULE |
| "Accept/reject/diff UI actions stay in the extension UI" | OUT OF SCOPE, recorded in RULE as a human step |
| "Do not invent command IDs" | Honoured: no `mermaidChart.*` command ID is invoked anywhere in the delivered surfaces; the two that appear in prose (Sync Diagram, Review Mermaid Sync) are named as human VS Code actions |
| Docs link (marketplace page) | Superseded by the pinned mermaid.js.org references, which are the syntax source of record for this surface |

## Result

Mechanisms named in the source: 4 workflow steps, 3 LM tools, 16 command IDs, 8 slash commands,
7 rules, and 4 remaining items = 42. Dispositions recorded: 42. Silently dropped: 0.
