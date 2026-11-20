# mermaid-diagram-claude-runtime (Issue #491)

- Date captured: 2026-08-19
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/mermaid-diagram-claude-runtime/ (Issue #491)

- Issue: #491
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/491
- Last Updated: 2026-08-19
- Work Mode: full-feature

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
`extensions/drm-copilot/src/lib/codex-native-converter/reporting-render.ts`), so unvalidated Mermaid
can reach committed artifacts. Research verified that those two emitters produce valid flowchart
Mermaid today, but that their label helpers (`mermaid_label` / `mermaidLabel` in
`scripts/dev_tools/codex_native_converter/_reporting_topology.py` and
`extensions/drm-copilot/src/lib/codex-native-converter/reporting-topology.ts`) JSON-escape `"` as
`\"`, which Mermaid does not accept — the Mermaid escape is `#quot;`. That is a latent defect
recorded for the follow-up retrofit, not fixed here. Research also corrected an initial assumption:
the `render_subagent_tree` MCP tool emits plain text, not Mermaid
(`extensions/drm-copilot/src/lib/subagent-tree/tree-formatter.ts`), so it is not a Mermaid emitter
and is out of scope.

## Proposed Behavior

Deliver the same capability set on Claude's four runtime surfaces. This is a capability port, not a
textual translation: the VS Code-hosted mechanisms are replaced by mechanisms the Claude runtime
actually has, and the prose-only rules are replaced by a deterministic gate wherever the Copilot
file states a hard rule.

Capability mapping:

| Copilot mechanism | Claude-native equivalent |
|---|---|
| `mermaid-diagram-validator` LM tool | Deterministic in-repo validator module invoked by a `PreToolUse` hook, so validation is not optional |
| "never return unvalidated Mermaid" rule | Hook-enforced block on writing an invalid diagram, not a prose instruction |
| `mermaid-diagram-preview` LM tool | Claude-native rendering paths (Artifact publish, `SendUserFile` with `display: render`), documented in the skill |
| `get-syntax-docs-mermaid` LM tool | Bundled per-diagram-type syntax reference under the skill directory, plus a documented `WebFetch` fallback |
| `mermaidChart.*` VS Code commands | Not portable; recorded as explicitly out of scope with the reason, so a later reader does not treat the omission as an oversight |
| `@mermaid-chart` slash commands | Skill-documented generation recipes for the same eight diagram intents |
| Mermaid Chart sync cooperation (`id:` frontmatter) | Rule-level do-not-hand-edit constraint keyed on the `id:` frontmatter marker, enforced by the same hook |

Surface allocation:

1. `.claude/rules/mermaid.md` — path-scoped declarative standards (diagram file conventions,
   validation mandate, managed-diagram constraint).
2. `.claude/skills/mermaid-diagram/SKILL.md` — the procedural generate-validate-render workflow and
   the diagram-type recipes.
3. `.claude/hooks/enforce-mermaid-validation.ps1` — the `PreToolUse` gate on `Write`/`Edit`.
4. `.claude/lib/mermaid/` — the validator logic as a testable PowerShell module, keeping the hook
   thin and the logic unit-testable.

## Acceptance Criteria (early draft)

- [ ] A Claude-native rule, skill, hook, and validator module exist and cover every capability in the
      mapping table above.
- [ ] The validator rejects the specific defect classes the Copilot workflow names: wrong or missing
      first-line diagram keyword, unbalanced brackets, and invalid arrow forms for the declared
      diagram type.
- [ ] The hook blocks a `Write`/`Edit` that would land an invalid diagram and reports the specific
      defect, and it blocks a hand-edit of a Mermaid Chart-managed diagram (frontmatter `id:`).
- [ ] Every capability the Copilot file provides is either ported or recorded as out of scope with a
      stated reason. No capability is silently dropped.
- [ ] New `.claude` files are mirrored into
      `extensions/drm-copilot/resources/claude-customizations/.claude/` and registered in
      `pack-manifests/core.json`, keeping the pack-manifest completeness test green.
- [ ] The validator module meets the repository coverage thresholds under Pester.
- [ ] No new third-party dependency is introduced, or the dependency is justified in writing per the
      dependency policy in `.claude/rules/general-code-change.md`.

## Constraints & Risks

- **Dependency policy.** A full Mermaid grammar parse would mean adding the `mermaid` npm package.
  It is not currently a dependency, it is DOM-dependent for the jison-parsed diagram types
  (flowchart, sequence), and `@mermaid-js/parser` covers only the newer Langium-parsed types. The
  research stage must decide between a dependency-free structural validator and a real parser, and
  record the decision. The risk of the structural route is a validator weaker than the extension's;
  the risk of the parser route is a heavy, DOM-fragile dependency.
- **Pack-manifest parity is a hard gate.** `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`
  fails when a `.claude` file is absent from a pack manifest. Three artifacts must move together:
  the repo `.claude` file, the mirrored resources copy, and the `core.json` entry.
- **Hook implementation language.** All 34 existing hooks are PowerShell. A Python leg is prohibited
  for enforcement hooks. Bash hooks cannot be verified locally by any delegate.
- **False-positive blocking.** An over-strict hook that blocks a valid diagram is worse than no
  hook. The gate must scope narrowly to `.mmd` / `.mermaid` files and fenced ```mermaid blocks, and
  must fail open on content it cannot classify.
- **Scope containment.** The existing Mermaid emitters (codex-native-converter only)
  are not retrofitted by this change. Whether they should route through the new validator is
  recorded as a follow-up, not delivered here.

## Test Conditions to Consider

- [ ] Validator unit coverage: valid diagram per supported type; missing/misspelled first-line
      keyword; unbalanced `[]`, `()`, `{}`, `""`; arrow form invalid for the declared type;
      empty and whitespace-only input; CRLF and LF line endings; frontmatter-bearing diagram.
- [ ] Hook unit coverage: `.mmd` write blocked on invalid content; `.mmd` write allowed on valid
      content; fenced ```mermaid block inside a Markdown write; non-Mermaid write untouched;
      managed-diagram (`id:` frontmatter) hand-edit blocked; malformed hook input fails open.
- [ ] Parity: pack-manifest completeness test green; mirrored resources copy byte-identical.
- [ ] Negative control: a deliberately invalid fixture is proven to be rejected, so the gate is
      shown capable of failing.

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create `docs/features/active/mermaid-diagram-claude-runtime/` folder from the template
