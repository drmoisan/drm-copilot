# Research: PowerShell batch-budget hook as a large-path routing signal (Issue #769)

- Issue: #769
- Branch: `bug/batch-budget-hook-lacks-orchestration-awareness-769`
- Feature folder: `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769`
- Researched: 2026-09-29
- Owner direction (confirmed 2026-09-29, recorded in `issue.md:66`): the hook exists to signal that a change touching more than 3 production PowerShell files belongs on the large-path orchestrator. The large path has no file cap. Instructions to split work into batches must be removed.

All file:line citations below were verified by reading or searching the files in this worktree on 2026-09-29.

---

## 1. Current State

### 1.1 Claude hook — `.claude/hooks/enforce-powershell-batch-budget.ps1` (457 lines)

Registered on the `Write|Edit` PreToolUse matcher with a relative command, `pwsh -NoProfile -File .claude/hooks/enforce-powershell-batch-budget.ps1` (`.claude/settings.json:128`, `:144`).

Code paths:

| Path | Location | Behavior |
|---|---|---|
| Unreadable envelope | `:334-340` | deny, fail closed (`Resolve-ClaudeHookToolInput` anomaly) |
| No `file_path` | `:342-345` | allow |
| Non-PowerShell extension | `:347-350` (hook), `:273-275` (decision) | allow |
| Out-of-root candidate | `:279-282` | allow, no slot consumed, no state write |
| Test vs production classification | `:284` | `(^|/)tests/.*\.ps1$` or `\.Tests\.ps1$` is test; all else production |
| Already-counted path | `:289-291` | allow, no state write |
| Cap reached | `:293-298` | deny with the message below |
| Slot consumed | `:300-306` | allow, `shouldWriteState = $true` |
| Session id resolution | `:111-174`, `:356-360` | explicit arg, then `CLAUDE_SESSION_ID`, then `.claude/state/current-session-id`, then a worktree-derived id |
| State file | `:352`, `:366` | `<Root>/.claude/state/powershell-batch-budget.<session>.json` |
| Persisted cap override | `:214-215` | `prodCap`/`testCap` in the state file override the defaults |
| Environment cap override | `:426-433` | `CLAUDE_POWERSHELL_BUDGET_PROD` / `_TEST` |
| Defaults | `:316-317`, `:426-427` | prod cap 3, test cap 3 |
| Root | `:210`, `:269`, `:315` | `Split-Path (Split-Path $PSScriptRoot -Parent) -Parent`, the directory that contains `.claude/` |
| Entry point output | `:436-439` | deny-only: emits JSON only on deny, strips `state` |

The deny message, verbatim (`:296`):

```
PowerShell per-batch budget exceeded: $kind file cap is $cap and is already full ($currentFiles). Requested new file: $normalized. Split the work into a new batch, raise the cap via CLAUDE_POWERSHELL_BUDGET_$kindUpper environment variable with approved scope, or reset the batch by deleting $StateFile.
```

The hook contains no reference to orchestration, routes, or checkpoints. The docstring (`:9-11`, `:37-45`) documents the per-batch model and the state-file-deletion reset.

### 1.2 Codex hook — `.codex/hooks/enforce-powershell-batch-budget.ps1` (256 lines)

Same structure as a separate implementation (not byte-identical to the Claude hook): shared transport via `codex-pretooluse-file-mapping.ps1` (`:41`), no containment filter, no session-id fallback (session id is required, `:226`), state under `.codex/state/` (`:190`), root derived from `$PSScriptRoot` (`:228`), caps hard-coded 3/3 (`:229-230`), persisted cap override (`:77-78`), both sides of a rename consume budget (`:236-251`). Deny message (`:139`):

```
PowerShell per-batch budget exceeded: $kind file cap is $cap and is already full ($currentFiles). Requested new file: $normalized. Split the work into a new batch, record an approved cap in $StateFile, or reset the batch by deleting that state file.
```

Registered in `.codex/config.toml` with `$(git rev-parse --show-toplevel)/.codex/hooks/...` commands (`.codex/config.toml:119-137` pattern).

### 1.3 Extension-bundled copies (hand-mirrored, byte-parity enforced)

| Bundled copy | Parity binding |
|---|---|
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1` | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:118-143` — every repo `.claude/**` file (except `settings.local.json` and `agent-memory/**`) must exist in the bundle with identical text |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1` | `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:215-228` (all `.codex/**` and `.agents/**`); `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:114` ("keeps the canonical hooks byte-identical to their bundled copies") and `:96-109` (500-line cap on root and bundle) |

No generator or sync script produces these copies; `scripts/dev_tools/` contains no resource-sync tool and `extensions/drm-copilot/package.json` has no sync script. The copies are maintained by hand and held by the parity tests above. The hook is listed in pack manifests: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/powershell.json:8` and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json:56`. Coverage targets: `scripts/powershell/PoshQC/settings/pester.runsettings.psd1:31` (Claude) and `:136` (Codex), with the same entries in the bundled `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.

### 1.4 Tests that bind current behavior

| Test file | Binding |
|---|---|
| `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` (495 lines) | `:85-96` asserts `*production file cap is 1*`; `:98-107` asserts `*test file cap is 1*` (test cap deny); `:63-72` test-file slot recorded; `:131-147` persisted state; `:484-493` sets `CLAUDE_POWERSHELL_BUDGET_PROD/TEST`. The file is 5 lines under the 500-line cap, so new cases cannot be added here. |
| `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1` | Shared `-ForEach` over Python and PowerShell (`:69-88`). PowerShell rows assert `production file cap is 1` and `state.json` in the reason (`:167-176`), `test file cap is 0` (`:178-185`), persisted cap overlay `prodCap 5` (`:112-121`), persisted cap honored (`:267-281`), test slot consumed (`:187-195`). |
| `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` | `:233-237` pure decision with `ProdCap 1` denies; `:130-135` no `$env:CLAUDE_` reads in Codex hooks; `:30` shared-module list; `:137` shared modules must be in the core pack manifest. |
| `tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1:89-93` | Requires `Get-PowerShellBatchBudgetBlockDecision -Reason` to exist and return the deny shape. |
| `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1:18,26`, `codex-pretooluse-integration.Tests.ps1:192-202` | Registration and "no state left behind"; not message-dependent. |
| `tests/scripts/dev_tools/test_push_down_codex_and_agents_*.py`, `test_blast_radius_token_shapes.py:55`, `BlastRadiusTokenShape.Tests.ps1:90` | State-file path tokens only; unaffected unless the state-file name changes. |

### 1.5 The hook already runs only where a checkpoint exists

`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` is registered on the same `Write|Edit` matcher (`.claude/settings.json:152`). It classifies every `.ps1`/`.psm1` path as implementation (`:123`) and denies the write unless `artifacts/orchestration/orchestrator-state.json` carries `issue-num`, a `docs/features/active/` `feature-folder`, `route_id` (fallback `path_selected`), and `lifecycle_ready: true` (`:227-255`, `:417-429`). Consequently, in any session where this hook is live, every PowerShell write that reaches the batch-budget hook's cap branch already has a checkpoint at the root. The difference between "direct" and "large path" is therefore observable as the checkpoint's route, not as the presence of a checkpoint.

---

## 2. Large-Path Detection Signal

### 2.1 Candidates evaluated

| Candidate | Evidence | Verdict |
|---|---|---|
| **A. `artifacts/orchestration/orchestrator-state.json` route (`route_id`, fallback `path_selected`) read from the hook's own root** | Written by the Claude orchestrator (`.claude/skills/orchestrate/SKILL.md:33-36`) and the Codex orchestrator (`.codex/agents/orchestrator.toml:28`, `:48`, `:146-147`). The same file and field pair are already read by the preimplementation gate (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:31`, `:237-240`), by `enforce-completion-helpers.ps1:138-144`, and by the Python validator (`scripts/dev_tools/_orchestrator_state_routing.py:36-60`). Route values are defined in `config/orchestration-routing.json:4-143`. The current checkpoint in this worktree carries `"path_selected": "large"`, `"route_id": "large"` (`artifacts/orchestration/orchestrator-state.json:7-8`). | **Selected** |
| B. `agent_type` / `agent_id` on the PreToolUse envelope | Claude Code documentation (fetched 2026-09-29 from `https://code.claude.com/docs/en/hooks`, "Common input fields") states both fields are present when a hook fires inside a subagent. `.claude/hooks/enforce-epic-invocation-origin.ps1:18-31` relies on `agent_type`. However, `atomic-executor` performs writes on both the small route and the large route (`config/orchestration-routing.json:13-17`, `:37-44`), so agent identity does not distinguish the routes. A direct-mode `powershell-typed-engineer` and a large-path executor are distinguishable by type, but a small-route executor and a large-route executor are not. | Rejected: does not identify the route. |
| C. `epic-orchestrator-state.json` / `parallel-orchestrator-state.json` | These are coordinator checkpoints at the session root (`.claude/rules/orchestrator-state.md` standalone-merge section; `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:38-46`). Each epic or parallel item runs `Agent(orchestrator, isolation: "worktree")` (`.claude/skills/epic-orchestrate/SKILL.md:99`, `.claude/skills/parallel-orchestrate/SKILL.md:218`) and writes its own `orchestrator-state.json` in its own worktree. The coordinator file does not identify which item a write belongs to (see 2.3). | Rejected as primary; not needed because item orchestrators write candidate A in their own worktree. |
| D. Environment variable set by the orchestrator | A subagent cannot set the environment of hook processes launched by the runtime; Codex hooks are additionally forbidden from reading `$env:CLAUDE_*` (`tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:130-135`). | Rejected. |

### 2.2 Recommended signal and predicate

Read `<Root>/artifacts/orchestration/orchestrator-state.json`, where `<Root>` is the hook's existing root (`Split-Path (Split-Path $PSScriptRoot -Parent) -Parent` in both hooks). Treat the session as executing on the large path when all of the following hold:

1. The file exists and parses as a JSON object.
2. The selected route, resolved as the non-blank string value of `route_id`, falling back to `path_selected` only when `route_id` is absent (the rule implemented by `Get-OrchestratorStateSelectedRouteId`, `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1:184-234`, mirroring `_selected_route_id` in Python), is one of `large`, `remediation`, `preparation`.
3. The checkpoint is not terminal: `next_step` is not `complete` and `completed_steps` does not contain `S12_complete` (the same completion markers used by `.claude/hooks/enforce-completion-consistency.ps1:14-15`, `:160`).

Every other outcome (file absent, unreadable, malformed, route `small`, route blank or unknown, terminal checkpoint) is "not large path", and the hook enforces the direct-mode threshold. This fails toward the existing behavior rather than toward an unlimited allow.

Rationale for the route set: `large` is the escalation target. `remediation` is the orchestrator-owned review-triggered loop (`config/orchestration-routing.json:61-78`) with atomic planning and preflight. `preparation` exists only for epic and parallel children (`config/orchestration-routing.json:79-99`); epic children always use the orchestrator topology (`.agents/skills/codex-model-routing/SKILL.md:38-39`), and whether an epic execution child keeps `route_id: preparation` after resuming is not documented, so including it avoids denying an epic execution child. `small` is the only route whose definition is "inside the direct budget" (`config/orchestration-routing.json:5-6`). `parallel` and `epic` never appear in `orchestrator-state.json`; they are the coordinator checkpoint routes (`.claude/rules/parallel-orchestration.md:46`, `.claude/skills/epic-orchestrate/SKILL.md:287`).

Implementation note for route resolution: the Claude hook may either import `OrchestratorStateRoutingMatrix.psm1` (shipped in the core pack, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json:139`) or inline the ~10-line rule. The Codex hook cannot import `.claude/lib` (the Codex bundle does not carry it; there is no `.codex/**/*.psm1`), so it must inline the rule. Recommendation: inline a small pure function in each hook (`Test-PowerShellBatchBudgetLargePathRoute -CheckpointText`) so a module-import failure cannot turn the hook into a non-zero exit (which Claude treats as non-blocking), and keep the two hooks' semantics identical through mirrored unit tests.

### 2.3 Execution-context analysis

- **Main-session and non-isolated subagents.** Hook commands are relative paths (`.claude/settings.json:144`), so the process runs in the session's current directory; Claude Code documentation states handlers "run in the current directory" and that the payload `cwd` "is the worktree root after Claude enters a worktree". `$PSScriptRoot` resolves inside that directory, so `<Root>/artifacts/orchestration/orchestrator-state.json` is the checkpoint of the session that is writing. This is the same file the preimplementation gate reads through a cwd-relative path (`:262-265`).
- **Isolated-worktree item orchestrators (parallel/epic).** Each item orchestrator runs with `isolation: "worktree"` and writes its own `orchestrator-state.json` in that worktree. Hooks for calls made inside that worktree run the worktree's copy of the hook scripts with the worktree as the root. The item's own checkpoint is therefore co-located with the hook's root. `artifacts/` is gitignored (`.gitignore:6`), so a fresh worktree has no inherited checkpoint.
- **Isolated worktrees are built from `origin/main`.** A hook change on a feature branch is not exercised by isolated subagents until it merges. End-to-end validation must use the session worktree, not an isolated subagent.
- **Coordinator-issued calls on behalf of an item** (a process whose cwd is not the item worktree) read the coordinator root's checkpoint. For file writes this does not arise in the documented flows, because implementation writes happen inside the item worktree.

### 2.4 Failure modes of the selected signal

| Failure mode | Effect | Mitigation / residual |
|---|---|---|
| Stale non-terminal large-path checkpoint left at a root after its item moved or was abandoned | A later direct-mode session at that root is not capped | Checkpoint hygiene (issue #673, `.claude/skills/orchestrate/SKILL.md:36`) moves foreign checkpoints; the preimplementation gate has the identical exposure and accepts it. Residual risk accepted and documented. |
| Completed checkpoint left at a root | Would otherwise exempt later work | Excluded by the terminal-checkpoint condition. |
| Malformed or partially written checkpoint | Hook enforces the direct threshold | Fail toward existing behavior; the preimplementation gate would already deny the write. |
| Checkpoint route edited by an agent to `large` | Cap bypassed | Policy guard, not a security control (same position as the standalone-merge record, `.claude/rules/orchestrator-state.md`). The `route_id` must match the checkpoint's required receipts at completion (`_orchestrator_state_routing.py:162-197`), so a falsified route fails the completion validator. |
| Hook process cwd deleted mid-session | Claude Code falls back to the session start directory, project root, home, or temp (documented) | Root then resolves elsewhere; hook enforces the direct threshold or finds the session-root checkpoint. |
| Subagent in an isolated worktree without its own checkpoint | Direct threshold enforced | The preimplementation gate denies such writes anyway (no ready checkpoint). |

---

## 3. Direct-Mode Semantics

### 3.1 Behavior

- Only distinct **production** PowerShell paths are counted. Threshold: the 4th distinct production path is denied when the route is not large-path ("more than 3 production files belongs on the large path").
- **Remove the test-file cap in all modes.** Routing is decided by production files (owner direction; `powershell-change-budget-router` counts only production files, `.claude/skills/powershell-change-budget-router/SKILL.md:19-22`). A test-cap deny has no routing remedy, so it can only produce a batching instruction, which the owner has ruled out. Test paths are allowed without being recorded.
- **Remove both cap-override mechanisms** (environment `CLAUDE_POWERSHELL_BUDGET_*`, `.claude/hooks/...:426-433`; persisted `prodCap`/`testCap`, Claude `:214-215`, Codex `:77-78`). The threshold becomes a routing constant; the sanctioned way past it is routing. Keep an internal `-ProdCap` parameter (default 3) for testability only. A persisted state file carrying `prodCap`/`testCap`/`testFiles` must still load without error (ignore those keys) so existing state files do not break the hook.
- **Large path:** allow every PowerShell path without counting and without writing state.
- Unchanged: fail-closed envelope handling, out-of-root discard, containment filter on rehydrate, session-id resolution, deny-only output, the `Get-PowerShellBatchBudgetBlockDecision` function name and shape.

### 3.2 Proposed deny message

Claude hook:

```
POWERSHELL_LARGE_PATH_REQUIRED: this change touches more than 3 production PowerShell files (already counted: <a>, <b>, <c>; requested: <d>). A change of this size belongs on the orchestrated large path, which has no production-file cap. Route the change through /orchestrate. Checkpoint route observed: <route or 'none'>.
```

Codex hook: identical except the routing clause names the Codex orchestrator entry point (`.codex/prompts/orchestrate-work.md`, listed as a required bundled file in `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:67`).

The message must not contain `Split the work`, `new batch`, `raise the cap`, `CLAUDE_POWERSHELL_BUDGET`, `record an approved cap`, or `deleting`. The state-file path is no longer part of the message.

### 3.3 Threshold reconciliation

| Surface | Current | Location |
|---|---|---|
| `powershell-change-budget-router` (Claude, `.agents`, `.github`) | small `1-2`, large `>2` | `.claude/skills/powershell-change-budget-router/SKILL.md:21-22`, `:39` (same lines in `.agents/...` and `.github/...` copies) |
| `.claude/agents/orchestrator.md` | small 1-3, large 4+ | `:75-76` |
| Hook | denies the 4th production file | `.claude/hooks/...:293`, defaults `:316` |
| Codex topology resolver | PowerShell `max_production_files: 2` | `config/orchestration-routing.json:229-234`; pinned in `scripts/dev_tools/resolve_codex_topology.py:76-80`, `.claude/lib/codex-routing/CodexTopology.psm1:72`, and `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts` |
| Owner | more than 3 -> large | `issue.md:66` |

Recommendation: adopt "1-3 production files -> small/direct; more than 3 -> large path" as the single statement. In #769, update every PowerShell **text** surface on the Claude and Copilot (`.github`) runtimes, and remove the per-batch text from every runtime including Codex/`.agents`. Defer the **Codex topology resolver** value (and the Codex/`.agents` threshold text that documents it) to a required follow-up, because it is a machine-read routing contract implemented in three runtimes (Python, PowerShell, TypeScript) with parity fixtures (`tests/fixtures/codex_routing/topology.json:19-31`, `tests/scripts/dev_tools/test_resolve_codex_topology.py:23,49,71`, `extensions/drm-copilot/test/lib/validate/codex-topology-resolver.test.ts:12,35,58`, `tests/scripts/claude-lib/codex-routing/CodexTopology.Parity.Tests.ps1:41-46,186`, `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.Tests.ps1:50`). Changing it adds production Python and TypeScript to this item. In the interim the Codex runtime routes a 3-file PowerShell change to the large path, which is stricter than the policy and never produces a deny; it does not contradict "the large path has no cap".

The Claude-side router and rule name `powershell-orchestrator` (`.claude/skills/powershell-change-budget-router/SKILL.md:22`, `.claude/rules/powershell.md:39`), but no such agent exists in `.claude/agents/` (only `orchestrator.md`, `epic-orchestrator.md`, `parallel-orchestrator.md`). Claude-surface routing text should name `/orchestrate` (the `orchestrator` agent) instead.

---

## 4. Policy Surfaces to Change

Canonical policy files `.github/copilot-instructions.md` and `.github/instructions/*.instructions.md` carry no per-batch or production-file-count text (search for `batch|production files|production PowerShell` over those paths returned no matches). They are not modified.

### 4.1 Per-batch / split-into-batches text (PowerShell) — remove, replace with the routing rule

| File | Lines |
|---|---|
| `.claude/rules/powershell.md` | `:37-41` (Change Budget section: per-batch cap and "split the work into smaller batches") |
| `.claude/agents/powershell-typed-engineer.md` | `:4` (description), `:39` ("Enforce the 3 production + 3 test per-batch cap in all modes"), `:68` (stop condition) |
| `.claude/skills/invoke-powershell-engineer/SKILL.md` | `:3` (description), `:26` (`budget: prod=<N>, test=<M>` override input) |
| `.github/agents/powershell-typed-engineer.agent.md` | `:128-134` (Change budget: per-batch 3/3, split into smaller batches) |
| `.agents/skills/powershell/SKILL.md` | `:37-38` |
| `.agents/skills/invoke-powershell-engineer/SKILL.md` | `:3` ("a three-production plus three-test batch cap") |
| `.codex/agents/powershell-typed-engineer.toml` | `:32`, `:67`, `:96`; then regenerate the five variants `-c1`, `-c2`, `-c3`, `-c3-elevated`, `-c4` with `scripts/dev_tools/generate_codex_agent_variants.py` (the variants are generated from the base, `generate_codex_agent_variants.py:182-193`; drift is checked by `tests/scripts/dev_tools/test_generate_codex_agent_variants.py`) |
| `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.codex/hooks/enforce-powershell-batch-budget.ps1` | docstrings and deny messages (Section 1) |

Excluded, with reason: `.github/agents/Powershell DI Unit Test Engineer.agent.md:49-54` (a 1-production/1-test per-batch discipline for a separate unit-test agent, unrelated to the routing cap; flagged for the owner, not changed here); `.codex/agents/orchestrator*.toml:37-38` (language-generic statement that the small path applies the router's batch cap, which remains true); `.claude/skills/translate-copilot-to-claude/SKILL.md:62` (describes hook categories generically).

### 4.2 Threshold text (PowerShell `1-2` / `>2`) — change to `1-3` / `>3` in #769

| File | Lines |
|---|---|
| `.claude/skills/powershell-change-budget-router/SKILL.md` | `:21-22`, `:39` |
| `.github/skills/powershell-change-budget-router/SKILL.md` | `:21-22`, `:39` |
| `.claude/rules/powershell.md` | `:39` |
| `.claude/agents/powershell-typed-engineer.md` | `:4`, `:39`, `:49`, `:67` |
| `.claude/skills/invoke-powershell-engineer/SKILL.md` | `:3`, `:15` |
| `.github/agents/powershell-typed-engineer.agent.md` | `:52-53`, `:118-120`, `:130`, `:198` |
| `.github/agents/powershell-orchestrator.agent.md` | `:17`, `:101-102`, `:126-127`, `:131`, `:248` |
| `.github/prompts/orchestrate-powershell-work.prompt.md` | `:24`, `:26` |

Deferred to the Codex-topology follow-up (text documents the resolver and must move with it): `.agents/skills/powershell-change-budget-router/SKILL.md:21-22,39`, `.agents/skills/powershell/SKILL.md:36`, `.agents/skills/invoke-powershell-engineer/SKILL.md:3,15` (the "one-to-two" / "1-2" clauses), `.agents/skills/codex-model-routing/SKILL.md:34-36`, `.codex/agents/powershell-orchestrator.toml:32-33`, `.codex/agents/powershell-typed-engineer*.toml:32,67,77,95` (the `1-2`/`2` clauses only; the per-batch clauses are removed in #769).

### 4.3 Bundle mirrors required for every changed file

- `.claude/**` -> `extensions/drm-copilot/resources/claude-customizations/.claude/**` (bound by `test_push_down_claude_resource_contracts.py:118-143`).
- `.codex/**`, `.agents/**` -> `extensions/drm-copilot/resources/codex-and-agents-customizations/**` (bound by `test_push_down_codex_and_agents_resource_contracts.py:215-228`; hooks also by `legacy-codex-hook-contracts.Tests.ps1:114`).
- `.github/**` -> `extensions/drm-copilot/resources/customizations/.github/**` (`powershell-orchestrator.agent.md` is byte-bound by `tests/scripts/dev_tools/test_orchestrator_direct_command_contracts.py:72-85`; the other `.github` files are mirrored by convention and should be kept identical).

---

## 5. Downstream Coupling

- `local_execution_overrides`: required to be empty at completion by `scripts/dev_tools/_orchestrator_state_routing.py:592`, `scripts/dev_tools/_orchestrator_state_pr_creation_readiness.py:58`, `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1:67`, and the TypeScript port `extensions/drm-copilot/src/lib/validate/orchestrator-state-routing.ts:447`. None of these reference batch resets. No change is needed; the fix removes the reason a run would record a reset there.
- Planner and executor contracts: searches for `batch` in `.claude/skills/atomic-plan-contract/**`, `.claude/agents/atomic-*.md`, `.claude/skills/orchestrate/**`, `.claude/agents/orchestrator.md`, and the `.agents`/`.github` atomic equivalents returned no cap-related text. `powershell-qa-gate` uses "batch" only for a plan's work unit (`.claude/skills/powershell-qa-gate/SKILL.md:15`, `:76`). No planner text phases work around the 3-file cap; no change needed.
- `.claude/agents/powershell-typed-engineer.md:41` ("Implement in batches") refers to plan batches, not the cap; leave unchanged.

### 5.1 Bootstrap constraint for this item's own execution

This item changes four production `.ps1` files (two hooks and their two bundle copies), which is more than the current hook allows. Because the session runs the worktree's own hook file, the atomic plan must modify `.claude/hooks/enforce-powershell-batch-budget.ps1` first; subsequent writes are then evaluated by the corrected hook, which reads this item's `route_id: large` and allows them. The plan must not rely on deleting the state file. Separately, the preimplementation gate requires `lifecycle_ready: true` in the checkpoint before any `.ps1` write (`enforce-orchestration-preimplementation-gate.ps1:241-247`); the current checkpoint does not yet carry it.

---

## 6. Scope Boundary — Follow-ups (not changed in #769)

**Follow-up 1: Python and C# budget hooks and text** (same pattern):
- Hooks: `.claude/hooks/enforce-python-batch-budget.ps1` (`:293` message), `.codex/hooks/enforce-python-batch-budget.ps1` (`:137`), both bundle copies.
- Tests: `tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1` (`:75-95`, `:228`), the Python context of `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`, `legacy-codex-hook-contracts.Tests.ps1:227-231`.
- Text: `python-change-budget-router` (`.claude`, `.agents`), `invoke-python-engineer` (`.claude`, `.agents`), `.claude/agents/python-typed-engineer.md:4,40`, `.github/agents/python-typed-engineer.agent.md:61-78`, `.codex/agents/python-typed-engineer*.toml:32,68`; `csharp-change-budget-router` (`.claude`, `.agents`) `:63-65`, `.claude/agents/csharp-typed-engineer.md:35`, `.github/agents/csharp-typed-engineer.agent.md:128-130`, `.codex/agents/csharp-typed-engineer*.toml:64`, and the csharp-legacy variants under `extensions/.../.claude-variants/` and `.codex-variants/`; plus all bundle mirrors.

**Follow-up 2: Codex topology PowerShell budget 2 -> 3** (Section 3.3): `config/orchestration-routing.json:229-234` and its copies `extensions/drm-copilot/resources/config/orchestration-routing.json`, `extensions/drm-copilot/resources/claude-customizations/config/orchestration-routing.json`; `scripts/dev_tools/resolve_codex_topology.py:76-80`; `.claude/lib/codex-routing/CodexTopology.psm1:72` and its two bundle copies; `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts`; the fixtures and tests listed in 3.3; the Codex/`.agents` threshold text listed in 4.2.

---

## 7. Recommended Implementation Approach

1. **Claude hook** (edit first; see 5.1). Add a pure `Test-PowerShellBatchBudgetLargePathRoute -CheckpointText` (route resolution per 2.2, terminal exclusion, parse failure -> `$false`). Add a `[scriptblock] $ReadCheckpoint` seam to `Invoke-PowerShellBatchBudgetHook` whose default reads `Join-Path $Root 'artifacts/orchestration/orchestrator-state.json'` when it exists and returns `''` otherwise. Add `[switch] $LargePathRoute` (default off) to `Invoke-PowerShellBatchBudgetDecision`: when set, allow without counting or writing state. Test paths: allow without counting. Remove the test cap, the environment override, and the persisted cap override; ignore legacy keys on load. Replace the deny message (3.2). Update the docstring. Keep `Get-PowerShellBatchBudgetBlockDecision` unchanged. Measure the line count after the change; the removals (test-cap branch, env override block `:426-433`, docstring lines) should offset the additions and keep the file under 500 lines. If it would exceed 500, move the route predicate and checkpoint reader to a dot-sourced sibling (`enforce-powershell-batch-budget-route.ps1`, following the `enforce-orchestration-preimplementation-gate-helpers.ps1` precedent) and add it to `pack-manifests/powershell.json`, the bundle, and `pester.runsettings.psd1`.
2. **Codex hook**: same semantics with an inlined route predicate; no `$env:CLAUDE_` reads; checkpoint under `$repositoryRoot` (`:228`); Codex routing clause in the message.
3. **Bundle copies** of both hooks, byte-identical.
4. **Text surfaces** in 4.1 and 4.2, then regenerate Codex variants and mirror every changed file into its bundle.
5. **Follow-ups**: record Follow-up 1 and Follow-up 2 as potential entries.

Rejected alternatives: keying on `agent_type` (does not identify the route, 2.1-B); resetting counts at phase boundaries (retains a batching model the owner rejected); raising the cap for orchestrated runs (retains a cap on the large path, which the owner rejected).

---

## 8. Proposed File List

Production (PowerShell code, 4): `.claude/hooks/enforce-powershell-batch-budget.ps1`; `.codex/hooks/enforce-powershell-batch-budget.ps1`; `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1`.

Policy/documentation surfaces: every file in 4.1 and 4.2, the five regenerated Codex variants, and the bundle mirror of each (4.3).

Tests:
- New: `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` (the existing suite is at 495 lines).
- New: `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1`.
- Modified: `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1` (replace the test-cap deny case `:98-107` and the message assertions `:85-96`; adjust `:484-493`, which names the removed environment variables).
- Modified: `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1` (move the PowerShell row out of the shared `-ForEach` or make the cap-override, test-cap, and `state.json` message expectations language-specific; the Python row is unchanged).
- Unchanged, re-run: `legacy-codex-hook-contracts.Tests.ps1`, `PreToolUseSchema.Contract.Tests.ps1`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_orchestrator_direct_command_contracts.py`, `test_generate_codex_agent_variants.py`.

---

## 9. Proposed Acceptance Criteria

1. With no checkpoint, or a checkpoint whose route is `small`, the 4th distinct production PowerShell path is denied; the reason begins `POWERSHELL_LARGE_PATH_REQUIRED`, names `/orchestrate` (Claude) or the Codex orchestrator entry (Codex), and contains none of `Split the work`, `new batch`, `raise the cap`, `CLAUDE_POWERSHELL_BUDGET`, `record an approved cap`, `deleting`.
2. With a non-terminal checkpoint whose route (`route_id`, falling back to `path_selected` only when `route_id` is absent) is `large`, `remediation`, or `preparation`, no PowerShell path is denied for count at any number of distinct production files, and no state is written for those paths.
3. A checkpoint with `next_step: "complete"` or `S12_complete` in `completed_steps`, a malformed checkpoint, and a blank or unknown route each yield direct-mode enforcement.
4. Test PowerShell paths are never denied for count in either mode.
5. `CLAUDE_POWERSHELL_BUDGET_PROD`/`_TEST` and persisted `prodCap`/`testCap` no longer change the threshold; a legacy state file containing those keys and `testFiles` loads without error.
6. Existing behaviors hold: fail-closed envelope deny, out-of-root discard, repeated-path allow, deny-only entry-point output, `Get-PowerShellBatchBudgetBlockDecision` deny shape.
7. A repository search for the per-batch wording (`per-batch`, `batch cap`, `smaller batches`, `split the work`, `three-test`) in PowerShell-scoped files under `.claude/`, `.agents/`, `.codex/`, and `.github/agents/powershell-typed-engineer.agent.md` returns no match (excluding the Section 4.1 exclusions).
8. Claude and Copilot PowerShell routing text states `1-3` production files for the small/direct path and more than 3 for the large path; Claude-side text names `/orchestrate`.
9. Bundle parity, pack-manifest completeness, Codex-variant drift, and the 500-line cap tests pass.
10. Follow-up 1 and Follow-up 2 are recorded as potential entries.
11. PoshQC format -> analyze -> test pass with no coverage regression on changed lines of both hooks.

Criteria 7 and 8 are stated as searches, not counts, for the reason given in the Numeric Derivation Evidence section.

---

## 10. Testing Implications

Pester v5, no temporary files (`.claude/rules/general-unit-test.md`). Drive the checkpoint through the `ReadCheckpoint` seam with in-memory JSON strings; drive state through the existing `TestPathExists`/`ReadState`/`WriteState` seams. Cover: route table (`large`, `remediation`, `preparation`, `small`, blank, missing key, `route_id` present-but-null with `path_selected: large` -> not large, `path_selected` only), terminal markers, malformed JSON, missing file, 4th-file deny text (positive and negative substrings), test-path pass-through, legacy state keys ignored, and the Codex entry point with a `Write` payload whose mapped path is a production `.ps1` under a large-route checkpoint (via the seam, not the filesystem). Run the Codex and Claude suites plus the parity tests listed in Section 8. Validate end-to-end in the session worktree, not through an isolated subagent (isolated worktrees load `origin/main`'s hooks).

---

## Numeric Derivation Evidence

No numeric count is proposed for any acceptance criterion. The enumerations in Section 4 are reported as union sets because the independent searches disagreed; the disagreement is recorded below so the planner does not convert either list into a count.

### Family A — PowerShell per-batch / batch-cap text surfaces

- **Complete Family:** tracked, non-bundle, non-test, non-`docs/` files scoped to PowerShell routing (typed engineer, its invoke skill, the PowerShell rule/skill, the two batch-budget hooks) that state a per-batch or batch cap or instruct splitting into batches.
- **Exhaustive Search Scope:** repository root, excluding `docs/**`, `testResults.xml`, `artifacts/**`, `virtual/**`, `extensions/**`, `node_modules/**`, `tests/**`.
- **Inclusion Rules:** file is PowerShell-scoped and the matching text refers to the typed-engineer/hook production-and-test cap.
- **Exclusion Rules:** `.github/agents/Powershell DI Unit Test Engineer.agent.md` (separate unit-test agent budget); `.codex/agents/orchestrator*.toml` (language-generic); Python and C# files (out of scope).
- **Primary Search Strategy or Query Expression:** `(?i)per-batch|smaller batches|split the work|new batch|3 production files|three production`
- **Primary Member Set:** `.claude/hooks/enforce-powershell-batch-budget.ps1`, `.codex/hooks/enforce-powershell-batch-budget.ps1`, `.claude/rules/powershell.md`, `.claude/agents/powershell-typed-engineer.md`, `.claude/skills/invoke-powershell-engineer/SKILL.md`, `.github/agents/powershell-typed-engineer.agent.md`, `.agents/skills/powershell/SKILL.md`, `.codex/agents/powershell-typed-engineer.toml`, `-c1.toml`, `-c2.toml`, `-c3.toml`, `-c3-elevated.toml`, `-c4.toml`
- **Primary Count:** 13
- **Cross-check Search Strategy or Query Expression:** `(?i)batch cap|batch budget|per batch|three-test|three-production|split .{0,20}batch`
- **Cross-check Member Set:** the 13 primary members plus `.agents/skills/invoke-powershell-engineer/SKILL.md`
- **Cross-check Count:** 14
- **Member-set Comparison:** disagree. The primary expression misses `.agents/skills/invoke-powershell-engineer/SKILL.md:3`, which words the cap as "a three-production plus three-test batch cap". The union (14) is the working set for Section 4.1. A numeric assertion is withheld; AC 7 is a zero-match search instead.

### Family B — PowerShell `1-2` / `>2` threshold text surfaces

- **Complete Family:** tracked, non-bundle, non-test, non-`docs/` text files that state the PowerShell direct/small budget as 2 production files.
- **Exhaustive Search Scope:** same as Family A.
- **Inclusion Rules:** PowerShell-scoped routing or budget text.
- **Exclusion Rules:** machine-read code and config (`config/orchestration-routing.json`, `scripts/dev_tools/resolve_codex_topology.py`, `.claude/lib/codex-routing/CodexTopology.psm1`, `.codex/scripts/Resolve-CodexTopology.ps1`), which belong to Follow-up 2; `.github/agents/Powershell DI Unit Test Engineer.agent.md`; unrelated `1-2`/`1–2` uses (minutes, sentences, bats arguments).
- **Primary Search Strategy or Query Expression:** `(?i)(\b1-2\b|1–2|>2\b|up to \*{0,2}2\b|exceeds? \*{0,2}2\b|2-production|2 production|2-file|allows up to 2)`
- **Primary Member Set:** `.claude/skills/powershell-change-budget-router/SKILL.md`, `.claude/rules/powershell.md`, `.claude/skills/invoke-powershell-engineer/SKILL.md`, `.claude/agents/powershell-typed-engineer.md`, `.github/skills/powershell-change-budget-router/SKILL.md`, `.github/agents/powershell-typed-engineer.agent.md`, `.github/agents/powershell-orchestrator.agent.md`, `.github/prompts/orchestrate-powershell-work.prompt.md`, `.agents/skills/powershell-change-budget-router/SKILL.md`, `.agents/skills/powershell/SKILL.md`, `.agents/skills/invoke-powershell-engineer/SKILL.md`, `.agents/skills/codex-model-routing/SKILL.md`, `.codex/agents/powershell-orchestrator.toml`, `.codex/agents/powershell-typed-engineer.toml`, `-c1.toml`, `-c2.toml`, `-c3.toml`, `-c3-elevated.toml`, `-c4.toml`
- **Primary Count:** 19
- **Cross-check Search Strategy or Query Expression:** `(?i)(one-to-two|two production|\b2\b[^0-9\n]{0,25}production|production[^0-9\n]{0,25}\b2\b|"max_production_files": 2)`
- **Cross-check Member Set:** the primary members except `.agents/skills/codex-model-routing/SKILL.md` (its "production files, and PowerShell allows up to 2" places more than 25 characters between the tokens), plus the excluded code/config files.
- **Cross-check Count:** 18 text members (after exclusions)
- **Member-set Comparison:** disagree by one member (`.agents/skills/codex-model-routing/SKILL.md`). The union (19) is the working set; Section 4.2 splits it between #769 (8 Claude/Copilot files) and Follow-up 2 (the Codex/`.agents` files). A numeric assertion is withheld; AC 8 is phrased as a content requirement.

---

## Automation Feasibility

Fully automatable. Every change is a file edit plus deterministic regeneration (`generate_codex_agent_variants.py`) and byte-copy mirroring into the extension bundle. Verification uses existing PoshQC MCP tools and existing Pytest parity suites; the new behavior is unit-testable through injected seams with in-memory checkpoint text, so no live orchestration run, network access, or manual step is required. The only ordering constraint is the bootstrap in 5.1 (edit the Claude hook before the other PowerShell files).
