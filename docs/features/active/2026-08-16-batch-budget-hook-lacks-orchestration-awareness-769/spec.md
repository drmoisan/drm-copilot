# batch-budget-hook-lacks-orchestration-awareness (Spec)

- **Issue:** #769
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T13-50
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug
- **Research:** `docs/features/active/2026-08-16-batch-budget-hook-lacks-orchestration-awareness-769/research/2026-09-29T13-35-batch-budget-routing-research.md`

## Context

`.claude/hooks/enforce-powershell-batch-budget.ps1` enforces a direct-mode file cap against every session, including sessions already executing on the orchestrated large path. The cap exists to route over-budget work to the orchestrator. Once that routing has happened, continuing to enforce the cap denies the path the policy prescribes.

Owner-confirmed intent (2026-09-29, authoritative, recorded in `issue.md`): the hook exists to signal that a change touching more than 3 production PowerShell files belongs on the large-path orchestrator (`/orchestrate`). The large path has no cap on the number of files it may touch. Any instruction to split work into batches contradicts that purpose and must be removed.

Environment:
- OS/version: Windows 11 Pro 10.0.26200
- Command/flags used: any `Write`/`Edit` of a `.ps1`/`.psm1`/`.psd1` file inside an orchestrated run
- Data source or fixture: `.claude/state/powershell-batch-budget.<session_id>.json`

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

Any orchestrated PowerShell change exceeding three production files hits this. That is the class of change the large path exists to handle, so the hook is most obstructive where it should be inert. The available workaround requires an agent to delete enforcement state, which reads as a bypass to a reviewer without context and invites genuine bypasses to be rationalized the same way.

## Repro & Evidence

Steps to Reproduce:
1. Start a full orchestration (`/orchestrate`) for work that legitimately requires more than three production PowerShell files.
2. Let the orchestrator complete promotion, research, feature documents, atomic planning, and preflight, then begin execution.
3. Observe the hook deny the 4th distinct production PowerShell path, regardless of how the plan phases the work.

Expected:
The cap is a routing gate, not a chunking rule. Outside the large path, the 4th distinct production PowerShell file is denied with an instruction to route the change through `/orchestrate`. On the large path, no PowerShell write is denied for file count.

Actual:
The hook contains no reference to orchestration, routes, or checkpoints. State is keyed on the session id; subagents inherit the parent session id, so the count accumulates across an entire orchestration and never resets. In the issue-475 run (roughly 25 production and 20 test PowerShell files), the hook denied the 4th distinct production path during Phase 3 of 17, after the run had already been routed to the large path. The run's workaround was to delete the state file at each phase boundary, one of the remedies the deny message itself names.

Current deny message (`.claude/hooks/enforce-powershell-batch-budget.ps1:296`):

```
PowerShell per-batch budget exceeded: $kind file cap is $cap and is already full ($currentFiles). Requested new file: $normalized. Split the work into a new batch, raise the cap via CLAUDE_POWERSHELL_BUDGET_$kindUpper environment variable with approved scope, or reset the batch by deleting $StateFile.
```

The Codex hook (`.codex/hooks/enforce-powershell-batch-budget.ps1:139`) carries an equivalent message that offers "Split the work into a new batch, record an approved cap in $StateFile, or reset the batch by deleting that state file."

## Scope & Non-Goals

### In scope

1. **Claude hook** `.claude/hooks/enforce-powershell-batch-budget.ps1`: large-path awareness, routing deny message, removal of the test-file cap and both cap-override mechanisms, docstring update.
2. **Codex hook** `.codex/hooks/enforce-powershell-batch-budget.ps1`: the same semantics with an inlined route predicate and a Codex routing clause.
3. **Extension-bundled mirrors** of both hooks, byte-identical to the repository copies:
   - `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-powershell-batch-budget.ps1`
   - `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-powershell-batch-budget.ps1`
4. **Per-batch text removal** (research Section 4.1), replaced with the routing rule, on every PowerShell surface in every runtime:
   - `.claude/rules/powershell.md` (Change Budget section)
   - `.claude/agents/powershell-typed-engineer.md` (description, Routing and scope step, stop condition)
   - `.claude/skills/invoke-powershell-engineer/SKILL.md` (description; the `budget: prod=<N>, test=<M>` override input)
   - `.github/agents/powershell-typed-engineer.agent.md` (Change budget section)
   - `.agents/skills/powershell/SKILL.md`
   - `.agents/skills/invoke-powershell-engineer/SKILL.md` (description)
   - `.codex/agents/powershell-typed-engineer.toml` (description, Routing and scope step, stop condition), followed by regeneration of every generated variant with `scripts/dev_tools/generate_codex_agent_variants.py`
5. **Threshold text reconciliation** (research Section 4.2) on Claude and Copilot surfaces: every PowerShell routing statement reads "1-3 production files -> small/direct path; more than 3 -> large path":
   - `.claude/skills/powershell-change-budget-router/SKILL.md`
   - `.github/skills/powershell-change-budget-router/SKILL.md`
   - `.claude/rules/powershell.md`
   - `.claude/agents/powershell-typed-engineer.md`
   - `.claude/skills/invoke-powershell-engineer/SKILL.md`
   - `.github/agents/powershell-typed-engineer.agent.md`
   - `.github/agents/powershell-orchestrator.agent.md`
   - `.github/prompts/orchestrate-powershell-work.prompt.md`
6. **Escalation target naming on Claude surfaces**: routing instructions in `.claude/skills/powershell-change-budget-router/SKILL.md`, `.claude/rules/powershell.md`, `.claude/agents/powershell-typed-engineer.md`, and `.claude/skills/invoke-powershell-engineer/SKILL.md` name `/orchestrate` (the `orchestrator` agent) instead of `powershell-orchestrator`, which does not exist in `.claude/agents/`. Copilot (`.github`) surfaces keep `powershell-orchestrator`, which exists there as `.github/agents/powershell-orchestrator.agent.md`.
7. **Bundle mirrors** of every changed text file (research Section 4.3):
   - `.claude/**` -> `extensions/drm-copilot/resources/claude-customizations/.claude/**`
   - `.codex/**`, `.agents/**` -> `extensions/drm-copilot/resources/codex-and-agents-customizations/**`
   - `.github/**` -> `extensions/drm-copilot/resources/customizations/.github/**`
8. **Tests**: new routing suites for both hooks and updates to existing suites that assert removed behavior (see Test Strategy).
9. **Follow-up records**: the two follow-ups listed below are recorded as potential entries under `docs/features/potential/`.

### Out of scope / non-goals (follow-ups to be filed)

- **Follow-up 1 — Python and C# budget hooks and text.** `.claude/hooks/enforce-python-batch-budget.ps1`, `.codex/hooks/enforce-python-batch-budget.ps1`, their bundle copies and tests; `python-change-budget-router`, `invoke-python-engineer`, `python-typed-engineer` text on every runtime; `csharp-change-budget-router` and `csharp-typed-engineer` text on every runtime, including the csharp-legacy variants under `extensions/.../.claude-variants/` and `.codex-variants/`. These follow the same session-keyed pattern (research Section 6).
- **Follow-up 2 — Codex routing resolver PowerShell budget of 2.** `config/orchestration-routing.json` (`max_production_files: 2` for PowerShell) and its bundled copies, `scripts/dev_tools/resolve_codex_topology.py`, `.claude/lib/codex-routing/CodexTopology.psm1` and its bundle copies, `extensions/drm-copilot/src/lib/validate/codex-topology-resolver.ts`, the parity fixtures and tests, and the Codex/`.agents` threshold text that documents the resolver value (`.agents/skills/powershell-change-budget-router/SKILL.md`, the `1-2`/"one-to-two" clauses in `.agents/skills/powershell/SKILL.md` and `.agents/skills/invoke-powershell-engineer/SKILL.md`, `.agents/skills/codex-model-routing/SKILL.md`, `.codex/agents/powershell-orchestrator.toml`, and the `1-2`/`2` clauses in `.codex/agents/powershell-typed-engineer*.toml`). This is a machine-read routing contract implemented in Python, PowerShell, and TypeScript with parity fixtures. In the interim, the Codex runtime routes a 3-file PowerShell change to the large path, which is stricter than the policy and never produces a deny.

### Explicitly excluded systems, integrations, or files

- `.github/copilot-instructions.md` and `.github/instructions/*` are not modified. They carry no per-batch or production-file-count text.
- `.github/agents/Powershell DI Unit Test Engineer.agent.md`: its 1-production/1-test discipline belongs to a separate unit-test agent and is unrelated to the routing cap. Flagged for the owner; not changed.
- `.codex/agents/orchestrator*.toml`: language-generic statement that the small path applies the router's cap, which remains accurate.
- `.claude/skills/translate-copilot-to-claude/SKILL.md`: describes hook categories generically.
- `.claude/agents/powershell-typed-engineer.md` "Implement in batches": refers to plan work units, not the cap.
- `.claude/skills/powershell-orchestration-state-machine/SKILL.md` and `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`: their `powershell-orchestrator-state.json` references are checkpoint file names, not routing instructions.
- `local_execution_overrides` validators (Python, PowerShell, TypeScript): no change. The fix removes the reason a run would record a batch reset there.

## Root Cause Analysis

The hook implements the numeric half of the change-budget contract without the routing half. `powershell-change-budget-router` frames the threshold as a decision with two outcomes: proceed in direct mode, or escalate to the orchestrator. The hook implements only "deny past N", which is correct for a direct-mode session and wrong for a session already on the large path. Because the deny message offers batching, cap-raising, and state-deletion remedies, and the PowerShell policy text instructs "split the work into smaller batches" under a "per-batch cap in all modes", the repository's own guidance directs agents toward the chunking model the owner has ruled out.

A downstream consequence: the issue-475 run recorded its state resets under the checkpoint's `local_execution_overrides`, which must be empty before PR creation. No cap was raised and no policy was overridden, but the hook offered no orchestrated-run vocabulary for the situation.

## Proposed Fix

### Design summary (what changes where)

The approach follows research Section 7 without deviation.

- Both hooks read the orchestration checkpoint at `<Root>/artifacts/orchestration/orchestrator-state.json` and decide whether the session is on the large path.
- **Large path:** every PowerShell path is allowed without counting and without writing state, at any file count.
- **Direct mode (not large path):** only distinct production PowerShell paths are counted. The 4th distinct production path is denied with a routing instruction. Test paths are allowed and not counted.
- The environment cap override and the persisted cap override are removed. The threshold is a routing constant; routing is the only sanctioned way past it.
- Policy text drops the per-batch model and states the routing rule with the reconciled threshold.

### Large-path detection signal

Signal: `<Root>/artifacts/orchestration/orchestrator-state.json`, where `<Root>` is the hook's existing root (`Split-Path (Split-Path $PSScriptRoot -Parent) -Parent` in the Claude hook; `$repositoryRoot` in the Codex hook).

The session is on the large path only when all of the following hold:

1. The file exists and parses as a JSON object.
2. The selected route is one of `large`, `remediation`, `preparation`.
3. The checkpoint is not terminal: `next_step` is not `complete`, and `completed_steps` does not contain `S12_complete`.

Precedence rule for the selected route (mirrors `Get-OrchestratorStateSelectedRouteId` in `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1` and `_selected_route_id` in Python):

- When the `route_id` key is present, its value is the selected route. It is usable only when it is a non-blank string. A present-but-null, non-string, or blank `route_id` yields no route; `path_selected` is not consulted.
- When the `route_id` key is absent, `path_selected` is used under the same non-blank-string rule.

Route set rationale: `large` is the escalation target; `remediation` is the orchestrator-owned review loop with atomic planning and preflight; `preparation` exists only for epic and parallel children, which always use the orchestrator topology. `small` is the only route defined as inside the direct budget. `parallel` and `epic` do not appear in `orchestrator-state.json`.

Fail-safe behavior: every other outcome yields direct-mode enforcement. This includes a missing file, an unreadable file, malformed or non-object JSON, route `small`, a blank or unknown route, and a terminal checkpoint. The hook fails toward the existing deny behavior, never toward an unlimited allow.

Execution context (research Section 2.3):

- Main session and non-isolated subagents: hook commands are relative, so the hook's root is the session's worktree and the checkpoint read is that session's checkpoint.
- Isolated-worktree item orchestrators (parallel/epic): each item writes its own `orchestrator-state.json` in its own worktree, and hooks for calls in that worktree run that worktree's hook copy with that worktree as root. `artifacts/` is gitignored, so a fresh worktree inherits no checkpoint.
- Isolated worktrees are created from `origin/main`, so this change is not exercised by isolated subagents until it merges.

Rejected signals: `agent_type`/`agent_id` on the envelope (an `atomic-executor` writes on both small and large routes, so identity does not identify the route); coordinator checkpoints (`epic-orchestrator-state.json`, `parallel-orchestrator-state.json`), which do not identify the item; an orchestrator-set environment variable (subagents cannot set hook-process environment, and Codex hooks must not read `$env:CLAUDE_*`). Rejected remedies: resetting counts at phase boundaries and raising the cap for orchestrated runs, both of which retain a cap or batching model on the large path.

### Known limitations

- **Stale non-terminal large-path checkpoint.** A checkpoint left at a root after its work moved or was abandoned exempts a later direct-mode session at that root. Mitigation: orchestrator checkpoint hygiene (issue #673, `.claude/skills/orchestrate/SKILL.md`) moves foreign checkpoints aside. The preimplementation gate has the same exposure. Residual risk is accepted and documented in the hook docstring.
- **Agent-edited route.** An agent could set `route_id` to `large` to bypass the cap. This is a policy guard, not a security control. A falsified route fails the completion validator, which requires the route's receipts.
- **Hook process cwd deleted mid-session.** The runtime falls back to another directory; the root then resolves elsewhere and the hook either enforces direct mode or reads that root's checkpoint.

### Boundaries and invariants to preserve

- Fail-closed deny on an unreadable envelope (`Resolve-ClaudeHookToolInput` anomaly).
- Allow when no `file_path` is present or the extension is not PowerShell.
- Out-of-root candidates are allowed without consuming a slot or writing state; the containment filter on rehydrate is unchanged.
- Test vs production classification regex is unchanged: `(^|/)tests/.*\.ps1$` or `\.Tests\.ps1$` is test.
- A previously counted production path is allowed without a state write.
- Session-id resolution order is unchanged.
- Entry-point output is deny-only and strips `state`.
- `Get-PowerShellBatchBudgetBlockDecision` keeps its name, parameters, and deny shape.
- Codex hook reads no `$env:CLAUDE_*` variables.
- Repository and bundle copies remain byte-identical.
- No production or test file exceeds 500 lines.

### Dependencies or blocked work

- **Bootstrap ordering.** This item changes more than 3 production PowerShell files. The session runs the worktree's own hook, so the plan must modify `.claude/hooks/enforce-powershell-batch-budget.ps1` first. Subsequent writes are then evaluated by the corrected hook, which reads this item's `route_id: large` and allows them. The plan must not rely on deleting the state file.
- The preimplementation gate requires `lifecycle_ready: true` in the checkpoint before any `.ps1` write.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

- Hooks and their bundle copies (In scope items 1-3).
- Text surfaces and their bundle copies (In scope items 4-7).
- Tests (Test Strategy).
- If the Claude hook would exceed 500 lines, move the route predicate and checkpoint reader to a dot-sourced sibling `.claude/hooks/enforce-powershell-batch-budget-route.ps1` (following the `enforce-orchestration-preimplementation-gate-helpers.ps1` precedent) and add it to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/powershell.json`, the bundle, and both `pester.runsettings.psd1` coverage lists.

#### Functions/classes/CLI commands impacted

- New pure function in each hook: `Test-PowerShellBatchBudgetLargePathRoute -CheckpointText <string>` returns `[bool]`. It implements the detection predicate, route precedence, terminal exclusion, and returns `$false` on any parse failure. The function is inlined in each hook; the Claude hook does not import `OrchestratorStateRoutingMatrix.psm1` (a module-import failure would produce a non-zero exit, which the runtime treats as non-blocking), and the Codex bundle cannot carry `.claude/lib`.
- `Invoke-PowerShellBatchBudgetHook` (Claude) and the Codex entry point: add a `[scriptblock] $ReadCheckpoint` seam. The default reads `Join-Path $Root 'artifacts/orchestration/orchestrator-state.json'` when it exists and returns `''` otherwise.
- `Invoke-PowerShellBatchBudgetDecision`: add `[switch] $LargePathRoute` (default off). When set, allow without counting or writing state. Keep an internal `-ProdCap` parameter (default 3) for testability only; remove the test-cap parameter's effect.
- Removed: the `CLAUDE_POWERSHELL_BUDGET_PROD`/`_TEST` block in the Claude entry point; the persisted `prodCap`/`testCap` overlay in both hooks.

#### Data flow and validation changes

- Entry point resolves the envelope, then reads checkpoint text via the seam, evaluates `Test-PowerShellBatchBudgetLargePathRoute`, and passes the result to the decision function.
- State files written after this change carry only production paths. A legacy state file containing `prodCap`, `testCap`, or `testFiles` loads without error; those keys are ignored.

#### Error handling and logging updates

- Checkpoint read or parse failures are not errors; they yield direct-mode enforcement. The hook must not exit non-zero because of checkpoint content.
- Deny message (Claude):

  ```
  POWERSHELL_LARGE_PATH_REQUIRED: this change touches more than 3 production PowerShell files (already counted: <a>, <b>, <c>; requested: <d>). A change of this size belongs on the orchestrated large path, which has no production-file cap. Route the change through /orchestrate. Checkpoint route observed: <route or 'none'>.
  ```

- Deny message (Codex): identical except the routing clause names the Codex orchestrator entry point `.codex/prompts/orchestrate-work.md` in place of `/orchestrate`.
- Neither message contains `Split the work`, `new batch`, `raise the cap`, `CLAUDE_POWERSHELL_BUDGET`, `record an approved cap`, or `deleting`, and neither includes the state-file path.

#### Rollback/feature-flag considerations

No feature flag. Rollback is a revert of the hook files, their bundle copies, and the text surfaces. No data migration is involved.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

- Input: PreToolUse envelope (unchanged) plus checkpoint JSON text (new, read-only).
- Output: deny JSON only on deny (unchanged shape); reason text as above.

#### Required configuration keys and defaults

- Checkpoint keys read: `route_id`, `path_selected`, `next_step`, `completed_steps`.
- Direct-mode production threshold: 3 (a 4th distinct production path is denied). Not configurable at runtime.
- Removed configuration: `CLAUDE_POWERSHELL_BUDGET_PROD`, `CLAUDE_POWERSHELL_BUDGET_TEST`, persisted `prodCap`/`testCap`.

#### Backward-compatibility expectations

- Existing state files load without error.
- `Get-PowerShellBatchBudgetBlockDecision` contract (`PreToolUseSchema.Contract.Tests.ps1`) is unchanged.
- Hook registration in `.claude/settings.json` and `.codex/config.toml` is unchanged; the state-file name is unchanged.
- The `budget: prod=<N>, test=<M>` input of `invoke-powershell-engineer` is removed.

#### Performance constraints

One additional small file read per PowerShell `Write`/`Edit`. No measurable latency requirement beyond the existing hook timeout.

## Assumptions, Constraints, Dependencies

- Assumptions: the orchestrator writes `route_id` (or `path_selected`) before any implementation write, as the preimplementation gate already requires; hook processes run with the session's worktree as the directory containing `.claude/`.
- Constraints: no production or test file exceeds 500 lines; the existing Claude test suite is at 495 lines, so new cases go in a new file; tests must not create temporary files; Codex hooks must not read `$env:CLAUDE_*`.
- External dependencies: none.

## Data / API / Config Impact

- User-facing changes: the deny message text and code; removal of the environment and persisted cap overrides; removal of the test-file cap; removal of the `budget:` override input from `invoke-powershell-engineer`.
- Data or migration: none; legacy state keys are ignored.
- Logging/telemetry: none beyond the deny reason.
- Compatibility notes: hook registration, state-file name, and `Get-PowerShellBatchBudgetBlockDecision` are unchanged.

## Test Strategy

Framework: Pester v5 through PoshQC. No temporary files: the checkpoint is supplied through the `ReadCheckpoint` seam as in-memory JSON strings, and state through the existing `TestPathExists`/`ReadState`/`WriteState` seams.

- Regression tests to add:
  - `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` (new).
  - `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` (new).
- Tests to update:
  - `tests/scripts/claude-hooks/enforce-powershell-batch-budget.Tests.ps1`: replace the test-cap deny case and the per-batch message assertions; adjust the case that sets `CLAUDE_POWERSHELL_BUDGET_PROD/TEST`.
  - `tests/scripts/codex-hooks/codex-batch-budget-hooks.Tests.ps1`: make the PowerShell row's cap-override, test-cap, and `state.json` message expectations language-specific or move the row out of the shared `-ForEach`; the Python row is unchanged.
- Cases required in both new suites (mirrored so the two hooks' semantics stay identical):
  - Route table: `large`, `remediation`, `preparation` -> large path; `small`, blank, unknown, missing key -> direct; `route_id` present-but-null with `path_selected: large` -> direct; `path_selected` only (`route_id` absent) with `large` -> large path.
  - Terminal markers: `next_step: "complete"`; `S12_complete` in `completed_steps`.
  - Malformed JSON, non-object JSON, and empty checkpoint text -> direct.
  - Direct mode: first three distinct production paths allowed; 4th denied with the required prefix, routing target, and none of the prohibited substrings; repeated path allowed.
  - Large path: production paths beyond the threshold allowed and no state written.
  - Test paths allowed and not recorded in either mode.
  - Legacy state file with `prodCap`, `testCap`, `testFiles` loads without error and does not change the threshold; `CLAUDE_POWERSHELL_BUDGET_*` set in the test scope does not change the Claude threshold.
  - Codex entry point with a `Write` payload whose mapped path is a production `.ps1` under a large-route checkpoint, via the seam.
- Re-run unchanged suites: `legacy-codex-hook-contracts.Tests.ps1`, `PreToolUseSchema.Contract.Tests.ps1`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_orchestrator_direct_command_contracts.py`, `test_generate_codex_agent_variants.py`.
- Coverage: line coverage >= 85% for both hooks; no regression on changed lines. PowerShell is exempt from the branch-coverage threshold.
- Toolchain: PoshQC format -> analyze -> test for PowerShell; Pytest for the parity suites.
- Manual validation: end-to-end validation runs in the session worktree, not through an isolated subagent, because isolated worktrees load `origin/main` hooks.

## Acceptance Criteria

- [ ] AC-1: In direct mode (no checkpoint, or a checkpoint whose selected route is `small`), the Claude hook allows the first three distinct production PowerShell paths and denies the 4th; the deny reason begins `POWERSHELL_LARGE_PATH_REQUIRED` and names `/orchestrate`.
- [ ] AC-2: In direct mode, the Codex hook denies the 4th distinct production PowerShell path; the deny reason begins `POWERSHELL_LARGE_PATH_REQUIRED` and names `.codex/prompts/orchestrate-work.md`.
- [ ] AC-3: Neither hook's deny reason contains `Split the work`, `new batch`, `raise the cap`, `CLAUDE_POWERSHELL_BUDGET`, `record an approved cap`, `deleting`, or the state-file path; asserted by unit tests for both hooks.
- [ ] AC-4: With a non-terminal checkpoint whose selected route is `large`, `remediation`, or `preparation`, neither hook denies any PowerShell path for file count at any number of distinct production files, and neither hook writes state for those paths.
- [ ] AC-5: Route precedence is `route_id` when the key is present and `path_selected` only when `route_id` is absent; a present-but-null or blank `route_id` with `path_selected: large` yields direct-mode enforcement in both hooks.
- [ ] AC-6: A missing checkpoint, a malformed or non-object checkpoint, a blank or unknown route, a checkpoint with `next_step: "complete"`, and a checkpoint with `S12_complete` in `completed_steps` each yield direct-mode enforcement in both hooks, and no checkpoint condition causes a non-zero hook exit.
- [ ] AC-7: Test PowerShell paths are never denied for count and are not recorded in state, in either mode, in both hooks.
- [ ] AC-8: `CLAUDE_POWERSHELL_BUDGET_PROD`/`_TEST` and persisted `prodCap`/`testCap` no longer change the threshold; a legacy state file containing `prodCap`, `testCap`, and `testFiles` loads without error in both hooks.
- [ ] AC-9: Existing behaviors hold in both hooks: fail-closed deny on an unreadable envelope, out-of-root discard without a state write, repeated-path allow without a state write, deny-only entry-point output, and the `Get-PowerShellBatchBudgetBlockDecision` deny shape (`PreToolUseSchema.Contract.Tests.ps1` passes).
- [ ] AC-10: The Codex hook contains no `$env:CLAUDE_` read (`legacy-codex-hook-contracts.Tests.ps1` passes).
- [ ] AC-11: The checkpoint is supplied to both hooks through an injectable seam, and no new or modified test creates a temporary file.
- [ ] AC-12: New tests exist at `tests/scripts/claude-hooks/enforce-powershell-batch-budget-routing.Tests.ps1` and `tests/scripts/codex-hooks/codex-powershell-batch-budget-routing.Tests.ps1` and pass, and the updated `enforce-powershell-batch-budget.Tests.ps1` and `codex-batch-budget-hooks.Tests.ps1` pass.
- [ ] AC-13: A case-insensitive search for `per-batch`, `batch cap`, `smaller batches`, `split the work`, `new batch`, `three-test`, and `per-batch cap in all modes` returns no match in files whose path contains `powershell` under `.claude/`, `.agents/`, `.codex/`, `.github/agents/`, `.github/skills/`, and `.github/prompts/`, or in their bundle mirrors under `extensions/drm-copilot/resources/`, excluding `.github/agents/Powershell DI Unit Test Engineer.agent.md` and its mirror.
- [ ] AC-14: Every PowerShell routing statement in the Claude and Copilot surfaces listed in In scope item 5 states `1-3` production files for the small/direct path and more than 3 for the large path, and none of those files states `1-2` or `>2` as the PowerShell threshold.
- [ ] AC-15: Routing instructions in `.claude/skills/powershell-change-budget-router/SKILL.md`, `.claude/rules/powershell.md`, `.claude/agents/powershell-typed-engineer.md`, and `.claude/skills/invoke-powershell-engineer/SKILL.md` name `/orchestrate` and do not name `powershell-orchestrator`.
- [ ] AC-16: `.claude/skills/invoke-powershell-engineer/SKILL.md` no longer offers the `budget: prod=<N>, test=<M>` override input.
- [ ] AC-17: Every generated variant of `.codex/agents/powershell-typed-engineer.toml` is regenerated with `scripts/dev_tools/generate_codex_agent_variants.py`, and `test_generate_codex_agent_variants.py` passes.
- [ ] AC-18: Bundle parity holds: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_orchestrator_direct_command_contracts.py`, and the byte-identity and pack-manifest checks in `legacy-codex-hook-contracts.Tests.ps1` pass, and every changed `.github` file is identical to its copy under `extensions/drm-copilot/resources/customizations/.github/`.
- [ ] AC-19: `.github/copilot-instructions.md` and `.github/instructions/*` are unchanged on the branch relative to `main`.
- [ ] AC-20: No production or test file created or modified by this item exceeds 500 lines, and the 500-line checks in `legacy-codex-hook-contracts.Tests.ps1` pass.
- [ ] AC-21: PoshQC format -> analyze -> test passes with zero analyzer errors, line coverage >= 85% for both hooks, and no coverage regression on changed lines.
- [ ] AC-22: The hook docstrings describe the routing model and document the stale-checkpoint limitation and the #673 hygiene mitigation, and contain no per-batch or state-file-deletion reset guidance.
- [ ] AC-23: Follow-up 1 (Python and C# budget hooks and text) and Follow-up 2 (Codex routing resolver PowerShell budget) are recorded as potential entries under `docs/features/potential/`.

## Risks & Mitigations

- Technical or operational risks:
  - Stale large-path checkpoint exempts a later direct-mode session (accepted; see Known limitations).
  - Codex runtime continues to route at more than 2 production files until Follow-up 2 lands; this is stricter than the policy and does not deny on the large path.
  - Bootstrap: without hook-first ordering, this item's own execution would be denied by the current hook.
  - The Claude hook could exceed 500 lines after edits.
- Mitigations and rollbacks:
  - Checkpoint hygiene (#673); terminal-checkpoint exclusion; fail-safe to direct mode.
  - Plan edits the Claude hook first.
  - Sibling helper file if the line limit would be exceeded.
  - Rollback by revert.

## Rollout & Follow-up

- Release/rollout steps: merge to `main`; the change reaches isolated subagents only after merge; extension consumers receive it with the next extension release.
- Post-fix monitoring or clean-up tasks: file Follow-up 1 and Follow-up 2; owner review of `.github/agents/Powershell DI Unit Test Engineer.agent.md`.
- Links: Issue #769 (https://github.com/drmoisan/drm-copilot/issues/769); related issue #673 (checkpoint hygiene); research record listed in the header.
