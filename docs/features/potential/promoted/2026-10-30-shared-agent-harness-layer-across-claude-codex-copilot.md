# shared-agent-harness-layer-across-claude-codex-copilot (Issue #1018)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/shared-agent-harness-layer-across-claude-codex-copilot/ (Issue #1018)

- Issue: #1018
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1018
- Last Updated: 2026-10-30
## Problem / Why

This repo runs three agent ecosystems: Claude Code, OpenAI Codex and GitHub Copilot. Each has its own native harness. Claude is the most advanced, Codex is next, and Copilot is the oldest and has fallen behind. To avoid collisions between them the owner relies on personal user settings, and other users do not have those settings. The repo's own documents disagree about which ecosystem is authoritative: `docs/engineering/claude-code-architecture.md` says `.github/` is canonical, `.agents/README.md` says `.agents/skills` is the canonical Codex surface, and `CLAUDE.md` says `.claude/` is standalone. No repo file records any collision control (no `.vscode/settings.json`; none of the Copilot settings that control which files it reads appear anywhere).

Facts from the inventory (2026-10-30):

- Claude: 25 agents, 66 skills, 19 rules, 75 hook files, `settings.json`, `CLAUDE.md`, `.mcp.json`.
- Codex: 130 agent TOML files (about 98 unique, with generated profile variants), 83 skill directories under `.agents/skills`, 50 hook files, `config.toml`, `AGENTS.md`.
- Copilot: 17 instruction files, 46 agents, 30 prompts, 34 skills, 6 hook files under `.github/`.
- Skills: 90 distinct names. 33 are in all three ecosystems, 22 are in Claude and Codex only, 11 are Claude-only, 24 are Codex-only, and none are Copilot-only (`.github/skills` is a strict subset). Of the 55 shared names, 12 are byte-identical, 27 differ in wording only, and 16 differ materially.
- Claude Code 2.1.314 does not discover skills in `.agents/skills` at project level (verified with a control skill in a scratch project on 2026-10-30). Codex reads `.agents/skills`. Copilot in VS Code reads `.github/skills`, `.claude/skills` and `.agents/skills`.
- Claude Code reads `AGENTS.md` only when no `CLAUDE.md` exists; a `CLAUDE.md` containing `@AGENTS.md` loads it without a double load. Codex and Copilot read `AGENTS.md` natively.
- Copilot in VS Code also reads Claude-format agents from `.claude/agents`.
- Codex has no shared MCP file; it uses TOML in `.codex/config.toml`.

Goal: migrate to the common cross-tool conventions so that each tool loads every skill and instruction exactly once with default settings, without losing the power of any native harness, and with each ecosystem expressing each skill at the same gold standard.

## Proposed Behavior

**Structure**

| Surface | Source of truth | Generated or native |
| --- | --- | --- |
| Instructions | `AGENTS.md` | `CLAUDE.md` is `@AGENTS.md` plus Claude-only text; `.github/copilot-instructions.md` is Copilot-only |
| Path-scoped rules | One source with globs | Generated into `.claude/rules` (`paths:`) and `.github/instructions` (`applyTo`) |
| Shared skills | `.agents/skills` (neutral body, superset frontmatter, `references/standard.md` contract, small per-tool files) | Mirrored into `.claude/skills` by a generator with `--check` |
| Tool-only skills | Their native folder | Not mirrored |
| MCP servers | One list | Generated into `.mcp.json` and the `[mcp_servers]` table of `.codex/config.toml` |
| Agents | One logical definition | Generated into `.claude/agents/*.md` and `.codex/agents/*.toml`; `.github/agents` retires if the Copilot CLI and cloud agent read Claude format |
| Hooks, permissions, subagent frontmatter | Native | Parity of function, tracked in the parity matrix |
| Copilot prompts, handoffs, hooks | Native in `.github` | Thin Copilot layer |
| Copilot collision controls | Workspace `.vscode/settings.json` | If workspace scope works, otherwise documented |

**Rules**

- **Parity matrix.** Every native feature gets a disposition: shared, native, generated, or dropped with a written reason. A test fails if a feature has none. Hook parity is parity of function; hook counts need not match, and Codex gains a hook only where its system can express the behavior.
- **Gold standard.** Each shared skill has a tool-neutral contract (objective, observable behaviors, acceptance checks). Differences between ecosystems are judged against the skill's objective: positive, negative, neutral or mechanism-only. Positives are ported in any direction. The owner approves in bulk and only disputed cases are escalated. Mechanism may differ per tool; the gold standard does not.
- **Retirements.** `.github/skills` retires once its three unique sections (in `feature-promotion-lifecycle` and `feature-review-workflow`) are ported or found stale. It is a strict subset of the other two folders.
- **Delivery.** Destinations choose packs per ecosystem and the shared layer is always installed. The three push-downs become one pipeline with the existing MCP tools kept as thin wrappers. Migration is non-destructive: a dry-run report first, and a destination's own edits are never overwritten (detected against the last pushed-down manifest).

## Decomposition (draft; `/epic-plan` finalizes)

1. Survey, gold-standard contracts and parity matrix, plus the Copilot and Codex experiments. First, and gates the restructuring.
2. Issue #1016 Phase 1: the resolver and configured development-docs root, behavior unchanged. May run alongside child 1.
3. Generators and the shared-source pipeline: skill mirror, rules, MCP and agent generators, all with `--check`.
4. Push-down consolidation and per-ecosystem pack selection.
5. Hook parity.
6. Retirements and the thin Copilot layer.
7. Issue #1016 Phases 2 and 3: migration command, the move to `.dev`, and the default flip. Last, after the other work has merged.

Sequencing: starts after the current nine-item parallel run (`bugs-1001-1002-1003-1006`) merges. This epic takes priority over #1016 as a standalone feature, and #1016 becomes children 2 and 7.

## Acceptance Criteria (early draft)

- [ ] With default settings, Claude Code, Codex and Copilot each load every skill and instruction exactly once in a repo with the new layout, with no duplicate or conflicting content.
- [ ] A parity matrix assigns every native feature of every ecosystem a disposition, and a test fails if one has none.
- [ ] Each shared skill has a tool-neutral gold-standard contract, and each ecosystem's implementation is checked against it.
- [ ] Every difference between ecosystems for a shared skill is classified and approved, and positives are ported in the direction that serves the skill's objective.
- [ ] Shared skills, path-scoped rules, MCP servers and agents are authored once and generated into each ecosystem's native files, each with a `--check` mode that reports drift.
- [ ] `.github/skills` is retired with no loss of unique content, and `.github/agents` is retired or reduced to a generated file, depending on the verification result.
- [ ] A destination chooses packs per ecosystem; an unused ecosystem installs no files.
- [ ] The migration to the new layout is non-destructive, reports a dry run first, and never overwrites a destination's own edits.
- [ ] No native capability of any ecosystem is dropped without a written reason approved by the owner.
- [ ] Enforcement hooks do not invoke Python.

## Constraints & Risks

- Scale: about 90 skills, 98 Codex agents, 25 Claude agents, 46 Copilot agents, 125 hook files, three push-downs and the mirrored extension bundles.
- Some behavior was not verified: Copilot duplicate-skill listing, Codex ignoring Claude-only frontmatter, whether the Copilot CLI and cloud agent read `.claude/agents`, whether the Copilot settings work at workspace scope, and details of the Claude hooks, subagent and permissions pages. The first child runs these experiments; those needing VS Code or Codex require owner-run steps.
- The skill heading comparison overstates real differences (the same topic under different headings). The survey needs a content read.
- Windows symlinks are unreliable, so mirrors are generated, not linked.
- Touches the same hooks, skills and push-down code as the in-flight parallel run, so the epic starts after that run merges.
- Several Copilot features are Preview or experimental (hooks, nested `AGENTS.md`, workspace-root `.mcp.json`).

## Test Conditions to Consider

- [x] Unit coverage areas: each generator with and without drift; the parity-matrix completeness test; pack selection; the migration dry run and the no-overwrite rule; contract presence per shared skill.
- [x] Integration scenarios: a scratch repo with the new layout loaded by Claude Code (and by Codex and Copilot via owner-run steps) showing each skill exactly once; a destination with the old layout migrated twice with the second run a no-op.
- [ ] CLI/API examples

## Next Step

- [x] Promote to GitHub issue (epic)
- [ ] Create the epic folder `docs/features/epics/<epic-slug>/` with `/epic-plan` after the current parallel run merges
