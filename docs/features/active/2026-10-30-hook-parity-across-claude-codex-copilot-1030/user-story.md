# `hook-parity-across-claude-codex-copilot` — User Story

- Issue: #1030
- Parent: epic #1018, child 5
- Owner: drmoisan
- Status: Draft
- Last Updated: 2026-10-30
- Spec: `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/spec.md`

## Story Statement

- As the repository owner, I want every hook registration in Claude Code, Codex and GitHub Copilot
  recorded in the parity matrix with the function it implements, so that a gate missing from one
  ecosystem is detected by a test instead of by an incident.
- As the repository owner, I want every function that exists in one ecosystem but not another to
  carry a written reason and a decision reference, so that I can review and override each gap
  deliberately.
- As the repository owner, I want ported Codex hooks to share byte-identical rule files with their
  Claude originals and to be proven equivalent on shared fixtures, so that the two implementations
  cannot drift silently.
- As the repository owner, I want the Python-invocation guard to cover every PowerShell file a
  registered hook executes, so that the rule "enforcement hooks do not invoke Python" holds for
  Copilot hooks and Codex helper scripts as well.
- As a Codex user in a destination repository, I want plan writes blocked until the feature
  folder's prerequisite documents exist, and planner, executor, researcher, prd-feature, pr-author
  and required-artifact outputs validated when those agents stop, so that Codex enforces the same
  workflow contracts as Claude Code.
- As a Claude Code user in a destination repository, I want hook behavior to stay unchanged by this
  work, so that existing workflows and gate decisions are not disturbed.
- As a GitHub Copilot user in a destination repository, I want the Copilot discovery hooks to be
  recorded in the same parity groups as their Claude and Codex counterparts, so that the thin
  Copilot layer (child 6) keeps the same discovery gates.

## Problem / Why

This repository runs enforcement and validation hooks in three agent ecosystems: Claude Code
(`.claude/hooks`), Codex (`.codex/hooks`) and GitHub Copilot (`.github/hooks`). The sets were built
separately and drifted: some Claude gates have no Codex counterpart, some Codex hooks exist only to
express Codex-specific attestation, and the Copilot hooks cover only the discovery surface. No
record states, for each hook registration, which function it implements and why a counterpart is
or is not present elsewhere, so a missing gate in one ecosystem is not detectable.

Epic #1018 settles the design: hook parity is parity of function, tracked in the parity matrix
owned by child 1 (#1025, `config/harness-parity-matrix.json`). Hook counts need not match, and
Codex gains a hook only where its hook system can express the behavior. Under child 1's semantics
(O1), each registration is `native` (or `generated`), and a shared function is a `parity_group`
with members in two or more ecosystems.

## Personas & Scenarios

- Persona: Repository owner (maintainer of the agent harness)
  - Maintains the Claude, Codex and Copilot customizations and the extension that pushes them down.
  - Cares about enforcement gates behaving the same way regardless of which agent runs the work.
  - Constraint: upstream children 1 and 3 and the parallel run `bugs-1001-1002-1003-1006` must
    merge first; the plan carries a Phase 0 gate and accepts one revision.
  - Frustration: discovering a missing Codex gate only after a Codex session wrote a plan without
    a spec, or stopped without advertising its artifact path.
- Persona: Codex user in a destination repository
  - Runs Codex agents against a repository that received the pushed-down `.codex/` layer.
  - Cares that the same workflow contracts apply as in Claude Code.
  - Constraint: Codex has no per-agent hook declaration and no caller identity in PreToolUse input,
    so some Claude gates cannot be expressed.
- Persona: Claude Code user in a destination repository
  - Relies on the existing `.claude/hooks` gates; expects no behavior change.
- Persona: GitHub Copilot user in a destination repository
  - Uses the discovery hooks in `.github/hooks`; their disposition and changes belong to child 6.

- Scenario: Owner reviews a parity gap
  - The owner opens `config/harness-parity-matrix.json` and filters `hook-registration` entries by
    `parity_group`.
  - For `hook:mermaid-validation`, the owner sees a Claude member, no Codex member, and the reason
    "requires library publication; deferred to child 4" with a `decision_ref`.
  - The owner either accepts the default or records an override; the repository gate
    `tests/scripts/harness/hook-parity-gate.Tests.ps1` fails if any such gap lacks a reason.
- Scenario: Codex planner stops without a plan path
  - A Codex `atomic-planner` subagent stops without a `plan-path:` line.
  - The Codex SubagentStop adapter dispatches on `agent_type`, runs the byte-identical planner
    validator, and returns a continuation decision with the reason.
  - The planner adds the missing advertisement and stops again; with `stop_hook_active` set, the
    adapter does not loop.
- Scenario: Codex writes a plan too early
  - A Codex session applies a patch that creates a plan file in a full-feature folder that has no
    `spec.md`.
  - The Codex feature-folder-order entry denies the write with the same decision the Claude hook
    returns for the same input.
- Scenario: Rule drift attempt
  - A contributor edits `.claude/hooks/validate-planner-output.ps1` without updating the Codex twin.
  - `tests/scripts/codex-hooks/hook-parity-twins.Tests.ps1` fails on the hash mismatch.

## Acceptance Criteria

- [ ] Phase 0 evidence records that the parallel run `bugs-1001-1002-1003-1006` and children 1 and 3 have merged, and confirms the matrix schema, `id` encoding, O8 hook-table ownership and the Codex agent-body contracts, or records the stop and plan revision.
- [ ] Every `hook-registration` entry enumerated by child 1's inventory module at execution time has a `parity_group`, and child 1's matrix completeness test passes.
- [ ] `tests/scripts/harness/hook-parity-gate.Tests.ps1` passes: dispositions follow child 1's semantics, every one-sided parity group carries a `reason`, `decision_status` and `decision_ref`, and Copilot entries keep child 1's default disposition and `owner_child` 6.
- [ ] Codex enforces feature-folder order: `tests/scripts/codex-hooks/enforce-feature-folder-order.Tests.ps1` and `tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1` pass.
- [ ] Codex validates planner, executor, task-researcher, prd-feature, pr-author and required-artifact outputs at SubagentStop for each agent type whose contract Phase 0 confirmed: `tests/scripts/codex-hooks/validate-codex-agent-output.Tests.ps1` passes.
- [ ] Ported rule files cannot drift: `tests/scripts/codex-hooks/hook-parity-twins.Tests.ps1` passes for every twin pair and every root-to-bundle pair.
- [ ] Ported Codex hooks behave like their Claude originals: `tests/scripts/codex-hooks/hook-parity-equivalence.Tests.ps1` passes.
- [ ] The Codex preimplementation delegation leg is registered only with recorded O2 runbook evidence; otherwise the matrix records the pending reason.
- [ ] Claude hook behavior is unchanged: existing `tests/scripts/claude-hooks/` suites pass, and the branch modifies nothing under `.claude/settings.json`, `.claude/agents/`, `.codex/agents/`, `.github/hooks/` or `extensions/drm-copilot/src/lib/push-down/`.
- [ ] No enforcement hook invokes Python: `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes with `.github/hooks` and `.codex/scripts` in scope, and the branch adds no `.py` file.
- [ ] Bundled mirrors and their parity tests are green: `legacy-codex-hook-contracts.Tests.ps1`, `codex-pretooluse-integration.Tests.ps1`, `hook-dependency-guard-completeness.Tests.ps1` and the push-down resource, pack-manifest completeness and dependency-closure tests pass.
- [ ] Each new PowerShell production file meets the line-coverage threshold governed by the root `CLAUDE.md`, and seeded shuffled runs show no test-order dependence.
- [ ] The Linux hook-suite job and the Windows PowerShell QC shards conclude `success` on the pull-request head (CI-dependent; checked off at S9).

## Non-Goals

- Edits to `.claude/settings.json`, `.claude/agents/*.md` or `.codex/agents/*.toml` (child 3 owns
  agent generation; frontmatter duplicates stay per O3).
- Edits to `.github/hooks/**` or Copilot dispositions (child 6).
- Push-down TypeScript changes, including any library-publication route for lib-dependent gates
  (child 4, O4).
- Edits to any path in the parallel run's blast radius before that run merges.
- Claude counterparts for the Codex-only epic hooks (O6).
- Changes to the matrix schema, `id` encoding or completeness test (child 1).
- New Python of any kind.
