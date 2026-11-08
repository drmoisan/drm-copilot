# epic-preparation-orchestrators-lack-agent-tool-at-depth (Spec)

- **Issue:** #1138
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T11-44
- **Status:** Draft
- **Version:** 0.2

## Context
`/epic-plan` and `/epic-run` broke when the per-feature orchestrators they delegate to ran two levels below the session root: those orchestrators had no Agent tool, so they could not delegate to task-researcher, atomic-planner, atomic-executor or other specialists, and the epic stalled or the orchestrator did the work itself. No preflight detected the condition. Severity: Blocker.

Environment: Windows 11 Pro, Claude Code CLI; `/epic-plan` and `/epic-run` on the iar-migration three-layer redesign epic (E1/E2), 2026-11-07/08; chain epic-planner -> preparation-mode `Agent(orchestrator)` -> specialists. Research: `research/research.2026-11-08T16-51.md`.

## Root Cause Analysis
Confidence: high on the mechanism, medium on the specific trigger.

- Claude Code 2.1.219 and later lets a subagent spawn subagents up to depth 3 below the main conversation by default. At the depth limit it withholds the Agent tool from the subagent. `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` changes the limit (`1` disables nesting).
- The epic and parallel chain is: coordinator at depth 1 (`context: fork` skill, or a main-session `Agent(...)`), per-feature `orchestrator` at depth 2, specialists at depth 3. Only the depth-2 orchestrator needs Agent below the coordinator; specialists never delegate.
- An effective limit of 2 leaves the depth-2 orchestrators without Agent while the depth-1 coordinator keeps it, which matches the report. Candidate triggers: `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=2` in a settings `env` block or the process environment; the skill started from inside a subagent or fork (one extra layer); or a Claude Code version whose nesting default was lower.
- The drm-copilot host runs Claude Code 2.1.319 with the variable unset, which explains the successful epic-run on 2026-11-08.
- No repository surface states or checks the depth assumption, and `blocked_reason: "spawn_agent_unavailable"` (already in `.claude/rules/orchestrator-state.md`) has no Claude-side producer.

## Reproduction Status
A live reproduction is not possible from inside a subagent: it would require a delegating agent running a nested session with the variable set. The testable level is a Pester-tested hook helper (configured limit read through a mocked seam) plus Pester wording contract tests over the agents, skills, brief, and their bundle mirrors. An optional manual check (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=2`, then `/epic-plan` on a two-feature fixture in an operator session) may be recorded under `evidence/regression-testing/` but is not a gate.

## Scope
In scope: agent-instruction preflight, hook-level preflight helper, main-session topology fallback documentation, `## Nesting Depth` skill sections, the execution-environment brief line, bundle mirrors, pack manifest entry, and the pinned-hash re-baseline.

## Non-goals
- Flattening the chain by removing `context: fork` from the coordinator skills, or making the coordinator emit launch prompts as the default topology (research options C1/C2).
- Setting `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` in the pushed-down `settings.json`.
- A `SubagentStop` post-hoc detection check.
- Codex changes: `.codex/config.toml` already sets `max_depth = 3`; out of scope.
- Detecting the actual runtime depth in the hook (the hook can only see the configured value).

## Functional Requirements

### FR1 Instruction-level preflight
The agent files `.claude/agents/orchestrator.md`, `epic-planner.md`, `epic-orchestrator.md`, `parallel-planner.md`, and `parallel-orchestrator.md` gain a first startup step: confirm the Agent tool is in the available tool list before any other work. When it is absent, the agent records `blocked_reason: "spawn_agent_unavailable"` where it owns a checkpoint, performs no specialist work, and returns a line beginning `AGENT_TOOL_UNAVAILABLE:` that names the causes (variable below 3, run started inside a subagent, older Claude Code version) and both remedies (raise or unset `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`, or use the main-session fallback of FR3). A coordinator that receives that line from a child halts with the same reason instead of doing the child's work.

### FR2 Hook-level preflight
A new helper `.claude/hooks/epic-invocation-nesting-depth.ps1` is dot-sourced into `.claude/hooks/enforce-epic-invocation-origin.ps1` inside a guard that follows the existing guarded dot-source pattern (a failed import denies gated delegations rather than failing open). The helper:
- reads `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` only through a seam function (`Get-SubagentSpawnDepthSetting`);
- applies to delegations into the epic/parallel chain: main thread calling `epic-planner`, `epic-orchestrator`, `parallel-planner`, or `parallel-orchestrator`, and a gated coordinator (`agent_type` in those four) calling `orchestrator`;
- allows when the value is unset or an integer of 3 or more;
- denies with a reason beginning `NESTING_DEPTH_INSUFFICIENT:` plus the remedy text of FR1 when the value is an integer below 3;
- denies (fail closed) with a parse message when the value is set but not an integer;
- leaves `orchestrator` delegations to specialists and all non-chain delegations unaffected.
The existing origin rules of the hook are unchanged. `.claude/settings.json` registration is unchanged.

### FR3 Topology fallback
The `epic-plan`, `epic-run`, `epic-orchestrate`, `parallel-plan`, `parallel-run`, and `parallel-orchestrate` skills document that when depth is insufficient and cannot be raised, the main session itself launches each per-feature `Agent(orchestrator)` with the same delegation prompt (including `Preparation mode: true` for preparation), so orchestrators run at depth 1 and specialists at depth 2.

### FR4 Documentation
- Each skill named in FR3, plus `.claude/skills/orchestrate/SKILL.md`, carries a `## Nesting Depth` section stating the depth layout, the requirement (Claude Code 2.1.219 or later, variable unset or at least 3, invoked from the main session), the `AGENT_TOOL_UNAVAILABLE` / `spawn_agent_unavailable` outcome, and the FR3 fallback. The `orchestrate` section states that the main-session path needs depth 1 only and that a delegated orchestrator needs Agent at its own depth.
- The `## Tool Routes by Agent` section of the execution-environment brief gains one line on the nesting-depth requirement, byte-identical across `.claude/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, and the three copies under `extensions/drm-copilot/resources/{claude-customizations/.claude,customizations/.github,codex-and-agents-customizations/.agents}/skills/execution-environment/SKILL.md`.

### FR5 Mirrors and pins
- Every edited agent, skill, and hook file is mirrored under `extensions/drm-copilot/resources/claude-customizations/.claude/`.
- The new helper is listed in `pack-manifests/core.json` next to `enforce-epic-invocation-origin.ps1`.
- Because `epic-orchestrator.md` and `epic-orchestrate/SKILL.md` change, `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` is re-baselined with a comment block citing #1138 (precedent #1129, #1130).

## Assumptions, Constraints, Dependencies
- Assumption (unverified): a PreToolUse hook process inherits values from a settings `env` block. The instruction-level preflight (FR1) is therefore the primary control; FR2 is an early-deny supplement and cannot detect the extra-layer trigger.
- Constraints: no new Python; all new code is PowerShell 7+; Pester 6.x; tests mock the seam, do not mutate environment variables, and create no temp files; tests run parallel-safe; `enforce-epic-invocation-origin.ps1` stays small (new logic lives in the helper).
- Dependencies: Claude Code 2.1.219 or later for the default depth of 3.

## Test Strategy
- `tests/scripts/claude-hooks/epic-invocation-nesting-depth.Tests.ps1` (new): limit parse and caller/target matrix with `Get-SubagentSpawnDepthSetting` mocked per `It`.
- `tests/scripts/claude-runtime/NestingDepthContract.Tests.ps1` (new): wording contract over live and bundle copies.
- Existing suites run unchanged in disposition: `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1`, `PreToolUseSchema.Contract.Tests.ps1`, push-down resource parity, manifest completeness and dependency closure, `tests/scripts/dev_tools/test_execution_environment_brief_contracts.py`, `parallel_orchestrator_surface_expectations.py` with new digests, Codex generator `--check`.
- Toolchain: PoshQC format -> analyze -> Pester test, plus the repository Python contract tests unchanged.

## Acceptance Criteria
- [ ] AC1: Each of `.claude/agents/orchestrator.md`, `epic-planner.md`, `epic-orchestrator.md`, `parallel-planner.md`, and `parallel-orchestrator.md` contains the Agent-tool preflight as its first startup step, naming `spawn_agent_unavailable` and `AGENT_TOOL_UNAVAILABLE:`; verified by `NestingDepthContract.Tests.ps1` "agent files carry the Agent-tool preflight".
- [ ] AC2: The coordinator agents (`epic-planner`, `epic-orchestrator`, `parallel-planner`, `parallel-orchestrator`) state that an `AGENT_TOOL_UNAVAILABLE:` line from a child halts the run with the same reason; verified by `NestingDepthContract.Tests.ps1` "coordinators halt on child AGENT_TOOL_UNAVAILABLE".
- [ ] AC3: The preflight text names both remedies (raise or unset `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`; main-session fallback); verified by `NestingDepthContract.Tests.ps1` "preflight names both remedies".
- [ ] AC4: `.claude/hooks/epic-invocation-nesting-depth.ps1` exists, defines `Get-SubagentSpawnDepthSetting`, and is dot-sourced inside a guard by `enforce-epic-invocation-origin.ps1`; a failed import denies chain delegations; verified by `epic-invocation-nesting-depth.Tests.ps1` "guarded import failure denies".
- [ ] AC5: Unset value and integer values of 3 or more allow; verified by `epic-invocation-nesting-depth.Tests.ps1` "allows when unset" and "allows at or above 3".
- [ ] AC6: Integer values below 3 (including 2, 1, 0) deny with a reason beginning `NESTING_DEPTH_INSUFFICIENT:` that names both remedies; verified by `epic-invocation-nesting-depth.Tests.ps1` "denies below 3 with remedy text".
- [ ] AC7: A set, non-integer value denies with a parse message; verified by `epic-invocation-nesting-depth.Tests.ps1` "denies non-integer value".
- [ ] AC8: The check applies to main thread -> gated coordinator and gated coordinator -> `orchestrator`, and does not apply to `orchestrator` -> specialist or other delegations; verified by `epic-invocation-nesting-depth.Tests.ps1` "caller and target matrix".
- [ ] AC9: The tests never set environment variables and create no temp files; verified by the `poshqc / PowerShell QC static` leak scan passing on the new test file.
- [ ] AC10: `epic-invocation-nesting-depth.ps1` reaches at least 90% line coverage in the Pester coverage run, and no existing file's line coverage drops.
- [ ] AC11: `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` and `PreToolUseSchema.Contract.Tests.ps1` pass unchanged in assertions.
- [ ] AC12: The `epic-plan`, `epic-run`, `epic-orchestrate`, `parallel-plan`, `parallel-run`, and `parallel-orchestrate` SKILL.md files contain a `## Nesting Depth` heading that documents the main-session `Agent(orchestrator)` fallback including `Preparation mode: true`; verified by `NestingDepthContract.Tests.ps1` "coordinator skills document Nesting Depth and fallback".
- [ ] AC13: `.claude/skills/orchestrate/SKILL.md` contains a `## Nesting Depth` heading stating the main-session path needs depth 1 and a delegated orchestrator needs Agent at its own depth; verified by `NestingDepthContract.Tests.ps1` "orchestrate documents Nesting Depth".
- [ ] AC14: The `## Tool Routes by Agent` section carries the nesting-depth line, byte-identical in every execution-environment copy listed in FR4; verified by `test_execution_environment_brief_contracts.py` and `NestingDepthContract.Tests.ps1` "brief carries nesting-depth line".
- [ ] AC15: Bundle mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/` match the live agent, skill, and hook files; verified by the push-down resource parity test and the bundle-copy cases in `NestingDepthContract.Tests.ps1`.
- [ ] AC16: `pack-manifests/core.json` lists `epic-invocation-nesting-depth.ps1`; verified by the manifest completeness and dependency-closure tests.
- [ ] AC17: `PINNED_FROZEN_SURFACE_HASHES` is re-baselined with a #1138 comment block and its test passes.
- [ ] AC18: No new Python file is added, and no file under `.codex/` changes; verified from the branch diff.
- [ ] AC19: Full toolchain pass (PoshQC format -> analyze -> Pester, plus repository contract tests) completes without errors.

## Risks & Mitigations
- Hook env inheritance unverified: FR1 is the primary control; the assumption is stated above.
- Mirror drift across agents, skills, brief copies: contract and parity tests cover live and bundle copies.
- Linux case-sensitive CI hook job: tests use `Join-Path`, exact file-name case, and no drive letters.

## Rollout & Follow-up
- Merge via PR on `bug/epic-subagent-nesting-depth`; push-down delivers the agents, skills, and helper to destinations after extension rebuild.
- Links: issue #1138; research `research/research.2026-11-08T16-51.md`.
