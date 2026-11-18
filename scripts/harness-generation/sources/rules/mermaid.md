<!-- harness-section: head -->

# Mermaid Diagram Standards

This rule governs Mermaid diagrams in this repository. The authoring workflow, the per-type syntax
references, and the generation recipes live in `.claude/skills/mermaid-diagram/SKILL.md`; this file
carries the constraints.

The pinned Mermaid documentation version for the whole surface is **11.17.0**
(https://mermaid.js.org/intro/syntax-reference.html). The keyword allowlist and the per-type arrow
token sets are a snapshot of that version, recorded in `.claude/lib/mermaid/MermaidGrammar.psm1`.

<!-- harness-section: diagram-file-conventions -->
## Diagram File Conventions

- A standalone diagram belongs in a `.mmd` file (`.mermaid` is also recognized). The whole file is
  one diagram: optional YAML frontmatter, optional `%%{init: ...}%%` directives, the diagram-type
  keyword line, then the body.
- A diagram embedded in prose belongs in a fenced ` ```mermaid ` block in the Markdown file that
  discusses it. GitHub renders such fences natively in Markdown, pull requests, and issues.
- The first line after any frontmatter, directive, comment, and blank line must be the
  diagram-type keyword. Mermaid keywords are case-sensitive: `C4Context`, `stateDiagram-v2`, and
  `sequenceDiagram` are exact spellings.
- Mermaid has no backslash escape. To place a double quote inside a label, use the `#quot;` entity;
  a backslash before a closing quote closes the span rather than escaping it.
- Do not commit a diagram file as a test fixture. Diagram fixtures belong in PowerShell
  here-strings inside the Pester suites, because a `PreToolUse` hook fires on the write of its own
  fixtures.

<!-- harness-section: validation-mandate -->
## Validation Mandate

Every diagram written to this repository passes through the structural gate
`.claude/hooks/enforce-mermaid-validation.ps1` on `Write` and `Edit`. The gate is registered in the
`Write|Edit` matcher of `.claude/settings.json` and runs the dependency-free validator in
`.claude/lib/mermaid/`.

What the gate rejects, naming the defect class and the line number:

- a missing, non-keyword, or misspelled first-line diagram keyword;
- YAML frontmatter that opens with `---` and is never closed;
- an empty or whitespace-only diagram body;
- unbalanced `[]`, `()`, or `{}` on structural lines of a bracket-structural diagram type,
  computed by a quote-aware scanner;
- an unterminated double-quoted label;
- an arrow or edge token that is not valid for the declared diagram type;
- a `subgraph` with no matching `end`.

What the gate does NOT do, stated plainly so "validated" is not overclaimed: it does not prove a
diagram renders, and it performs no parse. Semantic and deep-grammar errors — an undefined node
reference in a `click` statement, a malformed gantt date, an invalid `classDef` property, a wrong
`section` structure, an invalid participant reference — are outside its reach. A `Valid` verdict
means no defect of a checked class was found, nothing more.

Where the gate declines to judge, it allows. An unknown but keyword-shaped first-line token is
allowed with a drift warning, because the allowlist is a pinned snapshot and an out-of-date
allowlist must cost a warning rather than a false rejection. Diagram types outside the deep-checked
set (flowchart, sequence, class, state, ER) are keyword-checked only. An `Edit` payload carries a
fragment rather than the resulting file, so the syntax check is not attempted and the next `Write`
catches a regression.

<!-- harness-section: managed-diagrams-do-not-hand-edit -->
## Managed Diagrams: Do Not Hand-Edit

A `.mmd` or `.mermaid` file whose frontmatter carries an `id:` key is connected to the Mermaid Chart
cloud sync workflow:

```yaml
---
id: cbd9e9ba-a2cb-47c5-a98e-8c28a753428d
---
```

Such a diagram must not be hand-edited. The next sync overwrites the edit, so the change is lost
and the diff is misleading in the meantime. The gate denies both `Write` and `Edit` on a file whose
on-disk frontmatter carries a non-empty `id:`, with the reason token
`MERMAID_MANAGED_DIAGRAM_BLOCKED:`.

To change a managed diagram, use the Mermaid Chart sync workflow in VS Code (Mermaid Chart
extension: **Sync Diagram with Mermaid**, then **Review Mermaid Sync**) and pull the synced result.
Connecting a diagram, reviewing a sync, and accepting or rejecting synced commits are interactive
VS Code actions; they are human steps, not automatable from a Claude Code session.

The opt-out marker below never suppresses this constraint: the marker applies to fenced blocks in
Markdown, and the managed-diagram gate is keyed on diagram file paths.

<!-- harness-section: opt-out-marker-for-deliberate-counter-examples -->
## Opt-Out Marker for Deliberate Counter-Examples

Documentation legitimately quotes invalid Mermaid to demonstrate a defect. Placing the exact HTML
comment on the line immediately preceding a fence suppresses validation for that one block:

```text
<!-- mermaid-validator: ignore -->
```

Rules for the marker:

- The comment text is exactly `mermaid-validator: ignore`, case-sensitive. Whitespace around the
  line and inside the comment delimiters is permitted.
- It must sit on the line immediately before the opening ` ```mermaid ` fence, with no intervening
  line, blank or otherwise.
- Its scope is exactly one block. A second counter-example needs its own marker; an unmarked
  invalid block in the same file is still denied.
- It applies only to fenced blocks in Markdown. Diagram files have no opt-out: a diagram file is by
  definition a diagram.
- A ` ```mermaid ` fence nested inside an outer, longer fence is already treated as example text
  rather than a diagram and needs no marker.

<!-- harness-section: out-of-scope-the-non-portable-extension-mechanisms -->
## Out of Scope: The Non-Portable Extension Mechanisms

The Copilot instruction pack at `.github/instructions/mermaid.instructions.md` relies on VS Code
extension mechanisms that no Claude Code session can invoke. They are recorded here so a later
reader does not read the omission as an oversight. The same record appears in
`.claude/skills/mermaid-diagram/SKILL.md`.

| Mechanism | Why it is not ported | What replaces it |
| --- | --- | --- |
| `mermaid-diagram-validator` LM tool | A VS Code Language Model API tool contributed by the extension; not an MCP tool and not callable from a Claude session | The structural gate in this repository, weaker than a real parse and documented as such |
| `mermaid-diagram-preview` LM tool, `mermaidChart.preview` | A VS Code webview | The conditional rendering paths in the skill; GitHub renders fences natively |
| `get-syntax-docs-mermaid` LM tool | A VS Code LM API tool | The bundled per-type references under the skill, pinned to 11.17.0, with a documented `WebFetch` fallback to mermaid.js.org |
| The sixteen `mermaidChart.*` command IDs | Each needs the VS Code command API, an active editor, and the extension host | Portable capabilities are ported by substitution: validation to the hook, generation to the skill recipes, preview to conditional rendering, sync cooperation to the `id:` guard. The command IDs themselves are not ported |
| `@mermaid-chart` Copilot Chat slash commands | Copilot Chat participants do not exist on the Claude surface | The eight generation intents are skill recipe sections |
| `mermaidChart.repairDiagram`, `mermaidChart.improveDiagram` | Mermaid AI credits and extension UI | The gate's specific defect messages plus ordinary editing. No credit-consuming path exists on this surface, so there is nothing to warn about |
| `mermaidChart.login`, `logout`, `connectDiagramToMermaidChart`, `syncDiagramWithMermaid`, `reviewAppCommits`, `regenerateDiagramWithMermaidAI` | Interactive OAuth and extension UI against the Mermaid Chart cloud | Human steps in VS Code. The automatable half is in scope and delivered: the `id:` managed-diagram guard above |
| `mermaidChart.createMermaidFile`, `mermaidChart.installAiSkills` | Extension UI; the second is the Copilot-surface distribution mechanism | Creating a diagram file is an ordinary `Write`. The Claude distribution mechanism is the bundled resources mirror plus the `pack-manifests/core.json` entry |
| Deep `mmdc`/Chromium validation | Chromium-backed, seconds-level latency, no validate-only mode; unfit for a per-write gate | Recorded as an optional CI-side follow-up consuming the validator's structured result |

<!-- harness-section: example -->
## Example

A minimal valid diagram file, frontmatter included:

```mermaid
---
title: Request handling
---
flowchart LR
    A[Client] --> B{Authenticated}
    B -->|yes| C[Handler]
    B -->|no| D[Reject]
```
<!-- harness-section: head-2 -->
# Mermaid AI Skills

When the user asks to create, edit, or visualize any diagram, use the Mermaid
VS Code extension tools and commands described below.

<!-- harness-section: workflow -->
## Workflow

1. Determine the diagram type and generate Mermaid syntax.
2. Write the diagram to a `.mmd` file in the project.
3. Validate syntax: correct first-line keyword, arrow types, balanced brackets.
4. Preview via the Mermaid extension — open the `.mmd` file (auto-preview) or run
   **MermaidChart: Preview Diagram** (`mermaidChart.preview`).

<!-- harness-section: lm-tools-call-these-for-every-diagram-interaction -->
## LM Tools — call these for every diagram interaction

- `mermaid-diagram-validator` — validate Mermaid syntax before presenting any diagram
- `mermaid-diagram-preview` — render a live preview inside VS Code after generating
- `get-syntax-docs-mermaid` — fetch correct syntax docs for any diagram type

<!-- harness-section: vs-code-commands -->
## VS Code Commands

Invoke via Command Palette or the VS Code command API (GitHub Copilot in VS Code only).
Do not invent command IDs. Prefer writing/editing `.mmd` files when a command is not needed.

### Diagram editing & preview
- **Preview** (`mermaidChart.preview`) — preview the active Mermaid editor (`.mmd` / `.mermaid` must be open).
- **Create Diagram** (`mermaidChart.createMermaidFile`) — creates a demo flowchart and opens preview side by side.
- **Repair Diagram** (`mermaidChart.repairDiagram`) — Mermaid AI repair for the active diagram; uses Mermaid AI credits — tell the user before running.
- **Improve Diagram** (`mermaidChart.improveDiagram`) — uses Copilot / LM API; suggests layout + styling variants for the active diagram.

### Generate diagrams (GitHub Copilot required)
- **Generate Diagram from Code** (`mermaidChart.generateDiagramFromCode`)
- **Generate Cloud Diagram** (`mermaidChart.generateCloudDiagram`)
- **Generate ER Diagram** (`mermaidChart.generateERDiagram`)
- **Generate Docker Diagram** (`mermaidChart.generateDockerDiagram`)
- **Open AI Chat** (`mermaidChart.openCopilotChat`)

### Mermaid Chart cloud
- **Login** (`mermaidChart.login`) / **Logout** (`mermaidChart.logout`)
- **Connect Diagram** (`mermaidChart.connectDiagramToMermaidChart`) — link a local diagram to Mermaid Chart.
- **Sync Diagram** (`mermaidChart.syncDiagramWithMermaid`) — only for diagrams already connected (frontmatter has `id:`). Example:
  ```yaml
  ---
  id: cbd9e9ba-a2cb-47c5-a98e-8c28a753428d
  ---
  ```

### Review Mermaid Sync
For diagrams updated by the Mermaid Chart GitHub Sync app (or pre-commit regenerate):
- **Review Mermaid Sync** (`mermaidChart.reviewAppCommits`) — start / open the review flow.
- **Regenerate with Mermaid AI** (`mermaidChart.regenerateDiagramWithMermaidAI`) — regenerate from source references.
Do not manually rewrite diagrams managed by this workflow. Accept/reject/diff UI actions stay in the extension UI.

### Install / update this pack
- **MermaidChart: Install AI Skills…** (`mermaidChart.installAiSkills`)

<!-- harness-section: mermaid-chart-slash-commands -->
## @mermaid-chart slash commands

| Command | Purpose |
|---|---|
| `/generate_diagram_from_code` | General diagram from any source file |
| `/generate_execution_sequence` | Sequence diagram from code flow |
| `/generate_er_diagram` | ER diagram from schema / models |
| `/generate_cloud_architecture_diagram` | Cloud / CI-CD architecture |
| `/generate_docker_diagram` | Architecture from Dockerfiles |
| `/generate_c4_topdown_architecture` | C4 top-down architecture |
| `/analyze_code_ownership` | Code ownership diagram |
| `/generate_dependency_diagram` | Dependency / security visualisation |

<!-- harness-section: rules -->
## Rules

1. Always call `mermaid-diagram-validator` before showing any diagram.
2. Always call `mermaid-diagram-preview` after generating a diagram.
3. Use `get-syntax-docs-mermaid` before generating an unfamiliar diagram type.
4. Prefer `@mermaid-chart` slash commands for complex generation.
5. Write diagrams to `.mmd` files; never return unvalidated Mermaid syntax.
6. Warn the user before Repair (Mermaid AI credits).
7. Cooperate with the Sync workflow — do not manually regenerate managed diagrams.

<!-- harness-section: docs -->
## Docs

More commands and features: https://marketplace.visualstudio.com/items?itemName=MermaidChart.vscode-mermaid-chart
