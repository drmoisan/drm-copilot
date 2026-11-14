# Research: epic preparation orchestrators lack the Agent tool at depth (Issue #1138)

- Issue: #1138
- Branch: bug/epic-subagent-nesting-depth
- Inputs: `issue.md`, `spec.md` in this feature folder
- Filename stamp: the researcher has no clock-reading tool; the stamp was not read from the host clock (see handback).

## 1. Claude Code platform behavior (verified sources)

### 1.1 Documentation (https://code.claude.com/docs/en/sub-agents; docs.claude.com redirects there)

- `## Work with subagents` > `Let subagents spawn their own subagents`: "By default, a subagent can spawn subagents of its own, up to three layers below the main conversation. At the depth limit, Claude Code withholds the `Agent` tool from every subagent except a fork, so a subagent at the limit does its delegated work itself and returns one summary. A fork at the limit keeps `Agent` in its inherited tool list, but the tool returns an error instead of spawning."
- Same section: "To change the limit, set `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` to the number of subagent layers you want below your main conversation." Example value `"2"` in `settings.json` `env`: "your subagents can delegate to a second layer of their own, and that second layer can't delegate further. Set `1` to turn nesting off."
- `Control subagent capabilities` > `Available tools`: the first filter removes "`Agent`, when the subagent is at the depth limit". The background filter keeps a fixed built-in list, but "`Agent` and `ExitPlanMode` ... follow the first filter's conditions wherever the subagent runs". Running in the background therefore does not remove `Agent`; only depth does.
- `Restrict which subagents can be spawned`: "The `Agent(agent_type)` allowlist syntax applies only to an agent running as the main thread with `claude --agent`. In a subagent definition, listing `Agent` in `tools` lets that subagent spawn subagents of its own while the depth limit allows it, but any type list inside the parentheses is ignored." Also: "If you omit `Agent` from the `tools` list entirely, the agent can't spawn any subagents." The Task tool was renamed Agent in 2.1.63; `Task(...)` remains an alias.

### 1.2 Skills documentation (https://code.claude.com/docs/en/skills, `Run skills in a subagent`)

- "Add `context: fork` ... Claude Code starts a new subagent of the type set in the `agent` field and gives it the skill content as its prompt." The `agent` field "determines the execution environment (model, tools, and permissions)".
- "Despite the name, a skill with `context: fork` doesn't run in a fork of the current conversation". It is a regular agent type, so the fork depth exemption does not apply, and it runs in the background by default with the background tool set.
- The page states no depth rule for a forked skill and does not address a forked skill invoked from inside a subagent. Inference (not stated by the docs): a forked skill invoked from the main session creates a subagent one layer below the main conversation, i.e. depth 1, the same as `Agent(...)` from the main session.

### 1.3 Changelog (https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md)

| Version | Entry (quoted) |
|---|---|
| 2.1.172 | "Sub-agents can now spawn their own sub-agents (up to 5 levels deep)" |
| 2.1.181 | "Fixed foreground subagents spawning unbounded nested chains; they now respect the same 5-level depth limit" (quote trimmed by the fetch tool) |
| 2.1.187 | "Fixed subagent depth tracking: resumed subagents now restore their original spawn depth" (same entry: forked subagents count toward the depth cap) |
| 2.1.217 | "Changed subagents to no longer spawn nested subagents by default;" "set `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` to allow deeper nesting" |
| 2.1.219 | "Subagents can now spawn nested subagents up to depth 3 by default (was 1);" "set CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1 to disable nesting" |
| 2.1.224 | "Removed the 200-subagent-per-session spawn cap; ... (concurrency and depth limits still apply)" |
| 2.1.285 / 2.1.302 | a subagent's own Agent call runs in the foreground (affects result delivery, not availability) |

The fetch scanned offsets 0 to 900000 of about 1.18 million characters; older entries (below 2.1.129) were not read. The entries above are sufficient for the 2.1.x range in use (the execution-environment brief pins Claude Code 2.1.318 in the devcontainer).

## 2. Repository contract (verified by reading the files)

| Surface | Frontmatter |
|---|---|
| `.claude/skills/epic-plan/SKILL.md` | `context: fork`, `agent: epic-planner` |
| `.claude/skills/epic-run/SKILL.md` | `context: fork`, `agent: epic-orchestrator` |
| `.claude/skills/epic-orchestrate/SKILL.md` | `context: fork`, `agent: epic-orchestrator` |
| `.claude/skills/parallel-plan/SKILL.md` | `context: fork`, `agent: parallel-planner` |
| `.claude/skills/parallel-run`, `parallel-orchestrate`, `parallel-add`, `parallel-close`, `parallel-remove` | `context: fork`, `agent: parallel-orchestrator` |
| `.claude/skills/orchestrate/SKILL.md` | no `context:`/`agent:`; runs in the main session |
| `.claude/agents/orchestrator.md` | `tools:` first entry `Agent(atomic-planner,...,typescript-engineer)` (15 types) |
| `.claude/agents/epic-planner.md`, `parallel-planner.md` | `Agent(orchestrator)` |
| `.claude/agents/epic-orchestrator.md`, `parallel-orchestrator.md` | `Agent(orchestrator)`, `Agent(pr-author)` |

- Only these five agents list `Agent` (Grep `^\s*- "?Agent` over `.claude/agents/`). Leaf specialists never delegate, so the deepest required spawning layer is the per-feature `orchestrator`.
- Per section 1.1 the parenthesized type lists are ignored in subagent definitions; they document intent but do not restrict. They do not cause the defect.
- No file outside `docs/` names `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH`; `.claude/settings.json` has no `env` block. No surface states the depth assumption (Grep for `depth` in `orchestrate/SKILL.md` matches only the GitHub Actions reusable-workflow cap).
- `.claude/hooks/enforce-epic-invocation-origin.ps1` (PreToolUse, `Agent` matcher): gates targets `epic-planner`, `epic-orchestrator`, `parallel-planner`, `parallel-orchestrator`; allows when `agent_type` is absent (main thread) and denies only when the caller `agent_type` is exactly `orchestrator`. It assumes the gated agents are entered from the main session (via a forked skill or a main-thread `Agent` call) and never inspects depth. Calls with target `orchestrator` are always allowed.
- `blocked_reason` already has the mechanical member `spawn_agent_unavailable` (`.claude/rules/orchestrator-state.md`, `## Blocked-Reason Vocabulary`; `.claude/lib/orchestrator-state/OrchestratorState.psm1`). No producer currently writes it on the Claude side (Grep found only those two files).
- Codex: `.codex/config.toml` sets `max_depth = 3`, `max_threads = 12`; the three-layer pattern is shared, and Codex already configures the needed depth. No Codex change is indicated.
- Bundle mirrors: `extensions/drm-copilot/resources/claude-customizations/.claude/{agents,skills,hooks,settings.json}` carry the same files; `pack-manifests/core.json` lists the hook.
- Pinned hashes: `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` `PINNED_FROZEN_SURFACE_HASHES` pins `.claude/agents/epic-orchestrator.md` and `.claude/skills/epic-orchestrate/SKILL.md`; any edit to either requires a re-baseline comment block (precedent: #1129, #1130) and new digests.

## 3. Failing condition

Depth accounting for the documented entry paths (main conversation = layer 0):

| Entry | Coordinator | Per-feature orchestrator | Specialists |
|---|---|---|---|
| `/epic-plan`, `/epic-run`, `/parallel-*` (forked skill) | depth 1 | depth 2 | depth 3 |
| main session `Agent(epic-orchestrator)` | depth 1 | depth 2 | depth 3 |
| `/orchestrate` (main session) | n/a | depth 0 | depth 1 |

Under the default limit of 3 (2.1.219 and later), depth 3 is the limit layer: specialists lose `Agent`, which they never use, and the depth-2 orchestrator keeps it. This matches the successful drm-copilot epic-run on 2026-11-08 and the routine parallel runs in this repository, which use the same depth.

The reported symptom (coordinator at depth 1 could delegate, orchestrator at depth 2 had no `Agent`) is exactly the documented behavior for an effective limit of 2. Candidate variables:

1. **Effective limit 2 on the failing host (most likely).** `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=2` in a user, project, local, or managed `settings.json` `env` block or in the process environment of the destination session. Explains both observations; drm-copilot sets no such value.
2. **One extra layer above the coordinator.** If `/epic-plan` ran inside a subagent or a conversation fork (forks count toward the cap per 2.1.187), the coordinator is at depth 2 and the orchestrator at depth 3. Note the coordinator at depth 2 would still have `Agent` and the orchestrator would not, matching the symptom.
3. **Claude Code version 2.1.217 to 2.1.218 (default 1).** Rejected as the explanation: the coordinator at depth 1 would itself have had no `Agent`, contradicting the report that it delegated `Agent(orchestrator)`.
4. **Entry path (forked skill vs direct agent).** Rejected: both give the coordinator depth 1, and the docs state background placement does not remove `Agent`.
5. **Stale pushed-down `orchestrator.md` lacking `Agent`.** Possible but unverified; the destination repository was not readable from this agent. The orchestrator should confirm with `git log -p -- .claude/agents/orchestrator.md` and a settings/env inspection in the destination repository.

Confidence: high that the mechanism is the documented depth limit; medium that the specific cause is variable 1 or 2 (not distinguishable without the destination host's settings and session shape).

Reproduction: a live reproduction is not possible from this subagent (no Bash, and a nested `claude -p` run with `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=2` would require a delegating agent). The testable levels are: Pester tests of a hook decision that reads the configured limit through a seam; contract tests pinning the preflight and topology wording in the five agents, the skills, and their bundle mirrors; and an optional manual check in an operator session (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=2` then `/epic-plan` on a two-feature fixture) recorded as manual evidence.

## 4. Fix options

### 4.1 (a) Fail-fast preflight

- Instruction-level preflight (deterministic for the agent itself): each agent sees its own tool list in its system prompt. Add a first step to `orchestrator`, `epic-planner`, `epic-orchestrator`, `parallel-planner`, `parallel-orchestrator`: before any other work, confirm `Agent` is in the available tool list; when absent, write `blocked_reason: "spawn_agent_unavailable"` to the checkpoint where one is owned, perform no specialist work, and return a single line beginning `AGENT_TOOL_UNAVAILABLE:` naming the likely causes (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` below 3, or the run started inside a subagent) and the remedy. Coordinators that receive this line from a child halt the epic or parallel run with the same reason instead of doing the child's work.
- Hook-level preflight (deterministic, before the wasted child run): extend `enforce-epic-invocation-origin.ps1` (or a dot-sourced sibling helper, to keep the file and its tests stable) so that when a gated coordinator (`agent_type` in the four gated types) calls `Agent(orchestrator)`, or the main thread calls a gated target, the hook reads the configured limit through a seam function; when the value is set and parses to an integer below 3, deny with `NESTING_DEPTH_INSUFFICIENT:` and the remedy text. Unset means the default 3 and allows. Whether a hook process inherits settings `env` values is likely (settings `env` is applied to the session environment) but not verified here; the plan must treat it as an assumption and keep the instruction-level preflight as the primary control. The hook cannot see the actual depth, so case 2 in section 3 is caught only by the instruction-level preflight.
- A `SubagentStop` check was considered and rejected: it fires after the work, and the transcript format is not a stable contract.

### 4.2 (b) Documentation of the depth assumption

Add one short `## Nesting Depth` section (same text in each) to `epic-plan`, `epic-run`, `epic-orchestrate`, `orchestrate`, `parallel-plan`, `parallel-run`, `parallel-orchestrate` SKILL.md, stating: the coordinator runs at depth 1, per-feature orchestrators at depth 2, specialists at depth 3; this requires Claude Code 2.1.219 or later with `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` unset or at least 3; the skill must be invoked from the main session, not from a subagent; and the `AGENT_TOOL_UNAVAILABLE` / `spawn_agent_unavailable` outcome. In `orchestrate`, the note says the main-session path needs depth 1 only and a delegated `Agent(orchestrator)` needs `Agent` at its own depth. Also add one line to the execution-environment brief (`## Tool Routes by Agent`) in all six copies, because it states which agents can delegate.

### 4.3 (c) Flattening

- Option C1: drop `context: fork` from `epic-plan`/`epic-run` (and parallel equivalents) so the main session is the coordinator and per-feature orchestrators sit at depth 1. Costs: the coordinator loses its agent frontmatter (`tools:` scoping, `skills:` preload, `SubagentStop` hooks such as the epic-orchestrator checkpoint validation), `enforce-epic-invocation-origin.ps1` loses its main-thread-origin premise, both pinned hashes move, and roughly a dozen skills plus mirrors change. This exceeds about 20 tasks and removes existing enforcement.
- Option C2: coordinator emits per-feature launch prompts that the main session runs. Changes the autonomous-run contract and the epic checkpoint ownership; same scale as C1.
- Neither is needed under the supported configuration, because the default limit already admits the three-layer chain.

### 4.4 Recommendation

Adopt (a) instruction-level preflight in the five agents plus the hook-level limit check, and (b) documentation; do not flatten. Rationale: the defect is a configuration below the documented default rather than a topology that the default rejects; the preflight converts silent degradation into an actionable halt using an existing `blocked_reason` member; and the change stays within PowerShell and Markdown. The hook change touches one hook family already registered on the `Agent` matcher, so `settings.json` registration is unchanged if the logic is dot-sourced from the existing hook.

Required file families: five agents and seven skills (plus bundle mirrors under `extensions/drm-copilot/resources/claude-customizations/.claude/`), the hook and a new helper with the manifest entry in `pack-manifests/core.json`, the epic-orchestrator pinned-hash re-baseline, a Pester test file for the helper, one Pester contract test file for the wording, and the six execution-environment copies. Estimated at 16 to 20 tasks.

Rejected alternatives: C1/C2 flattening (scale, loss of agent-scoped hooks); `SubagentStop` detection (post-hoc); setting `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` in the pushed-down `settings.json` (it would override a destination's deliberate choice and does not cover case 2; it may be reconsidered as a documented recommendation only).

## 5. Testing implications

- Pester unit tests for the helper: unset value allows; `3` and above allow; `2`, `1`, `0` deny with `NESTING_DEPTH_INSUFFICIENT`; non-integer value (fail closed or allow must be decided in the spec; recommend deny with a parse message); target/caller matrix (main thread to gated target, gated caller to `orchestrator`, `orchestrator` caller to specialist unaffected). Environment read goes through a seam function mocked in tests; no environment variable mutation, no temp files.
- Existing `tests/scripts/claude-hooks/enforce-epic-invocation-origin.Tests.ps1` and `PreToolUseSchema.Contract.Tests.ps1` must still pass; the plan names them with disposition.
- New Pester contract test under `tests/scripts/claude-runtime/` asserting the preflight sentence in the five agents and the `## Nesting Depth` section in the seven skills, in both live and bundle copies.
- Python contract tests run unchanged: push-down resource parity and manifest completeness/dependency closure, `parallel_orchestrator_surface_expectations.py` with new digests, Codex generator `--check`.

## 6. Pre-Mortem

- Review checklists: a reviewer can flag the hook env read as unverified behavior; mitigation: the plan records the inheritance assumption in the spec, keeps the instruction preflight as the primary control, and states the honest limit (hook cannot see actual depth).
- Coverage: the new helper must reach 85% line coverage in the PowerShell gate; mitigation: one test per branch of the limit parse and caller matrix, with the env read behind a mocked seam.
- Mirror parity: every edited agent, skill, hook, and the execution-environment brief has bundle copies (six copies for the brief); mitigation: one task per mirror family and a run of the push-down parity, manifest completeness, and dependency-closure tests; the `Mirror parity` bullet of the plan names the brief-update task.
- File size: `enforce-epic-invocation-origin.ps1` is 287 lines and the agents are long Markdown (exempt); mitigation: put new logic in a dot-sourced sibling helper with its own test file.
- Test isolation: tests must not set `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` in the process; mitigation: seam function mocked per `It`, and the leak scan in `poshqc / PowerShell QC static` confirms no environment mutation.
- CI-only behavior: the Linux hook-suite job runs `tests/scripts/claude-hooks` case-sensitively; mitigation: `Join-Path`, exact file-name case, no drive letters in fixtures.
- Evidence: the platform behavior cannot be reproduced live by an isolated subagent, and branch hooks are not exercised by isolated subagents until merge; mitigation: acceptance relies on Pester and contract tests, with a fail-before exception dossier under `evidence/regression-testing/` citing sections 1 and 3 of this document.
