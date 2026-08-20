# 2026-08-19-mermaid-diagram-claude-runtime — Spec

- **Issue:** #491
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-08-19
- **Status:** Ready for planning
- **Version:** 1.0

## Overview

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
Mermaid can reach committed artifacts. Research verified those two emitters produce valid
flowchart Mermaid today, but that their label helpers (`mermaid_label` / `mermaidLabel`)
JSON-escape `"` as `\"`, which Mermaid does not accept — the Mermaid escape is `#quot;`. That is a
latent defect recorded for the follow-up retrofit, not fixed here. Research also corrected an
initial assumption: the `render_subagent_tree` MCP tool emits plain text, not Mermaid
(`extensions/drm-copilot/src/lib/subagent-tree/tree-formatter.ts`), so it is not a Mermaid emitter
and is out of scope.

Authoritative research inputs:

- `research/mermaid-validation-technology.2026-08-19T08-39.md` — validator technology decision,
  Mermaid 11.17.0 grammar reference table, false-positive analysis, fail-open policy.
- `research/claude-runtime-integration-mechanics.2026-08-19T08-39.md` — hook input/block
  protocol, rule/skill contracts, distribution and coverage mechanics, test-purity constraints.

## Behavior

Deliver the same capability set on Claude's four runtime surfaces. This is a capability port, not a
textual translation: the VS Code-hosted mechanisms are replaced by mechanisms the Claude runtime
actually has, and the prose-only rules are replaced by a deterministic gate wherever the Copilot
file states a hard rule.

Capability mapping (every row must be ported or recorded out of scope with a reason — see
`## Out of Scope`):

| Copilot mechanism | Claude-native equivalent |
|---|---|
| `mermaid-diagram-validator` LM tool | Deterministic in-repo structural validator module invoked by a `PreToolUse` hook, so validation is not optional |
| "never return unvalidated Mermaid" rule | Hook-enforced block on writing an invalid diagram, not a prose instruction |
| `mermaid-diagram-preview` LM tool | Conditional Claude-native rendering paths (Artifact publish, `SendUserFile` with `display: render`) with a documented file-based fallback, documented in the skill (Decision D6) |
| `get-syntax-docs-mermaid` LM tool | Bundled per-diagram-type syntax reference under `.claude/skills/mermaid-diagram/references/`, pinned to Mermaid 11.17.0, plus a documented `WebFetch` fallback to mermaid.js.org |
| `mermaidChart.*` VS Code commands | Not portable; recorded as explicitly out of scope with the reason (see `## Out of Scope`) |
| `@mermaid-chart` slash commands | Skill-documented generation recipes for the same eight diagram intents |
| Mermaid Chart sync cooperation (`id:` frontmatter) | Rule-level do-not-hand-edit constraint keyed on the `id:` frontmatter marker, enforced by the same hook |

Surface allocation:

1. `.claude/rules/mermaid.md` — path-scoped declarative standards (diagram file conventions,
   validation mandate, managed-diagram constraint). Frontmatter scopes the rule to `**/*.mmd` and
   `**/*.mermaid` per research artifact 2 §3.3; the rule is deliberately not scoped to `**/*.md`
   because that would attach it to every Markdown file in a documentation-heavy repository. The
   Markdown-fence case is covered by the hook (content inspection) and the skill (procedure).
2. `.claude/skills/mermaid-diagram/SKILL.md` — the procedural generate-validate-render workflow,
   the eight diagram-intent recipes, the conditional rendering paths, the opt-out marker
   documentation, and the out-of-scope record. Per-type syntax detail lives in
   `.claude/skills/mermaid-diagram/references/*.md`.
3. `.claude/hooks/enforce-mermaid-validation.ps1` — the thin `PreToolUse` gate on `Write`/`Edit`,
   registered in the `Write|Edit` matcher block of `.claude/settings.json`.
4. `.claude/lib/mermaid/` — the validator logic as testable PowerShell module(s), keeping the hook
   thin and the logic unit-testable.

## Decisions

The following decisions are settled by the orchestrator on the recorded research evidence. They are
binding on planning and execution; do not re-open them.

### D1 — Validator implementation: dependency-free structural PowerShell

The validator is a dependency-free structural validator implemented as PowerShell module(s) under
`.claude/lib/mermaid/`, invoked by a thin `PreToolUse` hook at
`.claude/hooks/enforce-mermaid-validation.ps1`. No new npm or Python dependency is added.

Rationale (research artifact 1, §2 and Recommendation): no DOM-less Mermaid parse exists for the
diagram types this repository uses — `mermaid.parse()` has no supported Node/DOM-less mode and
`@mermaid-js/parser` covers only Langium-parsed types, not flowchart or sequence; a hook must run
even in a fresh worktree with no `node_modules`, which the parallel surface creates routinely; and
the defect classes the Copilot pack names (first-line keyword, arrow forms, bracket balance) are
fully covered structurally. The accepted cost is a validator weaker than a real parser: the gate's
contract is "rejects the named defect classes", never "proves validity", and the skill must state
that delta so "validated" is not overclaimed. The module's public entry returns a structured result
object (verdict, diagram type, findings with line numbers, warnings) so a future CI-side deep check
can be layered without changing the hook contract.

### D2 — Detection surface includes Markdown fenced blocks

The gate applies to `.mmd` and `.mermaid` files AND to fenced ```` ```mermaid ```` blocks inside
Markdown files. This deliberately widens research artifact 2's narrower recommendation of
`.mmd`/`.mermaid` files only.

Rationale: the repository currently contains zero `.mmd` files and every Mermaid diagram in it
lives in a fenced Markdown block, so a gate scoped to `.mmd` only would be a gate that can never
fire. A verification gate that cannot fail is a known failure pattern in this repository and must
be avoided. The Markdown surface is detected by the line-based fence tracker specified in research
artifact 1 §5 (3+ backtick/tilde fences, up to 3 spaces of indentation, blockquote prefixes, fence
stack for nesting, `mermaid` info-string first word, case-insensitive). D2 widens the hook's
detection surface only; the rule file's frontmatter scoping stays at `**/*.mmd` / `**/*.mermaid`
per research artifact 2 §3.3.

### D3 — Opt-out marker for intentional counter-examples

Documentation legitimately quotes invalid Mermaid to demonstrate a defect (this feature's own
research artifacts do exactly that). The gate honors an explicit, documented opt-out marker.

Exact marker syntax and scope:

- Marker line: `<!-- mermaid-validator: ignore -->` — an HTML comment whose text is exactly
  `mermaid-validator: ignore` (case-sensitive; leading/trailing whitespace on the line is
  permitted).
- Placement: the line immediately preceding the opening ```` ```mermaid ```` fence, with no
  intervening lines (blank or otherwise).
- Scope: suppresses syntactic validation for exactly that one fenced block. It has no effect on
  any later block, and each counter-example block requires its own marker.
- The marker applies only to fenced blocks in Markdown files. `.mmd`/`.mermaid` files have no
  opt-out: a diagram file is by definition a diagram, no such files exist today, and test
  counter-examples belong in Pester here-strings, not committed `.mmd` files. The marker never
  suppresses the managed-diagram (`id:` frontmatter) guard, which is keyed on `.mmd`/`.mermaid`
  file paths, not fences.
- The marker must be documented in both the rule and the skill.

Rationale: without an opt-out, the gate would block correct documentation that quotes invalid
Mermaid deliberately, which is worse than no gate. A fenced block nested inside an outer 4+-fence
remains covered separately by fail-open item 6 (D4) and needs no marker.

### D4 — Fail-open policy

The validator declines to judge rather than rejecting whenever it cannot classify the content
confidently, per the seven-item fail-open policy in research artifact 1 §4 and its
false-positive analysis. The seven items, all of which allow (optionally with a warning in the
decision reason):

1. First-line token not in the allowlist but shaped like a plausible keyword (letters, digits,
   hyphen): warn and allow. Only a missing or clearly non-keyword first line (for example a line
   starting with an arrow or bracket) blocks. This is the Mermaid version-drift safety valve: the
   keyword allowlist is pinned to Mermaid 11.17.0, and an out-of-date allowlist must cost a
   warning, never a false rejection.
2. Diagram types outside the deep-checked set (flowchart, sequence, class, state, ER, and the
   other arrow-bearing types in the research grammar table): first-line keyword check only.
3. Any single line the classifier cannot categorize: skip the line; never reject on
   "unclassifiable".
4. `Edit` tool calls where the fenced block or diagram is not fully reconstructable from the tool
   input: allow (the syntax check on Edit follows the checkpoint-monotonic precedent; the
   managed-diagram guard still applies to Edit via the on-disk reader).
5. Malformed or absent `CLAUDE_TOOL_INPUT`: allow. This deliberately differs from
   `enforce-evidence-locations.ps1`, which exits 1 on malformed JSON; the difference must be
   recorded in the hook's comment so a reviewer does not "fix" it into a hard failure.
6. Content inside a `mermaid` fence that is itself nested inside another open fence
   (documentation showing example Mermaid): not a diagram; allow.
7. ZenUML bodies (external-plugin grammar): keyword check only.

The false-positive constructs in research artifact 1 §4 (brackets in quoted labels, `#quot;` and
other HTML entities, Markdown strings, Unicode text, `%%` inside quoted spans, `subgraph` blocks,
statement-keyword lines such as `click`/`style`/`classDef`/`linkStyle`, `<br/>` and other angle
brackets, sequence message text after the first `:`, free-text diagram types, backslashes) must
each be accepted, and each is an explicit test case.

### D5 — Distribution is part of the deliverable, not a follow-up

Every new `.claude` file requires three coordinated artifacts: the repo file, the byte-identical
mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/`, and a
`pack-manifests/core.json` entry. `.claude/settings.json` is itself distributed, so the hook
registration edit lands in both the repo settings and the bundled mirror copy.

Research artifact 2 §5.3 found that skill `references/*.md` files are enumerated by NEITHER
completeness test suite (TypeScript or Python). They therefore need manual `core.json` entries or
they are silently dropped from pack-scoped push-downs — the issue #279 failure mode, unguarded for
this file class. This is a silent-failure path and is called out as its own acceptance criterion
(AC-20). Precedent for the manual listing:
`.claude/skills/human-exception-runbook/example.runbook.md` at `core.json:82`.

### D6 — Rendering is conditional

`Artifact` and `SendUserFile` are harness-dependent and may be absent from a given session (they
are absent from the research session's own tool set). The skill specifies the rendering path as
conditional with a documented fallback, never as an unconditional mandate:

1. If the session's tool set includes `Artifact`: publish a Markdown artifact containing the
   ```` ```mermaid ```` fence (preferred; no CSP or theme handling needed, unlike HTML artifacts).
2. Else if `SendUserFile` with `display: "render"` is available: use it.
3. Else: state that the diagram was written to `<path>` and name the VS Code preview route (the
   Mermaid Chart extension auto-previews `.mmd`/`.mermaid` files; built-in Markdown preview handles
   fenced blocks). GitHub also renders ```` ```mermaid ```` fences natively in Markdown, PRs, and
   issues.

The hook cannot perform any rendering step: hooks are non-interactive `pwsh` subprocesses whose
stdout is consumed by the hook protocol. Rendering is exclusively a skill-workflow step; the hook
enforces only the validation invariant.

### D7 — Out of scope, recorded with reasons

See `## Out of Scope`. The `mermaidChart.*` VS Code command IDs and the `@mermaid-chart` Copilot
Chat participants are not portable to the Claude runtime; deep `mmdc`/Chromium validation in CI is
a follow-up; retrofitting the codex-native-converter emitters through the new validator (including
the `mermaid_label`/`mermaidLabel` `\"`-versus-`#quot;` escaping defect) is a follow-up. Each
appears in the out-of-scope section with its reason so a later reader does not read the omission
as an oversight.

## Inputs / Outputs

- **Hook input:** `$env:CLAUDE_TOOL_INPUT` containing the tool parameter object as JSON.
  `Write`: `{"file_path": "<path>", "content": "<full file text>"}`. `Edit`:
  `{"file_path": "<path>", "old_string": "<fragment>", "new_string": "<fragment>"}` (plus
  `replace_all` when supplied). No stdin input. `SubagentStop`'s `$env:CLAUDE_HOOK_INPUT` is a
  different variable and is not used.
- **On-disk input (Edit managed-diagram check only):** the target file's current content, read
  through a named, mockable wrapper function (the wrapper-seam pattern of
  `.claude/rules/powershell.md`), so Pester can `Mock` it.
- **Hook output:** compact JSON on stdout with exit code 0 in every case. Deny shape:
  `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"<TOKEN>: <specific defect, line number, corrective pointer>"}}`.
  Allow shape: same envelope with `"permissionDecision":"allow"` (explicit-allow form, the
  recommended newer-hook convention). Never a nonzero exit to signal a block; never
  `{"decision":"block"}`.
- **Reason tokens:** `MERMAID_VALIDATION_BLOCKED:` for syntactic denials;
  `MERMAID_MANAGED_DIAGRAM_BLOCKED:` for the managed-diagram (`id:` frontmatter) guard, whose
  message points at the Mermaid Chart sync workflow.
- **Config keys:** none. The diagram-type keyword allowlist and per-type arrow token sets are data
  structures inside the module, pinned to Mermaid 11.17.0, with the docs version and source URL
  recorded in the module header so staleness is auditable.
- **Side effects:** none. The hook is a read-only gate ("This script must not modify any state")
  and writes no files, logs, or telemetry.
- **Backward compatibility:** purely additive. No existing hook, rule, skill, validator, or
  emitter behavior changes. Non-Mermaid writes pay only the JSON parse and extension/content scope
  check (early-exit ordering: scope check before any content scan).

## API / CLI Surface

There is no CLI. The surfaces are the hook protocol (above) and the module's public functions.

- Validator module public entry (name indicative, final naming at planning):
  `Test-MermaidDiagram -Content <string>` returning a structured result object:
  `Verdict` (`Valid` | `Invalid` | `NotJudged`), `DiagramType` (declared keyword or `$null`),
  `Findings` (array of `{ Class; Line; Message }` for defects), `Warnings` (array of strings, for
  example the unknown-keyword drift warning). The structured shape is the seam a future CI-side
  deep check consumes (D1).
- Hook pure decision function: `Invoke-MermaidValidationDecision -ToolInputRaw <string>` returning
  the decision object (or `$null` for silent allow), separated from the thin entrypoint by the
  dot-sourcing guard (`if ($MyInvocation.InvocationName -eq '.') { return }`) so Pester exercises
  the logic directly.
- Module resolution from the hook: `$PSScriptRoot`-relative
  (`Join-Path $PSScriptRoot '../lib/mermaid/MermaidValidation.psm1'`), with a missing-module guard
  that fails open (a consumer repo receiving the hook without the module must not be bricked).
- Contract validation rules: the deny reason must name the specific defect class, the line number,
  and a corrective pointer (`.claude/skills/mermaid-diagram/SKILL.md`), per the copyable contract
  in research artifact 2.

## Data & State

- No persistent data or state is introduced. The validator is a stateless, pure string pass per
  invocation.
- Data transformations: tool-input JSON → scope classification (`.mmd`/`.mermaid` path, Markdown
  with fenced ```` ```mermaid ```` blocks, or out of scope) → per-diagram structural analysis
  (frontmatter/directive/comment skipping, first-line keyword, quote-aware bracket balance,
  per-type arrow checks, `subgraph`/`end` pairing) → structured result → allow/deny JSON.
- Invariants: quote-aware scanning excludes quoted spans from balance counting; `\"` is never
  treated as an escape (Mermaid has none; `#quot;` is the mechanism); angle brackets are never
  structural; CRLF and LF inputs produce identical verdicts.
- No caching, no migration, no backfill. Zero `.mmd`/`.mermaid` files exist today, so there is no
  migration burden for the managed-diagram guard or the rule scoping.

## Constraints & Risks

- **Dependency policy — resolved by D1.** No new dependency is introduced. The rejected
  alternatives (npm `mermaid` at 83.9 MB/24 dependencies with no DOM-less parse path,
  `@mermaid-js/parser` covering none of the principal types, Chromium-backed `mmdc`) are recorded
  in research artifact 1 §2 with the disqualifying evidence.
- **Pack-manifest parity is a hard gate.**
  `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` fails when
  a `.claude` file is absent from a pack manifest;
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` fails on any repo `.claude`
  file missing from the bundle or differing by one byte. Three artifacts must move together: the
  repo file, the mirrored resources copy, and the `core.json` entry. Skill `references/*.md` files
  are the unguarded class (D5) and are the highest silent-failure risk in this feature.
- **Hook implementation language.** All 34 existing hooks are PowerShell. A Python leg is
  prohibited for enforcement hooks and is dynamically blocked by
  `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, which scans
  `.claude/hooks` and `.claude/lib` (excluding `lib/bash`). Bash hooks cannot be verified locally
  by any delegate.
- **False-positive blocking.** An over-strict hook that blocks a valid diagram is worse than no
  hook. Mitigations: the D4 fail-open policy, the D3 opt-out marker, the quote-aware scanner, the
  statement-keyword exemptions, and restricting deep checks to arrow-bearing diagram types. Every
  false-positive construct in research artifact 1 §4 is an explicit accept-path test.
- **Validator weaker than a real parse.** The structural validator cannot catch semantic or
  deep-grammar errors (research artifact 1 §2a "cannot catch" list). Mitigation: the gate's
  contract is stated as "rejects the named defect classes"; the structured-result seam leaves room
  for an optional CI-side `mmdc` deep check later (out of scope).
- **Version drift.** The keyword allowlist snapshots Mermaid 11.17.0; Mermaid adds diagram types
  several times per year. Mitigation: unknown-plausible-keyword warn-and-allow (D4 item 1), pinned
  version recorded in the module header, allowlist held in one data structure so an update is a
  one-line-per-keyword diff.
- **Hook self-interaction with test fixtures.** A PreToolUse hook fires on writes of its own test
  fixtures. Resolution: all diagram fixtures are PowerShell here-strings inside Pester files, never
  committed `.mmd` files, per the test-purity rules and research artifact 1 §5.
- **Scope containment.** The existing Mermaid emitters (codex-native-converter only;
  `render_subagent_tree` emits plain text and is not a Mermaid emitter) are not retrofitted by
  this change. The retrofit, including the `mermaid_label`/`mermaidLabel` escaping fix, is a
  recorded follow-up (D7).

## Implementation Strategy

- **Implementation scope (what changes, not sequencing):**
  - Create: `.claude/rules/mermaid.md`; `.claude/skills/mermaid-diagram/SKILL.md` plus
    `references/*.md`; `.claude/hooks/enforce-mermaid-validation.ps1`;
    `.claude/lib/mermaid/*.psm1` (expected split per research artifact 1: `MermaidValidation.psm1`
    for orchestration and the keyword/arrow tables, `MermaidLineScanner.psm1` for the
    quote/comment-aware scanner, `MermaidMarkdownFences.psm1` for the fence tracker — each under
    the 500-line limit); Pester suites at
    `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1` and
    `tests/scripts/claude-lib/mermaid/*.Tests.ps1`.
  - Modify: `.claude/settings.json` (append to the `Write|Edit` matcher block; add the
    conventional `Skill(mermaid-diagram *)` allow entry);
    `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` (new deny-shape `It` block and
    hook-count update); `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
    (`CodeCoverage.Path` entries with an issue-#491 comment);
    `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (one entry
    per new file, including every `references/*.md`); the bundled mirror copies of every created
    or modified `.claude` file including `settings.json`. `CLAUDE.md` indexing is optional (no
    test enforces it).
- **New functions:** module public entry `Test-MermaidDiagram` (structured result), managed-marker
  detector, fence tracker, line scanner; hook decision function
  `Invoke-MermaidValidationDecision` plus a named, mockable on-disk reader wrapper for the Edit
  managed-diagram check. Exact names are finalized at planning; the contracts above are binding.
- **Dependency changes:** none (D1). No `package.json`, `pyproject.toml`, or module-manifest
  dependency edits.
- **Logging/telemetry:** none. The hook communicates exclusively through the decision JSON;
  warnings (for example keyword drift) travel in the decision reason text.
- **Rollout:** single merge; the hook is active immediately on registration. No feature flag. The
  fail-open policy (D4) is the safety mechanism against disruption; the eleventh `Write|Edit` hook
  matches the existing per-hook `pwsh -NoProfile` startup budget, with the extension/content scope
  check ordered first so non-Mermaid writes pay only the JSON parse.

## Out of Scope

Each exclusion is recorded with its reason so a later reader does not treat the omission as an
oversight. The skill and/or rule text must carry the same record (AC-18).

1. **`mermaidChart.*` VS Code command IDs** (`preview`, `createMermaidFile`, `repairDiagram`,
   `improveDiagram`, `generateDiagramFromCode`, `generateCloudDiagram`, `generateERDiagram`,
   `generateDockerDiagram`, `openCopilotChat`, `login`, `logout`,
   `connectDiagramToMermaidChart`, `syncDiagramWithMermaid`, `reviewAppCommits`,
   `regenerateDiagramWithMermaidAI`, `installAiSkills`). Reason: they require the VS Code command
   API, an active editor, and the extension host — none reachable from a Claude Code session. The
   capabilities behind them are ported by substitution where portable (validation → hook,
   generation → skill recipes, preview → conditional rendering, sync cooperation → `id:` guard);
   the command IDs themselves are not.
2. **`@mermaid-chart` Copilot Chat participants** (the eight slash commands). Reason: Copilot Chat
   participants do not exist on the Claude surface. The eight generation intents are ported as
   skill recipe sections; the participant mechanism is not portable.
3. **Mermaid Chart cloud login/sync/review flows.** Reason: interactive OAuth and extension UI;
   these remain human actions in VS Code (research artifact 1 Automation Feasibility classifies
   them as `exception` with a human runbook). The Claude surface ports only the automatable half:
   the hook recognizes the `id:` frontmatter result of connecting a diagram and blocks hand-edits.
4. **Deep `mmdc`/Chromium validation in CI.** Reason: Chromium-backed, seconds-level latency, no
   validate-only mode — categorically unfit for a per-Write/Edit hook, and viable only as a
   CI-side check. Recorded as an optional follow-up consuming the structured-result seam.
5. **Retrofitting the codex-native-converter Mermaid emitters through the new validator**,
   including fixing the `mermaid_label`/`mermaidLabel` `\"`-versus-`#quot;` escaping defect in
   `scripts/dev_tools/codex_native_converter/_reporting_topology.py` and
   `extensions/drm-copilot/src/lib/codex-native-converter/reporting-topology.ts`. Reason: the
   issue's scope-containment constraint; the emitters produce valid flowchart Mermaid for their
   actual inputs today and the escaping defect is latent (manifests only for labels containing
   `"`). Recorded as a follow-up.
6. **`render_subagent_tree` MCP tool.** Reason: research verified it emits plain indented text,
   not Mermaid (`extensions/drm-copilot/src/lib/subagent-tree/tree-formatter.ts`); it is not a
   Mermaid emitter and there is nothing to gate or retrofit.
7. **Edit-path syntax reconstruction.** Reason: reconstructing post-edit file state inside the
   hook has no repo precedent and adds I/O failure modes to a per-call gate; the syntax check on
   `Edit` fails open (D4 item 4) and the next `Write` catches a regression, per the
   checkpoint-monotonic precedent. Recorded as a possible follow-up. The managed-diagram guard
   does apply to `Edit` via the on-disk reader.
8. **Codex (`.agents`) port of the Mermaid gate.** Reason: no test asserts a `.claude` → Codex
   counterpart; recorded as follow-up scope, mirroring how `.codex/hooks/` ports exist for the
   purity/budget/evidence hooks.
9. **A `quality-tiers.yml` entry.** Reason: research artifact 2 §6.4 confirmed the file does not
   exist at repo root and no `tier-classification` CI stage exists; the operative mechanism for
   PowerShell is coverage-path registration plus the QA-gate/feature-review process. Do not create
   the file for this feature.

## Acceptance Criteria

Each criterion names the artifact or command that demonstrates it. Verification commands:
`Invoke-PoshQCTest` (or MCP `mcp__drm-copilot__run_poshqc_test`) for Pester;
`poetry run pytest` for the Python suites; the extension Jest run for the TypeScript suite.

### Surfaces

- [x] AC-1: `.claude/rules/mermaid.md` exists with frontmatter `paths` scoped to `**/*.mmd` and
  `**/*.mermaid`, and its body states the diagram file conventions, the validation mandate, the
  managed-diagram (`id:` frontmatter) do-not-hand-edit constraint, and the D3 opt-out marker.
  Demonstrated by: the file content.
- [x] AC-2: `.claude/skills/mermaid-diagram/SKILL.md` exists (body under 500 lines) with valid
  `name`/`description` frontmatter, the generate-validate-render workflow, eight generation recipe
  sections matching the eight `@mermaid-chart` slash-command intents, the D6 conditional rendering
  paths with the file-based fallback and VS Code preview route named, the D3 opt-out marker
  documentation, a statement that the structural gate rejects named defect classes rather than
  proving validity, and per-diagram-type syntax references at
  `.claude/skills/mermaid-diagram/references/*.md` pinned to Mermaid 11.17.0 with a documented
  `WebFetch` fallback. Demonstrated by: the file contents.
- [x] AC-3: `.claude/hooks/enforce-mermaid-validation.ps1` exists (under 500 lines), is registered
  in the `Write|Edit` matcher block of `.claude/settings.json` as
  `pwsh -NoProfile -File .claude/hooks/enforce-mermaid-validation.ps1`, resolves the library via
  `$PSScriptRoot` with a fail-open missing-module guard, and carries the read-only-gate header and
  dot-sourcing guard. Demonstrated by: the file content and the `settings.json` diff.
- [x] AC-4: `.claude/lib/mermaid/` contains the validator module(s), each under 500 lines, whose
  public entry returns the structured result object (verdict, diagram type, findings with line
  numbers, warnings), with the Mermaid 11.17.0 pin and source URL recorded in the module header.
  Demonstrated by: the file contents.

### Validator defect detection and false-positive safety

- [x] AC-5: The validator rejects a missing or clearly non-keyword first line and a misspelled
  first-line diagram keyword, naming the defect. Demonstrated by: Pester cases in
  `tests/scripts/claude-lib/mermaid/*.Tests.ps1`.
- [x] AC-6: The validator rejects unbalanced `[]`, `()`, `{}` and unterminated double-quoted
  strings on structural lines of bracket-structural diagram types, using quote-aware scanning.
  Demonstrated by: Pester cases per bracket class in `tests/scripts/claude-lib/mermaid/*.Tests.ps1`.
- [x] AC-7: The validator rejects arrow tokens invalid for the declared diagram type on
  edge-classified lines for the deep-checked types (at minimum flowchart, sequence, class, state,
  ER). Demonstrated by: per-type Pester cases in `tests/scripts/claude-lib/mermaid/*.Tests.ps1`.
- [x] AC-8: Every false-positive construct enumerated in research artifact 1 §4 is accepted:
  brackets inside quoted labels, `#quot;`/`#35;`/`&amp;` entities (with `\"` never treated as an
  escape), Markdown strings in backticks, Unicode text, `%%` inside quoted spans, `subgraph`/`end`
  blocks with `direction` statements, statement-keyword lines
  (`click`/`style`/`classDef`/`linkStyle`/`class`/`accTitle`/`accDescr`/`title`), `<br/>` and
  angle brackets, sequence message text after the first `:`, free-text diagram-type bodies, and
  backslashes as ordinary characters. Demonstrated by: one Pester accept-case per construct in
  `tests/scripts/claude-lib/mermaid/*.Tests.ps1`.
- [x] AC-9: Each of the seven D4 fail-open items is asserted to allow, including
  unknown-plausible-keyword warn-and-allow (version-drift safety) and keyword-only checking for
  non-deep and ZenUML types. Demonstrated by: one Pester case per item across the lib and hook
  suites.
- [x] AC-10: Verdicts are byte-equivalent for CRLF and LF inputs; empty and whitespace-only
  diagram bodies are rejected; frontmatter-bearing diagrams (`title`, `config`, `id`) are
  validated past the frontmatter. Demonstrated by: Pester cases in
  `tests/scripts/claude-lib/mermaid/*.Tests.ps1`.

### Hook behavior

- [x] AC-11: The hook denies a `Write` of an invalid `.mmd`/`.mermaid` file with a
  `MERMAID_VALIDATION_BLOCKED:` reason naming the specific defect, the line number, and the
  corrective pointer, and allows a `Write` of a valid one. Demonstrated by: Pester cases in
  `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1`.
- [x] AC-12: The hook validates fenced ```` ```mermaid ```` blocks inside a Markdown `Write` (D2):
  an invalid fence is denied, a valid fence is allowed, non-Mermaid Markdown and non-Mermaid file
  paths are allowed untouched, and a `mermaid` fence nested inside an outer fence is allowed
  (fail-open item 6). Demonstrated by: Pester cases in
  `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1`.
- [x] AC-13: The hook honors the D3 opt-out marker: a fenced block immediately preceded by
  `<!-- mermaid-validator: ignore -->` is allowed even when its content is invalid, and the marker
  suppresses only that one block (a second unmarked invalid block in the same write is still
  denied). Demonstrated by: Pester cases in
  `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1`.
- [x] AC-14: The hook denies a hand-edit (`Edit` and `Write`) of a Mermaid Chart-managed diagram —
  a `.mmd`/`.mermaid` file whose on-disk frontmatter carries `id:` — with a
  `MERMAID_MANAGED_DIAGRAM_BLOCKED:` reason pointing at the sync workflow, using a named mockable
  on-disk reader seam. Demonstrated by: Pester cases mocking the reader in
  `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1`.
- [x] AC-15: The hook fails open (allows) on empty, absent, or unparseable `CLAUDE_TOOL_INPUT`,
  missing `file_path`, out-of-scope paths, and `Edit` payloads whose diagram content is not fully
  reconstructable, and its comment records why this deliberately differs from
  `enforce-evidence-locations.ps1`. Demonstrated by: Pester cases in
  `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1` and the hook source comment.
- [x] AC-16: The hook emits the correct block protocol: compact
  `hookSpecificOutput.permissionDecision = 'deny'` JSON on stdout with exit code 0 — never a
  nonzero exit and never `{"decision":"block"}` — and exit code 0 on allow. A new `It` block in
  `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1` asserts the round-tripped deny
  shape for this hook, and the suite's hook count is updated. Demonstrated by: entry-point Pester
  cases and the contract-suite diff.
- [x] AC-17: Negative control — a deliberately invalid fixture (here-string, not a committed
  file) is demonstrated to be rejected end-to-end through the hook decision path, proving the gate
  is capable of failing. Demonstrated by: a named negative-control Pester case in
  `tests/scripts/claude-hooks/enforce-mermaid-validation.Tests.ps1`.

### Capability completeness

- [x] AC-18: Every capability in the issue.md mapping table and every mechanism named in
  `.github/instructions/mermaid.instructions.md` is either ported by one of the four surfaces or
  listed in the skill/rule out-of-scope record with its stated reason, matching `## Out of Scope`
  above. No capability is silently dropped. Demonstrated by: a row-by-row cross-check of the
  mapping table against the delivered rule and skill text (feature-review evidence).

### Distribution

- [x] AC-19: Every created or modified `.claude` file (rule, SKILL.md, every `references/*.md`,
  hook, every `.psm1`, `settings.json`) has a byte-identical copy under
  `extensions/drm-copilot/resources/claude-customizations/.claude/`. Demonstrated by:
  `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` green.
- [x] AC-20: `pack-manifests/core.json` carries one entry per new file, explicitly including every
  `.claude/skills/mermaid-diagram/references/*.md` file (the class neither completeness suite
  enumerates — D5). Demonstrated by: the `core.json` diff listing each reference file, plus
  `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` and
  `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` green.
- [x] AC-21: The distribution suites are shown capable of failing for this change: the parity
  and/or completeness suites fail before the mirror/manifest edits and pass after (recorded as
  evidence), applying the negative-control requirement to distribution. Demonstrated by: the
  before/after run records in the feature evidence.

### Coverage and policy

- [x] AC-22: `.claude/hooks/enforce-mermaid-validation.ps1` and every `.claude/lib/mermaid/*.psm1`
  are appended to `CodeCoverage.Path` in
  `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` with an issue-#491 comment, and the
  new files reach >= 85% line coverage in `artifacts/pester/powershell-coverage.xml`. No
  branch-coverage gate applies (Pester does not measure branch coverage). Demonstrated by: the
  runsettings diff and the coverage XML from `Invoke-PoshQCTest`.
- [x] AC-23: No Python invocation exists in the new hook or library. Demonstrated by:
  `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` green.
- [x] AC-24: No new third-party dependency is introduced (no `package.json`, `pyproject.toml`, or
  module-manifest dependency change). Demonstrated by: the diff of dependency manifests (empty).
- [x] AC-25: All Pester tests satisfy the purity rules: diagram fixtures as here-strings, on-disk
  reads through mocked wrapper seams, no temp files, no `Start-Process`, no sleeps. Demonstrated
  by: the `check-powershell-test-purity` gate not firing on the new test files and the test
  sources themselves.

## Definition of Done

- [x] Acceptance criteria AC-1 through AC-25 checked off with evidence per criterion
- [x] Behavior matches acceptance criteria in all documented environments
- [x] Tests updated/added (validator lib suite, hook suite, contract-suite `It` block, distribution suites)
- [x] Edge cases and error handling covered by tests (fail-open matrix, false-positive matrix, CRLF/LF, frontmatter)
- [x] Docs updated (rule, skill, references; out-of-scope record present in skill/rule text)
- [x] Telemetry/logging: n/a (read-only gate; decision JSON only)
- [x] Toolchain pass completed (format → lint → type-check where applicable → test) in a single pass

## Seeded Test Conditions (from potential)

- [x] Validator unit coverage: valid diagram per supported type; missing/misspelled first-line
  keyword; unbalanced `[]`, `()`, `{}`, `""`; arrow form invalid for the declared type; empty and
  whitespace-only input; CRLF and LF line endings; frontmatter-bearing diagram.
- [x] Hook unit coverage: `.mmd` write blocked on invalid content; `.mmd` write allowed on valid
  content; fenced ```` ```mermaid ```` block inside a Markdown write; non-Mermaid write untouched;
  managed-diagram (`id:` frontmatter) hand-edit blocked; malformed hook input fails open.
- [x] Parity: pack-manifest completeness test green; mirrored resources copy byte-identical.
- [x] Negative control: a deliberately invalid fixture is proven to be rejected, so the gate is
  shown capable of failing.
