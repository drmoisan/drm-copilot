# 2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint (Spec)

- **Issue:** #1010
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-10-30T12-17
- **Status:** Draft
- **Version:** 0.2

## Context
The preimplementation gate denies writes into an item worktree that has a complete, valid checkpoint, because it evaluates the session-root checkpoint instead of the target worktree's. One of four sibling bugs that share the target-worktree resolver fix described in the batch-budget bug (sibling issue #1009 owns the resolver).

Environment:
- OS/version: not recorded
- Python version: not applicable
- Command/flags used: Write, Edit, or `git commit` from a coordinating session, a non-isolated child, or that child's subagents, against a file inside an item worktree
- Data source or fixture: hooks `enforce-orchestration-preimplementation-gate.ps1` and its `-helpers`, `-targets`, `-modes`, and `-epic-scope` files

Primary technical source: `research/research.2026-10-30T12-17.md` in this feature folder. Environment facts (tool routes, hook execution context, batch budget, CI shape, contract tests, coverage gates, test isolation checks) are those of `.claude/skills/execution-environment/SKILL.md` and are cited by heading, not restated.

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

It blocks pr-author's receipt write (compounding the PR-authoring bug) and forces a human to open one session per item.


## Repro & Evidence
Steps to Reproduce:
1. Prepare an item worktree whose checkpoint has issue number, feature folder, route, `lifecycle_ready`, and checkpoint state.
2. From a coordinator-rooted session (or a non-isolated child, or its subagents), Write, Edit, or `git commit` against a file in that worktree.
3. Typical cases: committing an owner-decision record onto a prepared item branch before its child launches; pr-author writing `artifacts/pr_body_<N>.receipt.json` for an item from a coordinator-rooted subagent.

Expected:
- The checkpoint of the resolved target worktree is evaluated for file and git targets.
- `TARGET_WORKTREE_NOT_DERIVABLE` / `TARGET_WORKTREE_AMBIGUOUS` are denied only when no single worktree resolves.
- Delegation-prompt resolution for `Agent(...)` is unchanged.

Actual:
The gate denies `PREIMPLEMENTATION_GATE_BLOCKED` because it evaluates the session-root checkpoint, and the coordinator root keeps no per-item checkpoint by design.

Logs / Screenshots:
- [ ] Attached minimal logs or screenshot
- Snippet: `PREIMPLEMENTATION_GATE_BLOCKED`


## Scope & Non-Goals
- In scope:
  - (a) The Claude and Codex preimplementation gates evaluate the checkpoint of the worktree resolved by the shared `Resolve-HookTargetWorktree` resolver for file targets (Write/Edit `file_path`, Codex `apply_patch` marker paths) and git targets (`git add` / `git commit` commands on the Bash leg).
  - (b) `TARGET_WORKTREE_AMBIGUOUS` and `TARGET_WORKTREE_NOT_DERIVABLE` denials are emitted only when no single worktree resolves (operands in two or more distinct registered worktrees, or a resolver result with no root).
  - (c) `Agent(...)` delegation-prompt resolution (`Resolve-WorktreeItemTarget`, `Resolve-WorktreeEpicTarget`, `Resolve-WorktreeParallelTarget`) is unchanged.
  - (d) `lifecycle_ready` is evaluated as a strict JSON boolean in `Test-OrchestrationReady` in each of `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, and their bundle copies: only JSON `true` is ready; the string `"false"`, the string `"true"`, numbers, and `null` are not ready. Tests cover both surfaces.
  - (e) Bundled push-down copies remain text-equal to their repository sources, and pack manifests remain complete and dependency-closed.
- Out of scope / non-goals:
  - No relaxation of the preimplementation requirements (issue number, feature folder, route metadata, lifecycle readiness, checkpoint state).
  - No change to worktree isolation behavior or to any checkpoint schema.
  - The epic-scope `target-mixed` verdict is unchanged: rule V1 in `Resolve-OrchestrationEpicTargetVerdict` (`enforce-orchestration-preimplementation-gate-targets.ps1`) always includes the session-root scope, so an epic coordinator whose session root is on an integration branch is still denied when writing into a child worktree. This is recorded as a known limitation (research Open Risk R2) that requires an owner policy decision; it is not changed here.
  - `cd <wt> && git commit` chains remain session-root evaluated (research Open Risk R4). `git -C <wt> ...` is the supported form.
  - No change to the execution-environment brief (`.claude/skills/execution-environment/SKILL.md` and its copies) or to any file under `.claude/rules/`. Research section 4 found that no brief fact changes; the batch-budget exemption sentence belongs to #1009.
- Explicitly excluded systems, integrations, or datasets:
  - The `-helpers`, `-modes`, and `-targets` gate files on both surfaces, and the Codex `-epic-resolution` file, in all copies.
  - `.claude/settings.json` and `.codex/config.toml` (hook matchers and commands are unchanged).
  - `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` (owned and created by #1009; consumed here).
  - `enforce-pr-author-skill.ps1` and Bash-side PR commands (`gh pr create`, `gh pr edit`).

## Root Cause Analysis
The template's stated root cause (`Split-Path (Split-Path $PSScriptRoot)` root derivation) does not apply to this gate. That derivation exists only in the batch-budget hooks (`.claude/hooks/enforce-powershell-batch-budget.ps1`, `.claude/hooks/enforce-python-batch-budget.ps1`), which are #1009's scope. No file of the preimplementation gate set uses `Split-Path` or `$PSScriptRoot` for a root. The verified causes (research `## Summary of Verified Findings`) are:

1. Claude Write/Edit leg: not defective. The path leg already reads the checkpoint of the worktree containing `file_path` (`Resolve-OrchestrationGateTarget` -> `Resolve-WorktreeOperandTarget` in `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, an upward `.git` ascent through `Find-WorktreeResolutionRoot`). Existing test `O1 admits a Write inside another worktree whose checkpoint is ready, reading that checkpoint` in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1` pins that behavior.
2. Claude `git add` / `git commit` leg: session-root bound except for a leading `git -C`. `Get-OrchestrationEpicScopeSelector` reads only a `git -C <value>` occupying the first two tokens of the first command segment. It returns `$null` (session root) for `git -c k=v -C <wt> commit`, a `-C` on a later segment, an absolute file operand without `-C` (`git add <wt>/file`), and a `cd <wt> && git commit` chain. This matches the lifecycle record's "committing an owner-decision record onto a prepared item branch" case.
3. Codex gate: session-root bound on every single-feature leg. `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` reads `artifacts/orchestration/orchestrator-state.json` as a cwd-relative path through its own parameterless `Get-CheckpointContent`. The Write/Edit (`file_path`), Bash, and `apply_patch` legs all evaluate the session root's checkpoint. This is the defect as described in the issue, on the Codex surface.
4. Readiness predicate: `Test-OrchestrationReady` casts `lifecycle_ready` with `[bool]` in the Claude and Codex gate entry points and their bundle copies, so the JSON string `"false"`, any non-empty string, and any non-zero number are treated as ready.
5. Codex resolver reach: Codex hooks cannot import `.claude/lib` in a consumer repository (header of `.codex/hooks/file-size-policy.ps1`), so the Codex gate needs a Codex twin of the resolver.


## Proposed Fix

### Design summary (what changes where):
Consume the shared resolver behind the existing seam (research `## Candidate Approaches`, approach 1).

- Claude, `enforce-orchestration-preimplementation-gate-epic-scope.ps1`: add a guarded import of `../lib/worktree-resolution/HookTargetWorktree.psm1` in the existing `try { Import-Module ... } catch { Add-HookDependencyFailure ... }` form. In `Resolve-OrchestrationGateTarget`, route the `$FilePath` and `$Command` branches to `Resolve-HookTargetWorktree` and adapt its `{ WorktreeRoot, Source, Ambiguous }` result to the existing `{ Status, WorktreeRoot, ReasonCode, Detail }` shape read by `Read-OrchestrationGateCheckpoint`: `Ambiguous` -> `Status = 'Ambiguous'`, `ReasonCode = 'TARGET_WORKTREE_AMBIGUOUS'`; null root -> `Status = 'NoTarget'`, `ReasonCode = 'TARGET_WORKTREE_NOT_DERIVABLE'`; otherwise `SessionRoot` or `OtherWorktree` with the root and a `Detail` naming `Source`. Remove `Get-OrchestrationEpicScopeSelector`, which becomes unused on the Claude surface. Update the header `.DESCRIPTION` / `.NOTES`.
- Claude, `enforce-orchestration-preimplementation-gate.ps1`: in `Test-OrchestrationReady`, replace the `[bool]` cast with a strict check equivalent to `($Payload.lifecycle_ready -is [bool]) -and $Payload.lifecycle_ready`.
- Codex, `enforce-orchestration-preimplementation-gate-epic-scope.ps1`: receive `Get-CheckpointContent` (moved out of the Codex gate, with a mandatory absolute `-Path`, mirroring the Claude seam) and add `Resolve-OrchestrationGateTarget` / `Read-OrchestrationGateCheckpoint` equivalents for the single-feature legs, using the Codex resolver twin. For `apply_patch`, resolve each `*** Add File:` / `*** Update File:` / `*** Delete File:` / `*** Move to:` marker path as a file target; markers resolving to different worktrees deny as ambiguous.
- Codex, `enforce-orchestration-preimplementation-gate.ps1`: the single-feature read in `Invoke-OrchestrationPreimplementationGateDecision` calls the target reader; `Test-OrchestrationReady` receives the same strict check. The move of `Get-CheckpointContent` keeps the file at or below its 500-line pin.
- Bundle copies of each edited file are updated in the same task to remain text-equal.

### Boundaries and invariants to preserve:
- Single-feature deny wording is byte-identical (`... to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state ...`).
- Injection precedence is unchanged: `-CheckpointRaw` truthiness fall-through and `ContainsKey` checks for mode parameters.
- `Get-OrchestrationEpicScopeDecision` and the epic/parallel delegation branches of `Resolve-OrchestrationGateTarget` are unchanged.
- Agent delegation resolution is unchanged.
- Reason codes are sourced from the resolver module or the existing `WorktreeResolution.psm1` accessors, not introduced as new literals.
- No Python in hooks.
- The session root remains `(Get-Location).Path`; the payload `cwd` field is not used (research Open Risk R6).

### Dependencies or blocked work:
- Hard dependency on sibling issue #1009. #1009 owns and creates `.claude/lib/worktree-resolution/HookTargetWorktree.psm1`, exporting `Resolve-HookTargetWorktree` with the contract `{ WorktreeRoot, Source, Ambiguous }` and an injectable `git worktree list --porcelain` invoker. The module is not on `main` at the time of writing.
- Phase 0 gate: after merging `origin/main` into this branch, the module must exist and export `Resolve-HookTargetWorktree`. If it does not, implementation does not start and the run stops as blocked.
- Requirements on the resolver this item relies on (research `## Shared Resolver Requirements (#1009)`):
  - E1: a defined no-root result (`WorktreeRoot` is `$null`, for invoker failure or a session root outside any repository), which the gate maps to `TARGET_WORKTREE_NOT_DERIVABLE`. A silent session-root substitution on invoker failure is not acceptable.
  - E3: `-FilePath` accepts any path string, so `apply_patch` marker paths are resolved as file targets without a new source kind.
  - Bash semantics: every command segment and every git global-option position is scanned for `-C`; absolute file arguments are operands; operands in two or more distinct registered worktrees yield `Ambiguous = $true`; relative, absent, or outside-every-worktree operands yield the session root; the nearest enclosing registered worktree wins.
- Codex twin (E2), two branches:
  - If #1009 delivers a Codex twin under `.codex/hooks/` exporting `Resolve-HookTargetWorktree`, this item consumes it and creates no twin.
  - If #1009 does not, this item creates `.codex/hooks/hook-target-worktree.ps1` (function-identical to the Claude resolver), its bundle copy `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-target-worktree.ps1`, its entry in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`, and the parity suite `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1` in the style of `tests/scripts/codex-hooks/file-size-policy.Tests.ps1`.
- Batch budget: the production PowerShell files listed under `#### Files/modules to change` (plus the E2 files under the creation branch) exceed the direct-mode cap described in the brief's `## Batch Budget`; the executing worktree's checkpoint must select the `large` (or `remediation`) route.

### What #1011 may rely on
The following hold after this fix on both the Claude and Codex surfaces (research section 5):
- Checkpoint writes are never implementation: any `file_path` ending in `artifacts/orchestration/` followed by one of the checkpoint names (`orchestrator-state.json`, `parallel-planner-state.json`, `parallel-orchestrator-state.json`, `epic-planner-state.json`, `epic-orchestrator-state.json`, `powershell-orchestrator-state.json`, `csharp-orchestrator-state.json`), in any spelling, absolute or relative, in any worktree, is not denied by this gate.
- `artifacts/pr_body_<N>.md` is never gated (`.md` is not an implementation extension).
- `artifacts/pr_body_<N>.receipt.json` written with an absolute `file_path` inside an item worktree is evaluated against that worktree's `artifacts/orchestration/orchestrator-state.json`, and is allowed when that checkpoint has a non-empty `issue-num`, a `feature-folder` under `docs/features/active/`, a `route_id` or `path_selected`, and `lifecycle_ready` equal to the JSON boolean `true`.
- A relative `artifacts/pr_body_<N>.receipt.json` resolves against the session root and evaluates the session root's checkpoint. #1011 must pass the absolute item-worktree path.
- `gh pr create` and `gh pr edit` are not implementation commands for this gate; `--body-file` / `--head` resolution belongs to `enforce-pr-author-skill.ps1`.
- Not covered: the epic coordinator `target-mixed` denial (Open Risk R2).

### Implementation strategy (what changes, not sequencing):
	
#### Files/modules to change:
Production, edited:
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`

Conditional, Codex twin (E2 creation branch only, when #1009 provides no Codex twin):
- `.codex/hooks/hook-target-worktree.ps1` (new)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/hook-target-worktree.ps1` (new)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (entry added; must remain byte-equal to `render_manifest` output of `scripts/dev_tools/generate_codex_agent_variants.py`)
- `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1` (new)

Conditional, Claude manifest:
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` is changed only if #1009 did not list `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` in Claude `core.json`.

Tests, new:
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1`

Tests, updated:
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Cases.ps1`
- `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1`
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`

#### Functions/classes/CLI commands impacted:
- Claude: `Resolve-OrchestrationGateTarget` (file and command branches only), `Read-OrchestrationGateCheckpoint` (unchanged signature; consumes adapted result), `Get-OrchestrationEpicScopeSelector` (removed), `Test-OrchestrationReady`.
- Codex: `Get-CheckpointContent` (moved to `-epic-scope`, gains mandatory absolute `-Path`), new `Resolve-OrchestrationGateTarget` / `Read-OrchestrationGateCheckpoint` equivalents, `Invoke-OrchestrationPreimplementationGateDecision` (single-feature read), `Test-OrchestrationReady`.
- Consumed: `Resolve-HookTargetWorktree` (#1009, or the E2 Codex twin).

#### Data flow and validation changes:
Gated call -> classification (`Test-ImplementationPath` / `Test-ImplementationCommand`, unchanged) -> `Resolve-HookTargetWorktree` with `-FilePath` or `-Command` and `-SessionRoot (Get-Location).Path` -> adapter -> `Get-WorktreeRunCheckpointPath -Kind item -WorktreeRoot <resolved root>` (Codex: equivalent absolute path) -> `Get-CheckpointContent -Path` -> `Test-OrchestrationReady` with strict boolean `lifecycle_ready`. Resolution runs only after classification determines that a checkpoint is required.

#### Error handling and logging updates:
- Ambiguous resolution denies with `TARGET_WORKTREE_AMBIGUOUS`; a null root denies with `TARGET_WORKTREE_NOT_DERIVABLE`. The deny detail names the resolver `Source`.
- A failure to import `HookTargetWorktree.psm1` is reported through the existing `Add-HookDependencyFailure` path (fail closed).
- No new logging channel.

#### Rollback/feature-flag considerations (if applicable):
No feature flag. Rollback is a revert of the edited production files (plus the E2 files when created) and their tests; the bundle copies revert with their sources.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- Resolver input: `-FilePath <string>` (any path string), `-Command <string>`, `-SessionRoot <string>`, injectable worktree-list invoker. Output: `{ WorktreeRoot = <absolute normalized path or $null>; Source = <string>; Ambiguous = <bool> }`.
- Adapter output (unchanged shape): `{ Status; WorktreeRoot; ReasonCode; Detail }`.
- Hook output: the existing PreToolUse allow/deny payload; no format change.

#### Required configuration keys and defaults:
None added. Checkpoint keys read are unchanged: `issue-num`, `feature-folder`, `route_id` / `path_selected`, `lifecycle_ready`, checkpoint state.

#### Backward-compatibility expectations:
- `lifecycle_ready` values produced by `ConvertFrom-Json` from JSON `true` / `false` literals behave as before; only non-boolean values (strings, numbers, `null`) change from ready to not ready.
- Path-leg narrowing (research Open Risk R3): a path in a worktree of a different repository, or an unregistered directory containing a `.git` entry, now falls back to the session root.
- Existing mocks of `Resolve-OrchestrationGateTarget` (Parity suite, O1 to O3, O9) continue to work because the function name and output shape are preserved.

#### Performance constraints (latency/throughput/memory):
At most one `git worktree list --porcelain` process per gated call that requires a checkpoint, after classification (research Open Risk R5). Ungated calls start no process.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access): #1009 merges to `main` before implementation begins and delivers E1 and E3; tests run under Pester with all resolver invokers mocked; hook execution context is as stated in the brief's `## Hook Execution Context` (isolated subagents run `main`'s hook copies, so branch hooks are proven by Pester, not by live subagents).
- Constraints (budget, performance, compatibility): the Codex gate is at its 500-line test pin and must not grow net; the Claude and Codex gate files must remain at or below 500 lines where pinned; batch budget requires the `large` route; per-file line coverage >= 85% for edited repository production files (brief `## Coverage and File-Size Gates`); PowerShell has no branch-coverage gate.
- External dependencies (services, libraries, releases): sibling issue #1009 (`HookTargetWorktree.psm1`, optional Codex twin); git CLI at runtime.

## Data / API / Config Impact
- User-facing or API changes: coordinator-rooted Write/Edit/`git commit` into an item worktree with a ready checkpoint is allowed; non-boolean `lifecycle_ready` is no longer treated as ready.
- Data or migration considerations: none; no checkpoint schema change.
- Logging/telemetry updates (if any): deny detail names the resolver `Source` for target-resolution denials.
- Compatibility notes (CLI flags, config schemas, versioning): pack manifests updated only under the conditional branches above; Codex `core.json` must stay generator-clean.

## Test Strategy
Seeded from issue:

- [x] Unit coverage areas: Write/Edit/commit into a worktree with a complete checkpoint → allow; the same into a worktree without one → deny; a target outside every worktree → current behavior; two candidate worktrees → ambiguous deny. Tests in every runtime carrying the hook (Claude, Codex, and the bundled push-down copies).
- [ ] Integration scenario to retest
- [ ] Manual verification notes

Documentation and parity as in the sibling batch-budget issue (execution-environment brief copies, `orchestrator-state.md`, contract tests, pack manifest, dependency closure, no Python in hooks). Research section 4 verified that this item changes no brief fact and no `orchestrator-state.md` fact; only the contract-test, pack-manifest, dependency-closure, and no-Python items apply here.

Out of scope: no relaxation of the preimplementation requirements; no change to worktree-isolation behavior or checkpoint schemas.

- Regression tests to add or update:
  - New `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1`, each covering (research section 3): Write/Edit into an item worktree with a ready checkpoint -> allow, reading the item path; the same with an absent or not-ready checkpoint -> deny; `git -c k=v -C <wt> commit`, `git add <wt>/file`, and a later-segment `-C` -> the item checkpoint; a target outside every registered worktree -> session-root checkpoint; two candidate worktrees -> deny naming `TARGET_WORKTREE_AMBIGUOUS`; a resolver result with no root -> deny naming `TARGET_WORKTREE_NOT_DERIVABLE`; `lifecycle_ready` `"false"` -> deny. The Codex suite also covers `apply_patch` with an absolute marker path and with markers in two worktrees.
  - Updated `enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1`: O4, O5, O6 re-mocked through the `Resolve-HookTargetWorktree` invoker seam; expected outcomes unchanged.
  - Updated `enforce-orchestration-preimplementation-gate.Parity.Cases.ps1`: readiness rows for `"lifecycle_ready":"false"`, `"lifecycle_ready":"true"`, and `"lifecycle_ready":1` (all `Expected = $false` on both surfaces); remove Codex `Get-CheckpointContent` from `$script:CodexOnlyGateFunction` if it moves.
  - Updated `EpicStateIsolation.Baseline.Helpers.ps1`: register the invoker seam returning an empty list in `$script:EpicStateBaselineModuleSeam`.
  - Updated `legacy-codex-hook-contracts.Tests.ps1`: the rows `returns empty checkpoint content when the checkpoint file is absent`, `returns the checkpoint file content when the checkpoint file is present`, and `reads the checkpoint from disk when no checkpoint text is supplied` use the mandatory absolute `-Path`; the last of these (the `Push-Location` row) mocks the read seam and invoker instead of reading a host checkpoint.
  - E2 creation branch only: `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1` (function parity with the Claude resolver).
- Unit tests (pytest) for the fixed behavior and boundaries: not applicable. All new and updated tests are Pester; no pytest suite is added. The Python contract tests listed below are run unchanged.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values): relative operand (session-root fallback), absent checkpoint, `lifecycle_ready` as `"false"`, `"true"`, `1`, `null`; ambiguous operands; null root; outside-every-worktree target; nested agent worktree inside the main checkout (nearest enclosing wins).
- Error handling and logging verification: deny text for ambiguous and not-derivable cases names the reason code and `Source`; single-feature deny wording asserted byte-identical by the existing EpicScope suites.
- Coverage impact and targets for changed lines/modules: per-file line coverage >= 85% for each edited repository production file (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, and `.codex/hooks/hook-target-worktree.ps1` when created), read from `artifacts/pester/powershell-coverage.xml`. Bundle copies are outside the coverage population (`config/poshqc-coverage.json`). No branch gate applies to PowerShell.
- Toolchain commands to run (format → lint → type-check → test): PoshQC format, PoshQC analyze, Pester (type-check not applicable to PowerShell), using the routes in the brief's `## PowerShell Route and PoshQC MCP Limits`. Then the contract tests from the brief's `## Contract Tests That Pin Mirrored Files`: `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, the Codex generator `--check`, and `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1`. Also the Codex row `keeps <File> at or under 500 lines in the repository and the bundle` in `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`.
- Isolation: seeded shuffled Pester runs plus a fresh single-process run over `tests/scripts`, per the brief's `## Test Isolation Checks`. Synthetic roots use forward-slash `/synthetic-worktrees/...` paths with exact file-name case (brief `## CI-Only Failure Classes`).
- Evidence: fail-before runs (Codex Write and `apply_patch` legs and the Claude `git -c k=v -C <wt> commit` leg denying against a ready item checkpoint) and pass-after runs recorded under `<FEATURE>/evidence/regression-testing/` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`, counts read from `artifacts/pester/pester-junit.xml`.
- Manual validation steps (if required): none. Live hook behavior in subagents is not part of acceptance (brief `## Hook Execution Context`).


## Acceptance Criteria
- [x] Phase 0 dependency check: after merging `origin/main`, `.claude/lib/worktree-resolution/HookTargetWorktree.psm1` exists and exports `Resolve-HookTargetWorktree` with the `{ WorktreeRoot, Source, Ambiguous }` contract, a null-`WorktreeRoot` no-root result, and `-FilePath` accepting any path string; the result (present, or blocked) and whether #1009 delivered a Codex twin are recorded in the feature evidence before any production edit.
- [x] Claude git-commit leg: `git -c k=v -C <wt> commit` from a coordinator session reads the item worktree's checkpoint and is allowed when that checkpoint is ready (proved in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1`, with fail-before evidence showing the pre-fix deny).
- [x] Claude git-add leg: `git add <wt>/file` with an absolute operand reads the item worktree's checkpoint (proved in `enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1`).
- [x] Claude later-segment selector: a `git -C <wt>` on a later command segment reads the item worktree's checkpoint (proved in `enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1`).
- [x] Claude Write/Edit into an item worktree with a ready checkpoint is allowed, and with an absent or not-ready checkpoint is denied (proved in `enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1`; existing O1 in `enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1` passes; O4, O5, O6 pass with unchanged expected outcomes after re-mocking).
- [x] Codex Write/Edit (`file_path`) leg reads the item worktree's checkpoint: allowed when ready, denied when absent or not ready (proved in `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1`, with fail-before evidence).
- [x] Codex Bash leg (`git -c k=v -C <wt> commit`, `git add <wt>/file`, later-segment `-C`) reads the item worktree's checkpoint (proved in `enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1`).
- [x] Codex `apply_patch` leg resolves each marker path and reads the item worktree's checkpoint for an absolute marker path; markers in two distinct worktrees deny as `TARGET_WORKTREE_AMBIGUOUS` (proved in `enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1`, with fail-before evidence).
- [x] Ambiguous denial: operands in two distinct registered worktrees deny naming `TARGET_WORKTREE_AMBIGUOUS` on both surfaces (proved in both new TargetWorktree suites).
- [x] Not-derivable denial: a resolver result with a null `WorktreeRoot` denies naming `TARGET_WORKTREE_NOT_DERIVABLE` on both surfaces (proved in both new TargetWorktree suites).
- [x] A target outside every registered worktree, a relative operand, or no operand evaluates the session-root checkpoint as before (proved in both new TargetWorktree suites and O5 in `enforce-orchestration-preimplementation-gate.OperandResolution.Tests.ps1`).
- [x] Agent delegation resolution is unchanged: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.WorktreeResolution.Tests.ps1` passes without modification to that file.
- [x] Strict `lifecycle_ready`: in `Test-OrchestrationReady` in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, and their bundle copies, only JSON `true` is ready; `"false"`, `"true"`, `1`, and `null` are not ready (proved by the new readiness rows in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.Parity.Cases.ps1` on both surfaces and the `"false"` deny row in both new TargetWorktree suites).
- [x] Single-feature deny wording is byte-identical: the existing deny-text assertions in `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`, `enforce-orchestration-preimplementation-gate.EpicScopeTargets.Tests.ps1`, and the Codex `-epic-scope.Tests.ps1` and `-epic-scope-targets.Tests.ps1` pass unchanged.
- [x] Epic-scope `target-mixed` behavior (rule V1 in `Resolve-OrchestrationEpicTargetVerdict`) is unchanged: `enforce-orchestration-preimplementation-gate-targets.ps1` is not edited in any copy and `enforce-orchestration-preimplementation-gate-targets.Parity.Tests.ps1` passes.
- [x] `Get-OrchestrationEpicScopeSelector` is removed from the Claude `-epic-scope` file and its bundle copy, and the Codex `Get-CheckpointContent` is moved out of the Codex gate with a mandatory absolute `-Path` (proved by updated `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` and the Parity suite function-inventory row).
- [x] Test isolation: `tests/scripts/claude-hooks/EpicStateIsolation.Baseline.Helpers.ps1` registers the resolver invoker seam, no suite starts a `git` process or reads a host checkpoint, and the seeded shuffled Pester runs required by the brief's `## Test Isolation Checks` plus a fresh single-process run over `tests/scripts` pass.
- [x] Bundle parity: every edited hook file is text-equal to its bundle copy; `test_push_down_claude_resource_contracts.py` and `test_push_down_codex_and_agents_resource_contracts.py` pass.
- [x] Pack manifests: `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, and the Codex generator `--check` pass; `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` passes with the guarded `HookTargetWorktree.psm1` import.
- [x] Codex twin (E2): if #1009 delivered a Codex twin, the Codex gate consumes it and no twin file is created; otherwise `.codex/hooks/hook-target-worktree.ps1`, its bundle copy, its Codex `core.json` entry, and `tests/scripts/codex-hooks/hook-target-worktree.Tests.ps1` exist and that suite passes.
- [x] File size: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and its bundle copy remain at or below 500 lines, proved by the row `keeps <File> at or under 500 lines in the repository and the bundle` in `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`; every edited file remains at or below 800 lines.
- [x] Full PowerShell toolchain passes in a single pass (PoshQC format, PoshQC analyze, Pester), and each edited repository production file reports line coverage >= 85% in `artifacts/pester/powershell-coverage.xml`.
- [x] Fail-before and pass-after evidence is recorded under `<FEATURE>/evidence/regression-testing/` with `Timestamp`, `Command`, `EXIT_CODE`, and `Output Summary`.

## Risks & Mitigations
- Technical or operational risks:
  - R1: #1009 is not merged or its final contract lacks E1/E3; implementation cannot start.
  - R2: epic coordinator on an integration branch is still denied with `target-mixed` for writes into a child worktree; requires an owner policy decision.
  - R3: path-leg narrowing to registered worktrees; paths in unregistered `.git` directories or other repositories fall back to the session root.
  - R4: `cd <wt> && git commit` remains session-root evaluated.
  - R5: one additional `git` process per gated call requiring a checkpoint.
  - Codex gate at its 500-line pin; growth fails the size row.
  - An unmocked resolver invoker in any suite would start `git` and read host worktrees, producing host-dependent results.
- Mitigations and rollbacks:
  - Phase 0 stop-as-blocked gate for R1.
  - R2 and R4 documented here and in the PR description as known limitations; `git -C <wt>` documented as the supported commit form.
  - Move `Get-CheckpointContent` out of the Codex gate before adding logic; measure lines before and after.
  - Register the invoker seam in the shared baseline helper and run seeded shuffle isolation checks.
  - Copy each edited file to its bundle path in the same task and run all brief-listed contract tests.
  - Rollback by reverting the item's commits.

## Rollout & Follow-up
- Release/rollout steps: merge after #1009; the change reaches consumer repositories through the next extension release carrying the bundled hook copies.
- Post-fix monitoring or clean-up tasks: owner decision on the epic `target-mixed` policy (R2); confirm #1011 consumes the guarantees in `### What #1011 may rely on`.
- Links: issue #1010; dependency #1009; consumer #1011; research `research/research.2026-10-30T12-17.md`; lifecycle record `docs/features/potential/promoted/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint.md`.
