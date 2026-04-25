# `2026-04-11-claude-code-architecture` — User Story

- Issue: #136
- Owner: drmoisan
- Status: In Progress
- Last Updated: 2026-04-11T20-00

## Story Statement

- As a repository developer using Claude Code as my primary AI environment, I want a first-class Claude Code architecture (CLAUDE.md, .claude/rules/, .claude/skills/, .claude/agents/, settings.json, hooks) that maps the existing Copilot orchestration model onto Claude-native primitives, so that I can run the same deterministic orchestration workflows in Claude Code without losing routing behavior, specialist delegation, or enforcement gates.
- As a repository maintainer, I want a documented and implemented sync strategy for keeping .claude/ content aligned with the canonical .github/ sources, so that changes to skills and agents remain consistent across both AI runtimes and do not diverge silently.

## Problem / Why

The repository's orchestration model is built around Copilot-specific primitives: auto-attached instruction files, declarative agent handoffs, reusable skill contracts, and extension-backed MCP tool surfaces. Claude Code can support the same overall workflows, but it uses a distinct four-layer native architecture:

1. `CLAUDE.md` and `.claude/rules/` for persistent standing instructions (not a monolithic single file)
2. `.claude/skills/` for user-invocable or automatically loaded reusable workflows (first-class primitive — not `.claude/commands/`)
3. `.claude/agents/` for named specialist personas with their own tool allowlists, models, hooks, memory, and MCP server scoping (first-class primitive — not ad hoc file reads at delegation time)
4. `.claude/settings.json` and `.claude/hooks/` for permissioned-enforced behavior and deterministic stop gates

Without a documented and implemented Claude-native architecture that uses all four layers, the current orchestration assets are not portable outside the Copilot runtime. Specifically, the repository cannot leverage Claude Code's per-subagent tool restrictions, subagent-scoped hooks, preloaded skills, or project-level permission enforcement — all of which are required to replicate the deterministic routing, guarded handoffs, and completion-gate behavior the Copilot orchestration model provides.

A command-only or `CLAUDE.md`-only approach (the original draft design) intentionally discards supported Claude features and is not a correct Claude-native architecture.

## Personas & Scenarios

- **Persona: Repository Developer (drmoisan)**
  - who the user is: a solo developer who maintains drm-copilot and uses AI agents as development accelerators.
  - what they care about: being able to run the same workflow automation in Claude Code as in Copilot; deterministic routing to the right specialist agent; the orchestrator resuming from checkpoint after interruption.
  - their constraints: cannot maintain two divergent sets of workflow definitions; existing `.github/` files must remain the canonical source.
  - their goals and frustrations: wants to open Claude Code and invoke `/orchestrate <objective>` and have it work correctly end-to-end; frustrated when output is prompt-driven rather than deterministic.
  - their context and motivations: spends time in both Copilot and Claude Code sessions; needs configuration that is usable in either runtime without manual adaptation.

- **Persona: Repository Maintainer (drmoisan)**
  - who the user is: the same person in a maintenance role, reviewing sync status between `.claude/` and `.github/`.
  - what they care about: knowing whether `.claude/` files are stale relative to `.github/` canonical sources; having a clear process for applying updates.
  - their constraints: limited time; does not want to manually diff many files.
  - their goals and frustrations: wants a clear documented sync procedure he can run on demand; frustrated by configuration drift discovered only when a workflow fails.
  - their context and motivations: makes changes to `.github/instructions/`, `.github/agents/`, or `.github/skills/` and wants to know the downstream impact on `.claude/`.

- **Scenario: Running an orchestration workflow in Claude Code**
  - who is acting: the repository developer.
  - what triggered the action: developer opens Claude Code in the repo and needs to start a new feature workflow.
  - what steps they take: invokes `/orchestrate "add support for X"` → the `orchestrate` skill forks the orchestrator subagent → orchestrator reads the checkpoint file → detects no prior state for this objective → routes through the promotion, research, planning, execution, and review lifecycle → writes checkpoint after each phase → returns a completion summary with all required artifact paths.
  - what obstacles or decisions occur: the orchestrator must respect the phase-gating rules from the Copilot orchestration model; the `SubagentStop` hook must block early termination.
  - what outcome they expect: the workflow completes with all required artifacts present; the checkpoint reflects the completed state; no manual prompt engineering was required.

- **Scenario: Generating a commit message in Claude Code**
  - who is acting: the repository developer.
  - what triggered the action: developer has staged changes and wants a conventional commit message.
  - what steps they take: invokes `/commit-message` → the skill reads the staged git diff and the commit-message conventions from `.github/agents/` or `.github/skills/` → produces a conventional commit message.
  - what obstacles or decisions occur: the skill must restrict tool access to git read operations only; it must not write files.
  - what outcome they expect: a ready-to-use conventional commit message output to the session.

- **Scenario: Verifying subagent tool restriction enforcement**
  - who is acting: the repository maintainer performing a validation check.
  - what triggered the action: acceptance criteria verification during delivery.
  - what steps they take: attempts to invoke a tool (e.g., `Write` to a path outside the allowed pattern) from within a restricted subagent session → the permission layer blocks the operation based on the `tools` frontmatter or `settings.json` deny entry.
  - what obstacles or decisions occur: the block must come from the permission/enforcement layer, not merely from prose instructions.
  - what outcome they expect: the operation is blocked with a clear permission error; retrying with an allowed tool succeeds.

- **Scenario: Applying a sync update after changing a canonical agent file**
  - who is acting: the repository maintainer.
  - what triggered the action: a `.github/agents/orchestrator.agent.md` file was updated with new specialist delegation targets.
  - what steps they take: consults `docs/engineering/claude-code-architecture.md` sync strategy section → identifies that `.claude/agents/orchestrator.md` derives its `tools` list from the canonical agent → applies the change manually (or via a documented script/task) → verifies alignment.
  - what obstacles or decisions occur: must understand which parts of `.claude/agents/orchestrator.md` are direct mirrors versus independent.
  - what outcome they expect: `.claude/` and `.github/` are aligned; the sync documentation provides enough detail to complete the task without guessing.

## Acceptance Criteria

- [x] A developer can invoke `/orchestrate` by name in a Claude Code session and trigger the full orchestration workflow without manual agent configuration steps
- [x] A developer can invoke `/commit-message` and receive a conventional commit message formatted according to the repository's canonical conventions
- [x] A developer can invoke `/pr-author` and receive a complete, GitHub-ready PR body derived from the pr_context artifacts
- [x] A developer can invoke `/research-issue` and receive structured research output written to the correct artifact path under `artifacts/research/`
- [x] Subagent tool restrictions correctly block operations outside their declared allowlist (verified by attempting a disallowed operation from within the relevant subagent context)
- [x] The orchestrator subagent reads `artifacts/orchestration/orchestrator-state.json` at session start and resumes from the recorded `next_step` rather than restarting from scratch when a valid checkpoint exists
- [x] The `PreToolUse` hook blocks at least one representative dangerous-command pattern (e.g., `rm -rf` or `git push --force`) via the hook script in `.claude/hooks/`
- [x] The `SubagentStop` hook blocks premature subagent termination when the required completion artifact (plan path, research path, or review artifact path) is absent from the output
- [x] A developer can follow the sync strategy documentation in `docs/engineering/claude-code-architecture.md` to determine whether `.claude/` content is current with `.github/` sources and apply updates
- [x] The architecture documentation explicitly identifies each non-equivalence between Copilot and Claude and does not claim runtime enforcement for behaviors that are enforced only by prompt conventions

## Non-Goals

- Rewriting or restructuring any existing `.github/agents/`, `.github/skills/`, or `.github/instructions/` files as part of this feature.
- Implementing agent teams (experimental Claude feature, higher-cost, not suited to this repository's sequential pipeline model).
- Supporting `.claude/commands/` as a primary user-invocable surface; it is a legacy compatibility surface only.
- Providing a fully automated synchronization script (documented manual process is sufficient for the initial delivery; automation may be a follow-up feature).
- Modifying the existing Copilot orchestration behavior or any running CI pipeline.

