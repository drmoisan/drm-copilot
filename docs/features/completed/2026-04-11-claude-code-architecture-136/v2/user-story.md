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

A command-only or `CLAUDE.md`-only approach (the original draft design) intentionally discards supported Claude features and is not a correct Claude-native architecture. The migration research also proves one specific architectural correction is required: Claude subagents cannot spawn downstream subagents, so the repository cannot model `/orchestrate` as a forked `orchestrator` worker that then performs nested planner, executor, reviewer, and researcher handoffs. The repository needs a main-thread orchestrator model, with wrapper skills for user entry points and bounded worker subagents for implementation, planning, research, and review.

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
  - what steps they take: invokes `/orchestrate "add support for X"` → the current main Claude session is already running as the `orchestrator` agent via `.claude/settings.json` → the `orchestrate` skill frames the objective and required workflow rules → the orchestrator reads the checkpoint file → detects no prior state for this objective → routes through the promotion, research, planning, execution, and review lifecycle by launching bounded worker subagents from the main thread → writes checkpoint after each phase → returns a completion summary with all required artifact paths.
  - what obstacles or decisions occur: the orchestrator must respect the phase-gating rules from the Copilot orchestration model, while also respecting Claude's no-nested-subagent limitation; the `SubagentStop` hook must block early termination of worker agents when required artifacts are missing.
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
  - what steps they take: attempts to invoke a tool (for example, `Write` to a path outside the allowed pattern or a disallowed `Bash` command) from within a restricted subagent session → the permission layer blocks the operation based on the `tools` frontmatter or `settings.json` deny entry → the maintainer reviews whether the block came from permissions or the `PreToolUse` hook.
  - what obstacles or decisions occur: the block must come from the permission/enforcement layer, not merely from prose instructions.
  - what outcome they expect: the operation is blocked with a clear permission error; retrying with an allowed tool succeeds.

- **Scenario: Reviewing the `.github` to `.claude` migration scope before implementation**
  - who is acting: the repository maintainer.
  - what triggered the action: the maintainer reads the migration research and needs to confirm which repository files become Claude skills, which become Claude subagents, and which remain `.github`-only canonical sources.
  - what steps they take: consults the architecture documentation and spec tables → verifies that canonical reusable workflow contracts remain authored under `.github/skills/` and mirrored into `.claude/skills/` → verifies that only bounded repository-canonical workers are committed under `.claude/agents/` → confirms that generic beast, mentor, and framework-specific personas are kept out of project scope.
  - what obstacles or decisions occur: the maintainer must distinguish between repository-canonical worker agents, main-thread-only orchestration logic, wrapper skills for prompts, and personal/library personas that should not affect automatic routing.
  - what outcome they expect: the migration scope is explicit, file-by-file, and does not require guessing which assets should exist under `.claude/`.

- **Scenario: Applying a sync update after changing a canonical agent file**
  - who is acting: the repository maintainer.
  - what triggered the action: a `.github/agents/orchestrator.agent.md` file was updated with new specialist delegation targets.
  - what steps they take: consults `docs/engineering/claude-code-architecture.md` sync strategy section → identifies that `.claude/agents/orchestrator.md` derives its `tools` list from the canonical agent → applies the change manually (or via a documented script/task) → verifies alignment.
  - what obstacles or decisions occur: must understand which parts of `.claude/agents/orchestrator.md` are direct mirrors versus independent.
  - what outcome they expect: `.claude/` and `.github/` are aligned; the sync documentation provides enough detail to complete the task without guessing.

## Acceptance Criteria

- [x] The architecture documentation states explicitly that the provided `20260412-claude-code-github-skills-agents-migration-research.md` research is sufficient to define the migration scope and file-by-file Claude mapping without additional discovery work. Evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t2.architecture-doc-green.2026-04-12T15-57.md`.
- [x] The Claude architecture uses a main-thread orchestrator model and does not require a forked `orchestrator` subagent to spawn downstream subagents. Evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t1.claude-runtime-green.2026-04-12T15-57.md`, `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t2.architecture-doc-green.2026-04-12T15-57.md`.
- [ ] A developer can invoke `/orchestrate` by name in a Claude Code session and trigger the full orchestration workflow without manual agent configuration steps beyond opening the repository in Claude Code. Blocker: live Claude session invocation is unavailable in the current shell-only environment. Evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t4.live-skill-validation.2026-04-12T15-57.md`.
- [ ] A developer can invoke `/commit-message` and receive a conventional commit message formatted according to the repository's canonical conventions. Blocker: live Claude session invocation is unavailable in the current shell-only environment. Evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t4.live-skill-validation.2026-04-12T15-57.md`.
- [ ] A developer can invoke `/pr-author` and receive a complete, GitHub-ready PR body derived from the pr_context artifacts. Blocker: live Claude session invocation is unavailable in the current shell-only environment. Evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t4.live-skill-validation.2026-04-12T15-57.md`.
- [ ] A developer can invoke `/research-issue` and receive structured research output written to the correct artifact path under `artifacts/research/`. Blocker: live Claude session invocation is unavailable in the current shell-only environment. Evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t4.live-skill-validation.2026-04-12T15-57.md`.
- [x] The migration documentation includes a file-by-file mapping for the canonical `.github/skills/*/SKILL.md` files to their `.claude/skills/*/SKILL.md` targets, including any files that remain documentation-only rather than runtime assets. Evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t2.architecture-doc-green.2026-04-12T15-57.md`.
- [x] The migration documentation includes a file-by-file disposition for all `.github/agents/*.agent.md` files, identifying which become project subagents, which become wrapper skills, which remain main-thread-only orchestration logic, and which are personal or library personas that stay out of project scope. Evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t2.architecture-doc-green.2026-04-12T15-57.md`, `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t6.disallowed-agent-validation.2026-04-12T15-57.md`.
- [x] The migration documentation identifies the direct-use `.github/prompts/*.prompt.md` entry points that must become `.claude/skills/*/SKILL.md` files rather than `.claude/commands/*` files. Evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t2.architecture-doc-green.2026-04-12T15-57.md`.
- [x] The migration documentation distinguishes between repository-enforceable controls (`CLAUDE.md`, `.claude/rules/`, `.claude/settings.json`, `.claude/hooks/*`) and controls that require managed settings outside the repository for non-overrideable enforcement. Evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t2.architecture-doc-green.2026-04-12T15-57.md`.
- [ ] Subagent tool restrictions correctly block operations outside their declared allowlist (verified by attempting a disallowed operation from within the relevant subagent context). Blocker: no live subagent-session permission probe was executed in the current environment. Evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t2.permissions-and-agent-scope-validation.2026-04-12T15-57.md`, `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t4.live-skill-validation.2026-04-12T15-57.md`.
- [ ] The main-thread orchestrator reads `artifacts/orchestration/orchestrator-state.json` at session start and resumes from the recorded `next_step` rather than restarting from scratch when a valid checkpoint exists. Blocker: live runtime resume behavior remains unverified in the current shell-only environment. Evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t5.checkpoint-resume-validation.2026-04-12T15-57.md`.
- [x] The `PreToolUse` hook blocks at least one representative dangerous-command pattern (for example `rm -rf` or `git push --force`) via the hook script in `.claude/hooks/`. Evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t3.validate-bash-green.2026-04-12T15-57.md`, `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t3.hook-enforcement-validation.2026-04-12T15-57.md`.
- [ ] The `SubagentStop` hook blocks premature worker termination when the required completion artifact (plan path, research path, or review artifact path) is absent from the output. Blocker: the hook configuration is present, but no live stop-gate execution was captured in the current environment. Evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p5-t3.hook-enforcement-validation.2026-04-12T15-57.md`.
- [x] A developer can follow the sync strategy documentation in `docs/engineering/claude-code-architecture.md` to determine whether `.claude/` content is current with `.github/` sources and apply updates. Evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t2.architecture-doc-green.2026-04-12T15-57.md`.
- [x] The architecture documentation explicitly identifies each non-equivalence between Copilot and Claude and does not claim runtime enforcement for behaviors that are enforced only by prompt conventions. Evidence: `docs/features/active/2026-04-11-claude-code-architecture-136/v2/evidence/qa-gates/p4-t2.architecture-doc-green.2026-04-12T15-57.md`.

## Non-Goals

- Rewriting or restructuring any existing `.github/agents/`, `.github/skills/`, or `.github/instructions/` files as part of this feature.
- Converting every `.github/agents/*.agent.md` file into a committed project Claude subagent regardless of whether it is repository-canonical, bounded, or appropriate for automatic routing.
- Implementing agent teams (experimental Claude feature, higher-cost, not suited to this repository's sequential pipeline model).
- Supporting `.claude/commands/` as a primary user-invocable surface; it is a legacy compatibility surface only.
- Providing a fully automated synchronization script (documented manual process is sufficient for the initial delivery; automation may be a follow-up feature).
- Modifying the existing Copilot orchestration behavior or any running CI pipeline.
- Treating project-level `.claude/settings.json` as if it can prevent all user overrides; stronger non-optional enforcement through managed settings is a follow-up concern, not part of the initial repository-scoped migration.
