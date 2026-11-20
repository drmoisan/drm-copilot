# retire-github-skills-and-thin-copilot-layer (Issue #1032)

- Date captured: 2026-10-30
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/retire-github-skills-and-thin-copilot-layer/ (Issue #1032)
- Parent epic: #1018 (shared agent-harness layer across Claude Code, Codex and GitHub Copilot), child 6
- Epic manifest: `docs/features/epics/shared-agent-harness-layer/epic.md` on `epic/shared-agent-harness-layer-integration`

- Issue: #1032
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/1032
- Last Updated: 2026-10-30
## Problem / Why

Epic #1018 moves the three agent ecosystems in this repository onto shared cross-tool conventions so that each tool loads every skill and instruction exactly once with default settings. GitHub Copilot in VS Code reads `.github/skills`, `.claude/skills` and `.agents/skills`, so the `.github/skills` folder (a strict subset of the other two skill folders) causes duplicate loading. `.github/agents` duplicates agent definitions that Copilot in VS Code also reads from `.claude/agents`. Collision controls currently live only in the owner's personal user settings; other users do not have them.

## Proposed Behavior

- Retire `.github/skills` after its three unique sections, in `feature-promotion-lifecycle` and `feature-review-workflow`, are ported to the shared skill source or recorded as stale.
- Retire `.github/agents`, or reduce it to a generated file, according to the result of child 1's experiment on whether the Copilot CLI and Copilot cloud agent read Claude-format `.claude/agents`.
- Keep a thin Copilot layer: prompts, handoffs and hooks stay native in `.github`; `.github/copilot-instructions.md` holds Copilot-only text.
- Deliver Copilot collision controls in workspace `.vscode/settings.json` if workspace scope works (child 1 experiment E4); otherwise document them. `.vscode/settings.json` is gitignored, so the delivery approach is an owner question with a default.
- Update the push-down packs and bundled extension mirrors for every removed file.

## Acceptance Criteria (early draft)

- [ ] `.github/skills` is retired with no loss of unique content; each of its three unique sections is ported or recorded as stale with a reason.
- [ ] `.github/agents` is retired or reduced to a generated file, according to child 1's recorded E3 result.
- [ ] The thin Copilot layer keeps prompts, handoffs and hooks native in `.github`, and `.github/copilot-instructions.md` holds only Copilot-only text.
- [ ] Copilot collision controls are delivered at workspace scope when E4 shows it works, otherwise documented.
- [ ] Push-down pack manifests and bundled mirrors contain no entry for a removed file, and the push-down contract tests pass.

## Constraints & Risks

- Depends on children 4 (push-down consolidation and packs) and 5 (hook parity) and on child 1's experiment results; planned before they exist (owner decision E3), so the plan carries a Phase 0 gate that re-checks them.
- Execution starts only after the parallel run `bugs-1001-1002-1003-1006` merges; that run edits `.github/skills/execution-environment/SKILL.md`.
- Language rule: anything pushed down is PowerShell or bash; TypeScript only for MCP tools and extension commands; no new Python.

## Test Conditions to Consider

- [x] Unit coverage areas: pack-manifest completeness and dependency closure after removals; bundle parity.
- [x] Integration scenarios: Copilot loads each skill once with the workspace settings (owner-run).
- [ ] CLI/API examples

## Next Step

- [ ] Promote to GitHub issue (feature request template)
- [ ] Create the active feature folder from the template
