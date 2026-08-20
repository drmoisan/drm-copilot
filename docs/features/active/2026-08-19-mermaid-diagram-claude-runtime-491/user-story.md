# `2026-08-19-mermaid-diagram-claude-runtime` — User Story

- Issue: #491
- Owner: drmoisan
- Status: Ready for planning
- Last Updated: 2026-08-19

## Story Statement

- As a Claude Code agent authoring a Mermaid diagram in this repository, I want a deterministic
  validation gate on `Write`/`Edit` plus bundled syntax references and a documented
  generate-validate-render workflow, so that I cannot land structurally invalid Mermaid in a
  committed artifact and I can author unfamiliar diagram types correctly without VS Code-hosted
  tools.
- As a developer reading committed documentation and pull requests, I want every embedded Mermaid
  diagram to render instead of producing a GitHub "Unable to render rich display" error box, so
  that diagrams communicate instead of failing silently at review time.
- As a documentation author who deliberately quotes invalid Mermaid to demonstrate a defect, I want
  an explicit, documented opt-out marker for a specific fenced block, so that the gate never blocks
  correct documentation.
- As a user of the Mermaid Chart sync workflow, I want hand-edits of managed diagrams (frontmatter
  `id:`) blocked with a pointer to the sync workflow, so that agent edits do not silently diverge a
  cloud-synced diagram.

## Problem / Why

The Mermaid Chart VS Code extension published a Copilot instruction pack that was downloaded into
`.github/instructions/mermaid.instructions.md` (commit `f70103a3`). That file governs how the
Copilot surface authors diagrams: it mandates a generate-validate-preview workflow, names three
Copilot LM tools (`mermaid-diagram-validator`, `mermaid-diagram-preview`,
`get-syntax-docs-mermaid`), enumerates VS Code command IDs, lists `@mermaid-chart` slash commands,
and states seven rules including "never return unvalidated Mermaid syntax".

The Claude runtime has no counterpart. Every capability the Copilot file relies on is
VS Code-extension-hosted and unreachable from a Claude Code session:

- The three LM tools are contributed by the extension to the VS Code Language Model API. They are
  not MCP tools and are not callable from Claude Code.
- Every `mermaidChart.*` command ID requires the VS Code command API and an active editor.
- The `@mermaid-chart` slash commands are Copilot Chat participants.

Consequently a Claude session today produces Mermaid syntax with no validation gate at all. The
repository already emits Mermaid into generated Markdown from the codex-native-converter topology
renderer (`scripts/dev_tools/codex_native_converter/reporting.py` and
`extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts`), so unvalidated
Mermaid can reach committed artifacts. Research corrected an initial assumption: the
`render_subagent_tree` MCP tool emits plain text, not Mermaid, so it is not a Mermaid emitter and
is out of scope.

## Personas & Scenarios

- Persona: **Claude Code agent (executor or documentation author)**
  - Runs non-interactively in this repository, often in a fresh worktree with no `node_modules`.
  - Cares about producing artifacts that pass review the first time; cannot call VS Code commands,
    LM tools, or Copilot Chat participants.
  - Constraint: every `Write`/`Edit` already passes through ten PreToolUse hooks; a new gate must
    be cheap, deterministic, and must never block valid content it cannot judge.
  - Frustration today: the seven rules in the Copilot pack ("never return unvalidated Mermaid")
    exist only as prose the Claude surface never even loads; there is no way to validate a diagram
    before writing it.

- Persona: **Developer (Dan) reviewing documentation and PRs**
  - Reads feature docs, research artifacts, and generated conversion reports on GitHub, where
    fenced ```` ```mermaid ```` blocks render natively.
  - Cares that a diagram either renders or is visibly flagged before merge, not discovered broken
    weeks later.

- Scenario: **Negative case — what goes wrong today, without the gate**
  - An agent is asked to document a workflow and embeds a flowchart in a feature doc. It declares
    `flowchart TD` but uses a sequence-diagram arrow `->>` on one edge, and leaves an unclosed
    bracket in a node label: `A[Start`.
  - No validation exists on the Claude surface. The `Write` succeeds, the toolchain loop has no
    Mermaid stage, review focuses on prose, and the file merges.
  - GitHub later renders the fence as an error box; the diagram communicates nothing. Nobody is
    alerted: the failure is visual-only and appears only where the Markdown is rendered. The
    repository's "never return unvalidated Mermaid syntax" rule was never enforced because the
    Copilot instruction file is invisible to Claude sessions.

- Scenario: **Authoring with the gate (valid path)**
  - An agent invokes the `mermaid-diagram` skill to produce a state diagram. The skill points it at
    `.claude/skills/mermaid-diagram/references/` for the exact `stateDiagram-v2` syntax (the
    `get-syntax-docs-mermaid` replacement), with a `WebFetch` fallback for anything the pinned
    11.17.0 references do not cover.
  - The agent writes the diagram. The `enforce-mermaid-validation.ps1` hook classifies the content,
    validates it, and allows the write.
  - The skill's rendering step runs conditionally: publish a Markdown artifact if the `Artifact`
    tool exists in the session, else `SendUserFile` with `display: render` if available, else
    report the written path and name the VS Code preview route. Rendering is never a hard gate.

- Scenario: **Authoring with the gate (invalid path)**
  - The same agent writes a flowchart containing the `->>` arrow defect above. The hook denies the
    write with exit 0 and a deny reason such as: `MERMAID_VALIDATION_BLOCKED: '<path>' declares
    'flowchart' but line 3 uses a sequence-diagram arrow '->>'. Fix the arrow or the diagram type.
    See .claude/skills/mermaid-diagram/SKILL.md.`
  - The reason names the defect and line, so the agent fixes the arrow and rewrites; the second
    write is allowed. The invalid diagram never reaches disk.

- Scenario: **Documenting a defect (opt-out)**
  - A researcher writes a document that quotes a broken diagram to demonstrate a defect class. They
    place `<!-- mermaid-validator: ignore -->` on the line immediately above that one fenced
    ```` ```mermaid ```` block, as documented in the rule and skill. The hook skips exactly that
    block; any other unmarked invalid block in the same file is still denied.

- Scenario: **Managed diagram protection**
  - A future `.mmd` file was connected to Mermaid Chart, so its frontmatter carries `id:`. An agent
    attempts an `Edit` on it. The hook reads the on-disk frontmatter, detects the marker, and
    denies with `MERMAID_MANAGED_DIAGRAM_BLOCKED:` pointing at the sync workflow — the Copilot
    pack's "do not manually rewrite managed diagrams" rule made deterministic.

- Scenario: **Fail-open safety**
  - An agent writes a diagram whose first line is `venn` — a plausible keyword newer than the
    pinned 11.17.0 allowlist. The hook allows with a drift warning rather than blocking, so Mermaid
    version drift can never cause a spurious block. Likewise, malformed hook input, partial `Edit`
    fragments, unclassifiable lines, and fences nested inside outer fences all allow.

## Acceptance Criteria

Story-level criteria; the detailed, mechanically checkable set is AC-1 through AC-25 in `spec.md`.
Each item below names the artifact or command that demonstrates it.

- [x] All four Claude surfaces exist and carry their assigned content: `.claude/rules/mermaid.md`
  (scoped standards, managed-diagram constraint, opt-out marker),
  `.claude/skills/mermaid-diagram/SKILL.md` with `references/*.md` (workflow, eight generation
  recipes, conditional rendering with file fallback, syntax references),
  `.claude/hooks/enforce-mermaid-validation.ps1` (registered in the `Write|Edit` matcher of
  `.claude/settings.json`), and `.claude/lib/mermaid/*.psm1` (structured-result validator).
  Demonstrated by: the delivered files and the `settings.json` diff. (spec AC-1..AC-4)
- [x] The validator detects each named defect class — missing/misspelled first-line keyword,
  unbalanced brackets/quotes, invalid arrow forms per declared diagram type — and does NOT reject
  the false-positive constructs research enumerated (quoted-label brackets, `#quot;` entities,
  Markdown strings, Unicode, `%%` in quoted spans, `subgraph` blocks, statement-keyword lines,
  `<br/>`, sequence post-colon text, free-text diagram types). Demonstrated by: the Pester suite
  at `tests/scripts/claude-lib/mermaid/*.Tests.ps1`. (spec AC-5..AC-10)
- [x] The hook blocks an invalid diagram write with a specific, actionable reason; allows a valid
  one; validates fenced ```` ```mermaid ```` blocks in Markdown writes; honors the
  `<!-- mermaid-validator: ignore -->` opt-out for exactly one block; blocks a hand-edit of a
  managed diagram (frontmatter `id:`); and fails open on malformed hook input. Demonstrated by:
  `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1`. (spec AC-11..AC-15)
- [x] The hook emits the correct block protocol — `hookSpecificOutput.permissionDecision = 'deny'`
  JSON on stdout with exit 0, never a nonzero exit and never `{"decision":"block"}` — and a new
  `It` block in `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` asserts the deny
  shape. Demonstrated by: the contract suite green. (spec AC-16)
- [x] A negative control proves the gate is capable of failing: a deliberately invalid here-string
  fixture is demonstrated to be rejected through the hook decision path. Demonstrated by: the named
  negative-control case in the hook Pester suite. (spec AC-17)
- [x] Every capability in the issue.md mapping table is either ported or listed as out of scope
  with a stated reason in the skill/rule text (matching the spec's `## Out of Scope`); no silent
  drops. Demonstrated by: row-by-row cross-check in feature review. (spec AC-18)
- [x] Distribution is complete: byte-identical mirrors under
  `extensions/drm-copilot/resources/claude-customizations/.claude/` and `core.json` entries for
  every new file including each skill `references/*.md` file; the pack-manifest completeness
  suites and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` are green.
  Demonstrated by: those three suites. (spec AC-19..AC-21)
- [x] Coverage and policy hold: the new hook and modules are registered in
  `pester.runsettings.psd1` `CodeCoverage.Path`, reach >= 85% line coverage (no PowerShell
  branch-coverage gate applies), no Python leg exists
  (`enforcement-hooks-no-python-invocation.Tests.ps1` green), and no new third-party dependency is
  introduced. Demonstrated by: `Invoke-PoshQCTest` coverage output and the dependency-manifest
  diff. (spec AC-22..AC-25)

## Non-Goals

Recorded with reasons per Decision D7 in `spec.md` (see its `## Out of Scope` for the full list):

- Porting `mermaidChart.*` VS Code command IDs or `@mermaid-chart` Copilot Chat participants —
  they require the VS Code command API, extension host, and Copilot Chat, none reachable from a
  Claude Code session; the capabilities behind them are ported by substitution instead.
- Mermaid Chart cloud login/sync/review flows — interactive OAuth and extension UI; they remain
  human actions in VS Code. Only the `id:`-frontmatter hand-edit guard is ported.
- Deep `mmdc`/Chromium validation in CI — unfit for a per-Write/Edit hook; recorded as an optional
  follow-up consuming the validator's structured-result seam.
- Retrofitting the codex-native-converter emitters through the new validator, including the
  `mermaid_label`/`mermaidLabel` `\"`-versus-`#quot;` escaping defect — the issue's
  scope-containment constraint; recorded as a follow-up.
- Anything for `render_subagent_tree` — research verified it emits plain text, not Mermaid.
- Proving full Mermaid validity — the structural gate rejects the named defect classes only;
  semantic and deep-grammar errors are outside its contract.
