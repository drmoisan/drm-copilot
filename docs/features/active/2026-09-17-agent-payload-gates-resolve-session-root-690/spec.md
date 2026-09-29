# agent-payload-gates-resolve-session-root (Spec)

- **Issue:** #690
- **Parent (optional):** epic #678 defect class (worktree-scoped state resolution)
- **Owner:** drmoisan
- **Last Updated:** 2026-09-29T22-15
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug
- **Branch:** `bug/agent-payload-gates-resolve-session-root-690`
- **Research:** `docs/features/active/2026-09-17-agent-payload-gates-resolve-session-root-690/research/2026-09-29T21-55-agent-payload-gates-session-root-research.md`

## Context

Several PreToolUse gates under `.claude/hooks/` read orchestration checkpoints
(`artifacts/orchestration/orchestrator-state.json`, `epic-orchestrator-state.json`,
`parallel-orchestrator-state.json`) through a path relative to the hook process directory. The hook
process directory is the invoking session's root, not the worktree the gated call targets. When a
coordinating session acts on an item, epic, or parallel run whose checkpoint lives in a different
worktree, the gate either denies a correct call (false denial) or evaluates the call against an
unrelated checkpoint that happens to occupy the session root (false approval).

Issue #690 originally named `enforce-orchestration-preimplementation-gate.ps1` and
`enforce-model-routing-receipt.ps1`. PR #695 fixed the per-feature read in
`enforce-model-routing-receipt.ps1`; #669 delivered the resolution module, #671 the `git -C`
staging exemption, and #687 the pr-author gate. The research record inventories the remaining
session-root-relative reads under `.claude/hooks` and `.claude/lib` (research section 3). This spec
converts the reads listed in Scope below.

The settled design (issue #690 comment of 2026-09-19, restated in research section 1): resolve the
target by portable identity, never by a feature-folder path or the payload `cwd`; after the scope
filter, deny an unidentifiable target with `TARGET_WORKTREE_NOT_DERIVABLE` or
`TARGET_WORKTREE_AMBIGUOUS`; stay fail-closed; otherwise keep each gate's decision semantics.

Environment:
- OS/version: Windows 11 Pro 10.0.26200, PowerShell 7+
- Command/flags used: `Agent(orchestrator)` epic-mode and parallel-mode kickoffs; `Agent(<implementation agent>)`; `Write`/`Edit`; `git`, `gh pr merge --merge <PR>`, `git worktree remove <path>`
- Data source or fixture: live worktree state under `C:\Users\DanMoisan\repos\drm-copilot-wt\` (observed 2026-09-29); tests use mocked seams and committed fixtures only

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

An epic run launched from a session whose root is not the epic worktree cannot pass the
preimplementation gate or the epic wave barrier. Coordinator writes into another worktree are
denied, which pushes work onto ungoverned tool paths (issue #690, observed impact for #688). Where a
stale checkpoint occupies the session root, the same reads can approve a call on the wrong run's
state.

## Repro & Evidence

Steps to reproduce (2026-09-29 epic run, research section 2):
1. Create an epic worktree `W_epic` (`2026-09-29T14-15-epic-770`) with the integration branch
   `epic/push-down-payload-correctness-integration` checked out and a valid
   `artifacts/orchestration/epic-orchestrator-state.json` (`route_id: "epic"`, matching
   `integration_branch`).
2. From a session whose root `W_session` holds no epic checkpoint, run `/epic-run`. The forked
   `epic-orchestrator` issues `Agent(orchestrator)` with the kickoff line
   `Epic mode: true. epic_feature_folder: <slug>. integration_branch: epic/<slug>-integration. ...`.
3. `Resolve-OrchestrationDelegationMode` returns `epic`; `Get-EpicCheckpointContent` tests
   `artifacts/orchestration/epic-orchestrator-state.json` relative to `W_session`, finds nothing, and
   returns `''`.

Expected: the delegation is evaluated against the epic checkpoint in `W_epic` and admitted when that
checkpoint is ready.

Actual: `Get-EpicOrchestrationReadinessFailure` returns `checkpoint-absent`, and the gate denies with
`PREIMPLEMENTATION_GATE_BLOCKED` naming the relative literal. `enforce-epic-wave-barrier.ps1` reads
the same relative literal (`:38,54-57,272`) and would deny the same call with
`EPIC_WAVE_BARRIER_BLOCKED`.

Second instance (issue #690, 2026-09-17/18, #688): a coordinating session's
`Agent(powershell-typed-engineer)` delegation and every `Write`/`Edit` into the target worktree were
denied with `PREIMPLEMENTATION_GATE_BLOCKED`, although a validator-passing checkpoint existed in the
target worktree.

Frequency / determinism: deterministic whenever the checkpoint the gate needs is not at the session
root.

Why the existing item resolver does not fix the epic case: `Find-WorktreeResolutionBranchSignal`
matches only `--head`, `--branch`, or `\bbranch:` (`WorktreeTargetResolution.psm1:61`). In
`integration_branch:` the characters `_` and `b` are both word characters, so `\b` does not hold,
and the epic kickoff carries no canonical issue-number line. An epic kickoff therefore resolves
`NoTarget` under `Resolve-WorktreeItemTarget`.

## Scope & Non-Goals

### In scope

Each site below is identified by its research section 3 row. This spec makes no claim about the
total number of session-root-relative reads in the repository (see "Numeric assertions" below).

- **Preimplementation gate, single-feature reads** (row 1):
  `enforce-orchestration-preimplementation-gate.ps1` `Get-CheckpointContent` for the Agent,
  Write/Edit path, and Bash command legs.
- **Preimplementation gate, epic-mode read** (row 2): `Get-EpicCheckpointContent` in
  `enforce-orchestration-preimplementation-gate-epic-scope.ps1`.
- **Preimplementation gate, parallel-mode read** (row 3): `Get-ParallelCheckpointContent` in the
  same file.
- **`Resolve-EpicScopeCheckpoint`** (row 4) in `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`,
  which serves the preimplementation gate's epic-scope command and path legs,
  `enforce-model-routing-receipt.ps1:247`, and `enforce-pr-author-skill-helpers.ps1:344`.
- **Epic wave barrier** (row 5): `enforce-epic-wave-barrier.ps1` checkpoint read.
- **Parallel cohort barrier** (row 6): `enforce-parallel-cohort-barrier.ps1` checkpoint read.
- **Merge gate, child branch** (row 7), **epic branch** (row 8), and **parallel branch** (row 9) in
  `enforce-epic-merge-gate.ps1`.
- **Epic worktree-removal gate** (row 10): `enforce-epic-worktree-removal-gate.ps1`.
- **Parallel worktree-removal gate** (row 11): `enforce-parallel-worktree-removal-gate.ps1`.
- **Parallel drift gate** (row 12): `enforce-parallel-drift-gate.ps1`.
- **Import-failure fail-closed for the new dependency** in each converted gate (see Proposed Fix,
  "Error handling"). Decision: in scope for the resolution-module imports this change introduces;
  out of scope for pre-existing imports and dot-sources (recorded as a follow-up).
- **Identity contract text** in `.claude/skills/orchestrate/SKILL.md`,
  `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, and the
  `.claude/skills/invoke-*-engineer/SKILL.md` direct callers of the implementation agents.
- **Registration and mirrors**: bundle mirrors under
  `extensions/drm-copilot/resources/claude-customizations/`, `pack-manifests/core.json`,
  `WorktreeResolution.Manifest.Tests.ps1`, both PoshQC runsettings copies, and the #737 isolation
  guard test `enforce-gate-suites.EpicStateIsolation.Tests.ps1`.

### Out of scope / non-goals

- `.claude/hooks/validate-orchestrator-output.ps1` (SubagentStop, row 18). It remains
  session-relative; recorded as a follow-up potential entry.
- `.codex/hooks/**` and the Codex bundle copies (issue #736). No `.codex` hook imports
  `.claude/lib/worktree-resolution` (research section 6).
- The epic wave barrier's feature-folder selection, `Find-EpicWaveBarrierFeatureFolderFromPrompt`
  (issue #565). The folder token stays a record key only.
- `enforce-model-routing-receipt.ps1` per-feature read (fixed by PR #695) and
  `enforce-pr-author-skill.epic-base-branch.ps1` (fixed by #687). Their epic branches change only
  through `Resolve-EpicScopeCheckpoint`; their hook files are not edited.
- `enforce-prd-feature-before-planner.ps1` (already on `Resolve-WorktreeItemTarget`).
- Session-scoped reads by design: `enforce-powershell-batch-budget.ps1` (row 16) and
  `CleanupWorktreeManifest.psm1` (row 17).
- The `Invoke-OrchestratorStatePreflight` latent default path (row 19).
- Hardening of pre-existing module imports and dot-sources that fail open, in any hook.

### Explicitly excluded systems, integrations, or datasets

- `.claude/lib/worktree-resolution/WorktreeResolution.psm1` (at the 500-line cap; not edited).
- `enforce-orchestration-preimplementation-gate-helpers.ps1` (SHA-256 pinned across four copies
  including Codex; not edited).
- No Python file is added or edited. No git subprocess is started by any new code.

### Numeric assertions

The research record states that it proposes no numeric acceptance criterion and carries no
`## Numeric Derivation Evidence` section. This spec therefore makes no count, total, or
exhaustiveness assertion about the inventory of sites, suites, or fixtures. Each in-scope site is
named individually. The 85% coverage and 500-line values below are repository policy thresholds,
not counts of a population.

## Root Cause Analysis

- **Confirmed root cause:** each listed site composes its checkpoint path as a relative literal (or
  from the session root) and reads it through `Test-Path`/`Get-Content` relative to the hook process
  directory. The process directory is the session root for main-session calls and forked skills
  (`epic-run`, `parallel-orchestrate` run as `context: fork`), so the read never follows the call's
  target.
- **Signals/evidence:** research section 2 (call path of the 2026-09-29 denial, with file and line
  references) and section 3 (site inventory). The epic kickoff carries `integration_branch:` but no
  canonical issue line, so the existing item resolver cannot identify an epic target.
- **Affected components:** the hook files and library module listed under In scope.

## Proposed Fix

### Design summary (what changes where)

1. Add `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, a sibling module that resolves
   epic and parallel run targets. It reuses `Get-WorktreeItemLiveRoot` and
   `New-WorktreeResolutionTargetResult`, and returns the existing result shape (`Status` in
   `SessionRoot`, `OtherWorktree`, `NoTarget`, `Ambiguous`; `WorktreeRoot`, `SessionRoot`, `Signal`,
   `SignalValue`, `Candidates`, `ReasonCode`, `Detail`), so each gate keeps one `switch` over `Status`.
2. Export `ConvertTo-WorktreeItemResolvedResult` from `WorktreeItemResolution.psm1` so
   `SessionRoot`/`OtherWorktree` labelling has one definition.
3. Convert each in-scope gate to resolve its target first (after its existing scope filter), then
   read the checkpoint beneath the resolved root through an absolute path.

Identity keys:

| Run kind | Signal in the payload | Match rule |
|---|---|---|
| Epic delegation (preimplementation epic mode, wave barrier) | `integration_branch: <name>` (and optional `epic_feature_folder: <slug>` cross-check) | Live worktree whose `epic-orchestrator-state.json` has `route_id -ceq 'epic'` and `integration_branch -ceq <name>`; tie-break by the worktree that has `<name>` checked out |
| Parallel delegation (preimplementation parallel mode, cohort barrier, drift gate) | `parallel_slug: <slug>` | Live worktree whose `parallel-orchestrator-state.json` has `route_id -ceq 'parallel'` and `parallel_slug -ceq <slug>`; no tie-break |
| Single-feature Agent leg | canonical issue-number line plus `branch:` label | Existing `Resolve-WorktreeItemTarget` |
| Single-feature Write/Edit path leg | absolute `file_path` operand | Worktree containing the path by ascent (PR #726 precedent) |
| Single-feature Bash command leg | `git -C <dir>` selector | Worktree containing the selector; no selector means the session root |
| Merge gate epic/parallel branches | explicit PR number in `gh pr merge --merge <PR>` | Live worktree whose run checkpoint records that `pr_number` |
| Removal gates | path in `git worktree remove <path>` | Live worktree whose run checkpoint records that `worktree_path` |

### Boundaries and invariants to preserve

- Resolution never uses a feature-folder path, a prompt-declared checkpoint path, or the payload
  `cwd` to select a worktree. A prompt-declared `epic_checkpoint_path` remains a cross-check only.
- Resolution runs after each gate's existing scope filter; calls the gate does not govern are
  unaffected.
- `NoTarget` and `Ambiguous` deny, behind each gate's existing leading token (for example
  `PREIMPLEMENTATION_GATE_BLOCKED:`, `EPIC_WAVE_BARRIER_BLOCKED:`), with the reason code obtained from
  `Get-WorktreeResolutionNoTargetReasonCode` or `Get-WorktreeResolutionAmbiguityReasonCode`.
- A resolved target whose checkpoint is absent, unparseable, a JSON array, or has the wrong
  `route_id` denies with the gate's existing reason (for example `checkpoint-absent`), not an allow.
- Injection parameters keep precedence over resolution: `-CheckpointRaw`, `-EpicCheckpointRaw`,
  `-ParallelCheckpointRaw` on the preimplementation gate, and each barrier/merge/removal gate's
  existing read-seam name, so existing test rows are unchanged.
- In the plain single-worktree case the resolved status is `SessionRoot` and the checkpoint read is
  the same file as today.
- No session-root-first fast path: a stale checkpoint copy at the session root must not win over the
  worktree that actually owns the run.

### Dependencies or blocked work

- Depends on #669 (`WorktreeResolution.psm1`, `WorktreeTargetResolution.psm1`) and the PR #695
  item resolver (`WorktreeItemResolution.psm1`), both merged.
- #565 edits `enforce-epic-wave-barrier.ps1` in a different function. Whichever lands second
  rebases.
- #737 edits the isolation guard list in `enforce-gate-suites.EpicStateIsolation.Tests.ps1`. This
  change updates that guard; coordinate so the two do not edit the list concurrently.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

New:
- `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` and its bundle mirror.
- Library tests under `tests/scripts/claude-lib/worktree-resolution/`.
- Gate tests under `tests/scripts/claude-hooks/` (one new suite per converted gate, or new
  `Describe` blocks in an existing suite that stays within 500 lines).
- Committed fixtures, if used, under `tests/fixtures/worktree-resolution/<gate>/<root>/artifacts/orchestration/`.

Changed (each with its bundle mirror):
- `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1` (export line only).
- `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`.
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and
  `enforce-orchestration-preimplementation-gate-epic-scope.ps1`.
- `.claude/hooks/enforce-epic-wave-barrier.ps1`, `enforce-parallel-cohort-barrier.ps1`.
- `.claude/hooks/enforce-epic-merge-gate.ps1` and `enforce-epic-merge-gate-authorization.ps1`.
- `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`,
  `enforce-parallel-worktree-removal-gate.ps1`, `enforce-parallel-drift-gate.ps1`.
- `.claude/skills/orchestrate/SKILL.md`, `epic-orchestrate/SKILL.md`,
  `parallel-orchestrate/SKILL.md`, and each `.claude/skills/invoke-*-engineer/SKILL.md`.
- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`.
- `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1`.
- `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1`.
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and
  `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`.
- Existing gate suites that need a default `BeforeAll` mock of the new resolution seam.

Where new logic goes (500-line limit):

| File | Lines now | Rule for this change |
|---|---|---|
| `WorktreeResolution.psm1` | 500 | Not edited. |
| `enforce-orchestration-preimplementation-gate-helpers.ps1` | 497 | Not edited. |
| `enforce-orchestration-preimplementation-gate.ps1` | 483 | `Get-CheckpointContent` and all resolution glue move to `enforce-orchestration-preimplementation-gate-epic-scope.ps1` (127 lines), following the #663 relocation precedent. The gate file keeps only call sites and must end at or below 500 lines. |
| `enforce-epic-merge-gate.ps1` | 483 | Resolution glue goes in `enforce-epic-merge-gate-authorization.ps1` (443 lines). If that file would exceed 500 lines, the glue goes in a new dot-sourced sibling `enforce-epic-merge-gate-resolution.ps1`, which is registered in `core.json` and mirrored. The gate file must end at or below 500 lines. |
| `enforce-orchestration-preimplementation-gate-modes.ps1` | 480 | No new logic. Identity parsing lives in `WorktreeRunResolution.psm1`. |
| `enforce-epic-worktree-removal-gate.ps1` | 468 | One-call seam only; matching logic lives in `WorktreeRunResolution.psm1`. |
| Other converted hooks and `EpicScopeResolution.psm1` | 283 to 397 | Glue may be inline; each must end at or below 500 lines. |
| `WorktreeRunResolution.psm1` | new | Must be at or below 500 lines (research estimate: under 300). |

#### Functions/classes/CLI commands impacted

`WorktreeRunResolution.psm1` exports:
- `Find-WorktreeRunIdentitySignal -Text`: pure. Reads the literals `integration_branch: <name>`,
  `epic_feature_folder: <slug>`, and `parallel_slug: <slug>` case-sensitively. The token ends at
  whitespace or a trailing `.` that terminates the kickoff sentence.
- `Get-WorktreeRunCheckpointText -Path`: the module's only filesystem read and the test seam.
  Returns `$null` for an absent file.
- `Resolve-WorktreeEpicTarget -IntegrationBranch [-EpicSlug] -SessionRoot`: empty branch returns
  `NoTarget`; zero matching live roots return `NoTarget`; one returns `SessionRoot` or
  `OtherWorktree`; several are narrowed to the roots with the integration branch checked out
  (`Get-WorktreeItemLiveRoot -Branch`), one survivor resolves and otherwise `Ambiguous` with a
  `Detail` naming the remedy (move the stale copy to `artifacts/orchestration/handoff/`). A supplied
  slug that disagrees with a match's `epic_feature_folder` returns `Ambiguous`.
- `Resolve-WorktreeParallelTarget -ParallelSlug -SessionRoot`: same shape keyed on
  `route_id -ceq 'parallel'` and `parallel_slug`; more than one match returns `Ambiguous`.
- `Resolve-WorktreeRunTargetByRecord -Kind epic|parallel -RecordField pr_number|worktree_path -Value -SessionRoot`:
  keeps live roots whose run checkpoint records the value (`epic_merge_pr.pr_number`,
  `features[].pr_number`, `features[].worktree_path` for epic; `items[].pr_number`,
  `items[].worktree_path` for parallel), same zero/one/many rule. Path comparison normalises
  separators and trailing slashes and is case-insensitive on Windows paths.

Gate-side:
- Preimplementation gate: a resolution seam (for example `Resolve-OrchestrationGateRunTarget`) in
  the epic-scope sibling; `Get-CheckpointContent`, `Get-EpicCheckpointContent`, and
  `Get-ParallelCheckpointContent` take a mandatory absolute path with no relative default.
- `Resolve-EpicScopeCheckpoint`: the matched branch (text signal, or the effective worktree HEAD for
  command and path legs) is the key passed to `Resolve-WorktreeEpicTarget`; the checkpoint path is
  composed from the resolved root. `NoTarget` returns `IsEpicScope = $false` with the existing reason
  `epic-checkpoint-absent-or-unparseable`, so callers fall through to their per-feature resolution as
  today. `Ambiguous` returns `IsEpicScope = $false` with a new reason `target-worktree-ambiguous`;
  callers fall through to their per-feature resolution, which is itself fail-closed. The resolved
  checkpoint is read once through `Get-EpicScopeCheckpointText`.
- Wave barrier, cohort barrier, drift gate: one resolution seam each; the existing read-seam names
  are kept and take the resolved absolute path.
- Merge gate: bare `gh pr merge --merge` (no PR number) keeps the session-root read, which is correct
  by construction because it targets the current branch's PR. With an explicit PR number, the epic and
  parallel branches resolve with `Resolve-WorktreeRunTargetByRecord -RecordField pr_number`. The child
  branch keeps the session-root per-feature read (the child merges from its own isolated worktree)
  and adds a binding: when the per-feature checkpoint records `pr_gate.pr_number`, it must equal the
  command's PR number or the branch declines.
- Removal gates: `Resolve-WorktreeRunTargetByRecord -RecordField worktree_path` on the command's path.

#### Data flow and validation changes

Gate flow after this change: payload -> existing scope filter -> identity signal -> resolver ->
`switch ($target.Status)`: `SessionRoot`/`OtherWorktree` compose
`Join-WorktreeResolutionPath -WorktreeRoot $target.WorktreeRoot -RepoRelativePath <checkpoint>` and
read it; `NoTarget`/`Ambiguous` deny with the accessor code. Readiness predicates are unchanged.

Path leg: a `file_path` inside a worktree resolves to that worktree's checkpoint. A path inside no
worktree keeps the session-root read (today's strictness; no item owns that path, so no cross-item
approval is possible).

#### Error handling and logging updates

- Every deny message keeps its gate token, then states the reason code and the `Detail` clause.
- **Import failure fails closed (in scope for the new dependency).** Each converted gate imports
  `WorktreeRunResolution.psm1` (and `WorktreeItemResolution.psm1` where used) inside a guard that
  records the failure. The decision function checks that record before any other logic and returns a
  deny naming the module, and the entry point still emits JSON and exits 0. Today a failed import in
  these hooks leads to a non-zero exit, which PreToolUse treats as non-blocking (fail-open).
- **Out of scope, recorded as a follow-up:** fail-closed handling of pre-existing imports and
  dot-sources (for example `HookPayload.psm1`, the `-helpers`/`-modes` dot-sources) and of hooks this
  change does not convert.

#### Rollback/feature-flag considerations

No feature flag. Rollback is a revert of the gate commit concerned; the module commit is inert on its
own because nothing imports it.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

- Inputs: the hook payload fields already read by each gate (`tool_input.prompt`,
  `tool_input.file_path`, `tool_input.command`, `subagent_type`).
- Outputs: unchanged PreToolUse decision JSON; deny reasons gain the resolution reason code.

#### Required configuration keys and defaults

None added.

#### Backward-compatibility expectations

- Plain single-worktree sessions: unchanged decisions.
- Behaviour change: an `Agent` delegation to an implementation agent (`python-typed-engineer`,
  `powershell-typed-engineer`, `typescript-engineer`, `csharp-typed-engineer`, `atomic-executor`) or a
  non-mode `Agent(orchestrator)` delegation that carries neither the canonical issue-number line nor a
  `branch:` label now resolves `NoTarget` and is denied. The skill contract text is extended so
  documented callers carry both lines.
- An epic kickoff without `integration_branch:` or a parallel kickoff without `parallel_slug:` is
  denied with `TARGET_WORKTREE_NOT_DERIVABLE`. Both literals are already required by the kickoff
  templates.

#### Performance constraints

The run and item resolvers read one small file per live worktree per resolved call. Path and command
legs use operand ascent, not enumeration. No subprocess is started.

## Assumptions, Constraints, Dependencies

- Assumptions: git checks a branch out in at most one worktree (basis of the epic tie-break). Live
  worktrees are enumerable from on-disk git administrative files (`Get-WorktreeItemLiveRoot`).
- Constraints: PowerShell 7+; no Python; no temporary files or `TestDrive:` in tests; 500-line limit;
  hooks in this worktree are live for the session doing the work (settings commands are relative).
- External dependencies: none.

## Data / API / Config Impact

- User-facing changes: deny messages for unresolved targets name `TARGET_WORKTREE_NOT_DERIVABLE` or
  `TARGET_WORKTREE_AMBIGUOUS`.
- Data or migration: none. Checkpoint schemas are unchanged.
- Logging/telemetry: none beyond deny text.
- Compatibility: skill contract text extends the identity lines to more delegations.

## Test Strategy

- **Library tests** for `WorktreeRunResolution.psm1`: synthetic `/synthetic-worktrees/<name>` roots
  (the #709 convention); mock `Get-WorktreeItemLiveRoot` (unfiltered and `-Branch`) and
  `Get-WorktreeRunCheckpointText -ModuleName WorktreeRunResolution` returning in-memory JSON per path.
  Cover zero, one, and several matches; the branch tie-break reproducing the observed
  `13-45`/`14-15-epic-770` pair; slug disagreement; `route_id` mismatch; unparseable, array, and empty
  text; record matching on `pr_number` and `worktree_path`; signal extraction including
  `integration_branch:` inside the epic kickoff sentence.
- **Gate tests** per converted gate, following the PR #695 pattern
  (`enforce-model-routing-receipt.WorktreeResolution.Tests.ps1`): dot-source the hook, import library
  modules without `-Force`, mock the live-root enumeration with a closure, and use either committed
  fixtures under `tests/fixtures/worktree-resolution/` run inside
  `Invoke-WorktreeResolutionFixtureCall`, or a mocked single text-read function. For unresolved rows,
  mock the gate's resolution seam with `New-WorktreeResolutionFixtureTarget` and assert the read seam
  runs zero times.
- **Existing suites**: add a default `BeforeAll` mock of each new resolution seam returning a
  `SessionRoot` target, so existing rows do not enumerate the developer machine's worktrees. Existing
  rows are kept as regression guards.
- **Isolation guard (#737)**: add `Get-WorktreeRunCheckpointText` to the guard, mock it `$null` in
  every guarded suite that reaches it, and update the pinned read-count assertion to the new contract.
- **Prohibited**: temporary files, `TestDrive:`, wall-clock reads, subprocesses, network.
- **Coverage**: line coverage for `WorktreeRunResolution.psm1` at or above 85%; no regression on
  changed lines of converted files.
- **Toolchain**: PoshQC format -> analyze -> test (MCP), restarting on any failure or file change;
  pytest `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` for bundle parity.

## Acceptance Criteria

### Reproduction

- [ ] Reproduction, admitted: a Pester test models a session root `W_session` holding no epic checkpoint and a separate live worktree `W_epic` holding a ready `epic-orchestrator-state.json` (`route_id: "epic"`, `integration_branch: epic/repro-integration`); an `Agent(orchestrator)` payload carrying the epic kickoff line `Epic mode: true. epic_feature_folder: repro. integration_branch: epic/repro-integration. ...` is allowed by `enforce-orchestration-preimplementation-gate.ps1`, and the readiness read is asserted to target the path under `W_epic`.
- [ ] Reproduction, admitted at the barrier: the same payload and topology is allowed by `enforce-epic-wave-barrier.ps1` when the checkpoint's wave state permits the delegation, with the read asserted to target the path under `W_epic`.
- [ ] Reproduction, denied: the same payload with no live worktree holding an epic checkpoint is denied by `enforce-orchestration-preimplementation-gate.ps1` with a reason containing `PREIMPLEMENTATION_GATE_BLOCKED` and `TARGET_WORKTREE_NOT_DERIVABLE`, and by `enforce-epic-wave-barrier.ps1` with a reason containing `EPIC_WAVE_BARRIER_BLOCKED` and `TARGET_WORKTREE_NOT_DERIVABLE`.

### Run-resolution module

- [ ] `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` exists and exports `Find-WorktreeRunIdentitySignal`, `Get-WorktreeRunCheckpointText`, `Resolve-WorktreeEpicTarget`, `Resolve-WorktreeParallelTarget`, and `Resolve-WorktreeRunTargetByRecord`.
- [ ] Every resolver in the module returns an object with `Status` (one of `SessionRoot`, `OtherWorktree`, `NoTarget`, `Ambiguous`), `WorktreeRoot`, `SessionRoot`, `Signal`, `SignalValue`, `Candidates`, `ReasonCode`, and `Detail`, built through `New-WorktreeResolutionTargetResult`, with `ReasonCode` equal to `TARGET_WORKTREE_NOT_DERIVABLE` for `NoTarget` and `TARGET_WORKTREE_AMBIGUOUS` for `Ambiguous`, obtained from the existing accessors.
- [ ] `Find-WorktreeRunIdentitySignal` returns the integration branch from the literal `integration_branch: <name>` inside the epic kickoff sentence (including when followed by `.`), the slug from `epic_feature_folder: <slug>`, and the slug from `parallel_slug: <slug>`, matched case-sensitively, and returns `$null` fields when a literal is absent.
- [ ] `Resolve-WorktreeEpicTarget` returns `NoTarget` for an empty branch and for zero matching live roots, resolves a single match, and returns `Ambiguous` when a supplied `-EpicSlug` disagrees with a match's `epic_feature_folder`.
- [ ] Tie-break: with matching epic checkpoints at the session root and at a second live worktree, `Resolve-WorktreeEpicTarget` resolves `OtherWorktree` to the worktree that has the integration branch checked out; when no match or more than one match has the branch checked out, it returns `Ambiguous` with a `Detail` that names `artifacts/orchestration/handoff/` as the remedy.
- [ ] A live root whose checkpoint text is absent, empty, unparseable, a JSON array, has a `route_id` other than the expected run kind, or has a different `integration_branch`/`parallel_slug` is never counted as a match.
- [ ] `Resolve-WorktreeParallelTarget` resolves exactly one matching live root by `route_id -ceq 'parallel'` and `parallel_slug`, and returns `Ambiguous` when more than one live root matches.
- [ ] `Resolve-WorktreeRunTargetByRecord` resolves epic checkpoints by `epic_merge_pr.pr_number` or `features[].pr_number`, epic checkpoints by `features[].worktree_path`, and parallel checkpoints by `items[].pr_number` or `items[].worktree_path`, with the same zero/one/many rule; `worktree_path` comparison is insensitive to separator style and trailing slashes.
- [ ] `Get-WorktreeRunCheckpointText` is the module's only filesystem read, and no function in the module starts a subprocess, reads the payload `cwd`, reads a wall clock, reads an environment variable, or accesses the network.
- [ ] `ConvertTo-WorktreeItemResolvedResult` is exported from `WorktreeItemResolution.psm1`, and `WorktreeRunResolution.psm1` uses it for `SessionRoot`/`OtherWorktree` labelling rather than a second implementation.

### Preimplementation gate

- [ ] Epic-mode delegations resolve through `Resolve-WorktreeEpicTarget` keyed on the payload's `integration_branch:` value, after the existing declared-path cross-check, and read `epic-orchestrator-state.json` beneath the resolved root.
- [ ] Parallel-mode delegations resolve through `Resolve-WorktreeParallelTarget` keyed on `parallel_slug:`, and read `parallel-orchestrator-state.json` beneath the resolved root.
- [ ] Single-feature `Agent` delegations to an allow-listed implementation agent, and non-mode `Agent(orchestrator)` delegations, resolve through `Resolve-WorktreeItemTarget` and read `orchestrator-state.json` beneath the resolved root; `NoTarget` and `Ambiguous` deny with `PREIMPLEMENTATION_GATE_BLOCKED:` and the accessor reason code.
- [ ] A `Write`/`Edit` whose absolute `file_path` lies inside a worktree other than the session root is evaluated against that worktree's `orchestrator-state.json`, and is allowed when that checkpoint is ready and denied when it is absent or not ready.
- [ ] A Bash command leg with a `git -C <dir>` selector inside another worktree is evaluated against that worktree's checkpoint; a command with no selector is evaluated against the session root.
- [ ] `Get-CheckpointContent`, `Get-EpicCheckpointContent`, and `Get-ParallelCheckpointContent` take a mandatory absolute path, and no relative checkpoint literal is passed to `Test-Path` or `Get-Content` by the gate or its dot-sourced siblings.
- [ ] Bound `-CheckpointRaw`, `-EpicCheckpointRaw`, and `-ParallelCheckpointRaw` values bypass resolution, and the existing preimplementation suites pass unchanged in their assertions.

### Epic-scope resolution (`Resolve-EpicScopeCheckpoint`)

- [ ] `Resolve-EpicScopeCheckpoint` composes its checkpoint path from the root returned by `Resolve-WorktreeEpicTarget` for the matched branch, not from the session root, and a test shows an epic-scope command leg on the integration branch resolving the checkpoint held by a different live worktree.
- [ ] When no live worktree holds a matching epic checkpoint, `Resolve-EpicScopeCheckpoint` returns `IsEpicScope = $false` with reason `epic-checkpoint-absent-or-unparseable`; when resolution is ambiguous, it returns `IsEpicScope = $false` with reason `target-worktree-ambiguous`; in both cases callers fall through to their existing per-feature resolution.
- [ ] The epic-scope suites for `enforce-model-routing-receipt.ps1` and `enforce-pr-author-skill.ps1` pass, and neither hook file is edited.

### Epic wave barrier and parallel cohort barrier

- [ ] `enforce-epic-wave-barrier.ps1` resolves its epic checkpoint through `Resolve-WorktreeEpicTarget` keyed on `integration_branch:`, reads it beneath the resolved root through its existing read seam, and denies `NoTarget`/`Ambiguous` with `EPIC_WAVE_BARRIER_BLOCKED:` and the accessor reason code.
- [ ] `enforce-parallel-cohort-barrier.ps1` resolves its parallel checkpoint through `Resolve-WorktreeParallelTarget` keyed on `parallel_slug:`, reads it beneath the resolved root through its existing read seam, and denies `NoTarget`/`Ambiguous` with its existing leading token and the accessor reason code.
- [ ] `Find-EpicWaveBarrierFeatureFolderFromPrompt` is unchanged (issue #565 scope).

### Merge gate

- [ ] Epic branch: `gh pr merge --merge <PR>` with an explicit PR number resolves the epic checkpoint through `Resolve-WorktreeRunTargetByRecord -Kind epic -RecordField pr_number`, and a test shows the merge allowed when the matching ready epic checkpoint is only in a worktree other than the session root.
- [ ] Parallel branch: `gh pr merge --merge <PR>` with an explicit PR number resolves the parallel checkpoint through `Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField pr_number`, and a test shows the merge allowed when the matching checkpoint is only in a worktree other than the session root.
- [ ] Child branch: when the session-root per-feature checkpoint records `pr_gate.pr_number` and it differs from the command's PR number, the child branch declines; when they are equal, the existing child-branch decision is unchanged.
- [ ] A bare `gh pr merge --merge` with no PR number is evaluated against the session root exactly as before.
- [ ] When the epic and parallel branches resolve `NoTarget` or `Ambiguous` and no other allow condition applies (including standalone-merge authorization), the gate denies with its existing leading token and the accessor reason code.

### Worktree-removal gates

- [ ] `enforce-epic-worktree-removal-gate.ps1` resolves the run checkpoint for `git worktree remove <path>` through `Resolve-WorktreeRunTargetByRecord -RecordField worktree_path`, allows the removal when the resolved checkpoint (in a worktree other than the session root) authorizes it, and denies `NoTarget`/`Ambiguous` with its existing leading token and the accessor reason code.
- [ ] `enforce-parallel-worktree-removal-gate.ps1` resolves the run checkpoint through `Resolve-WorktreeRunTargetByRecord -RecordField worktree_path` with the same allow and deny behaviour.

### Parallel drift gate

- [ ] `enforce-parallel-drift-gate.ps1`, for a payload inside its existing scope filter, resolves the parallel checkpoint through `Resolve-WorktreeParallelTarget` keyed on `parallel_slug:`, reads it beneath the resolved root, and denies `NoTarget`/`Ambiguous` with its existing leading token and the accessor reason code.

### Import failure (fail-closed)

- [ ] In each converted gate, a failure to import `WorktreeRunResolution.psm1` or `WorktreeItemResolution.psm1` produces a deny decision that names the module, the entry point emits the decision JSON and exits 0, and a Pester test per converted gate simulates the failure through the recorded-failure state without deleting or renaming any file.
- [ ] Fail-closed handling of pre-existing imports and dot-sources, and of hooks this change does not convert, is out of scope; a potential entry recording it exists under `docs/features/potential/`.

### Plain single-worktree regression guards

- [ ] A `Write`/`Edit` to a path inside the session worktree, and a Bash command with no `-C` selector, are evaluated against the session root's `orchestrator-state.json` with the same decision as before this change.
- [ ] An epic or parallel kickoff whose only matching checkpoint is at the session root resolves `SessionRoot` and yields the same decision as before this change in the preimplementation gate, the wave barrier, and the cohort barrier.
- [ ] A stale matching epic checkpoint at the session root does not win over the worktree that has the integration branch checked out (no session-root-first fast path).

### Identity contract (documented callers)

- [ ] `.claude/skills/orchestrate/SKILL.md` `## Issue Number Consistency` requires the canonical issue-number line and a `branch: <name>` label on delegations to `python-typed-engineer`, `powershell-typed-engineer`, `typescript-engineer`, `csharp-typed-engineer`, and on non-mode `Agent(orchestrator)` delegations, and names `enforce-orchestration-preimplementation-gate.ps1` among the gates that identify the item from those lines.
- [ ] `.claude/skills/epic-orchestrate/SKILL.md` and `.claude/skills/parallel-orchestrate/SKILL.md` state that the typed-engineer identity lines apply to their child runs, and that the gates key epic runs on `integration_branch:` and parallel runs on `parallel_slug:`.
- [ ] Each `.claude/skills/invoke-*-engineer/SKILL.md` that delegates to an allow-listed implementation agent documents the canonical issue-number line and `branch:` label in its delegation prompt.
- [ ] The contract text changes land no later than the commit that wires the preimplementation gate.

### Registration, mirrors, and guard test

- [ ] Each `.claude` file created or changed by this work has a byte-identical mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/`, and `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes.
- [ ] `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1` appears once in the `paths` array of `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and any new dot-sourced hook sibling created by this work is also listed there.
- [ ] `tests/scripts/claude-lib/worktree-resolution/WorktreeResolution.Manifest.Tests.ps1` lists `WorktreeRunResolution.psm1` in each of its module lists and passes, including the on-disk registration row and the SHA-256 mirror row.
- [ ] `WorktreeRunResolution.psm1` is added to `CodeCoverage.Path` in both `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`, and the two copies remain text-identical.
- [ ] `tests/scripts/claude-hooks/enforce-gate-suites.EpicStateIsolation.Tests.ps1` guards `Get-WorktreeRunCheckpointText` as well as `Get-EpicScopeCheckpointText`, its pinned read-count assertion matches the new `Resolve-EpicScopeCheckpoint` contract, each suite it guards that reaches the new seam mocks it `$null`, and the suite passes.

### Tests and determinism

- [ ] Each converted gate has Pester rows for (a) a checkpoint present only in a synthetic target worktree that differs from the session root, allowed or evaluated against that checkpoint, (b) a target with no checkpoint anywhere, denied with `TARGET_WORKTREE_NOT_DERIVABLE`, and (c) an ambiguous target, denied with `TARGET_WORKTREE_AMBIGUOUS`.
- [ ] Gate and library tests use the PR #695 seam (a mocked live-root enumeration with committed fixtures, or a mocked single text-read function); no test creates, writes, or deletes a file, and no test uses `TestDrive:`.
- [ ] Every existing suite for a converted gate mocks the new resolution seam in `BeforeAll` so that no existing row enumerates live worktrees on the host, and every existing row passes.
- [ ] Line coverage for `WorktreeRunResolution.psm1` is at or above 85%, read per file from the Pester coverage report, and changed lines in converted files show no coverage regression against the baseline recorded under `evidence/baseline/`.
- [ ] `WorktreeRunResolution.psm1` satisfies `tests/scripts/claude-lib/ClaudeLibModuleConvention.Tests.ps1`, and `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes with the new module in its scan scope.

### File size

- [ ] `WorktreeResolution.psm1` and `enforce-orchestration-preimplementation-gate-helpers.ps1` are byte-unchanged.
- [ ] `enforce-orchestration-preimplementation-gate.ps1`, `enforce-epic-merge-gate.ps1`, `enforce-orchestration-preimplementation-gate-modes.ps1`, `enforce-epic-merge-gate-authorization.ps1`, `enforce-orchestration-preimplementation-gate-epic-scope.ps1`, `WorktreeRunResolution.psm1`, and every other production or test file created or edited by this work are at or below 500 lines.
- [ ] `enforce-orchestration-preimplementation-gate-modes.ps1` gains no identity-parsing logic, and the preimplementation gate's resolution glue and `Get-CheckpointContent` live in `enforce-orchestration-preimplementation-gate-epic-scope.ps1`.

### Rollout safety

- [ ] The commit that adds `WorktreeRunResolution.psm1` (with its export change, mirror, `core.json` entry, manifest test, runsettings entries, and library tests) changes no hook file, and no hook imports the module at that commit.
- [ ] Each gate is wired by a single complete `Write` of each hook file it changes (no sequence of partial `Edit` calls on a live hook), followed by that gate's Pester suites before the next gate is wired; the order of writes and each suite result is recorded under `evidence/qa-gates/` in this feature folder.
- [ ] Before the preimplementation gate commit, the executor confirms and records under `evidence/qa-gates/` that the session's own pending implementation delegations carry the canonical issue-number line and `branch:` label.
- [ ] Each gate is committed together with its dot-sourced siblings and mirrors, so no commit leaves a hook importing a function that is absent at that commit.

### Toolchain and follow-ups

- [ ] The PowerShell toolchain (PoshQC format, then analyze, then test) completes in a single pass with no failure and no modified file, and the observed output is recorded under `evidence/qa-gates/`.
- [ ] No file under `.codex/`, no Python file, and neither `validate-orchestrator-output.ps1` nor `Find-EpicWaveBarrierFeatureFolderFromPrompt` is changed.
- [ ] Potential entries under `docs/features/potential/` record the session-relative read in `validate-orchestrator-output.ps1` (SubagentStop) and the merge-gate child-branch residual for routes without `pr_gate.pr_number`.

## Risks & Mitigations

- **Live-hook lockout or fail-open during implementation.** Hooks in this worktree are live for the
  session. Mitigation: module lands first with no importer; each gate is written in one `Write` and
  tested before the next; converted gates deny on import failure; commits keep each hook and its
  siblings consistent.
- **Newly deniable delegations.** Implementation-agent delegations without identity lines are denied.
  Mitigation: contract text lands no later than the preimplementation gate; the executor confirms the
  session's own delegations carry the lines.
- **Host-dependent test results.** An unmocked resolver would read gitignored checkpoints on a
  developer machine (one exists at this worktree's root). Mitigation: default `BeforeAll` mocks and
  the #737 guard extension.
- **Merge-gate child-branch residual.** Routes without `requires_pr_gate` have no
  `pr_gate.pr_number`, so the binding does not apply. Mitigation: recorded as a follow-up; checkpoint
  hygiene limits exposure.
- **Isolated subagents run main's hooks.** The fix does not govern isolated children until it merges.
- **Drift-gate marker forwarding is unverified.** Neither `.claude/agents/orchestrator.md` nor
  `.claude/skills/orchestrate/SKILL.md` contains `Parallel mode: true`. The drift-gate change applies
  only inside its existing scope filter, so an unforwarded marker leaves the gate out of scope as
  today.
- **Concurrent edits** with #565 (wave barrier) and #737 (guard list). Mitigation: sequence, and
  rebase whichever lands second.

## Rollout & Follow-up

- Release/rollout steps, in order: (1) module, export line, `core.json`, manifest test, runsettings,
  mirrors, library tests; (2) preimplementation gate with its siblings, mirrors, and the skill
  contract text; (3) wave barrier and cohort barrier; (4) merge gate, then removal gates, then drift
  gate; (5) `Resolve-EpicScopeCheckpoint` with the #737 guard update and affected suites.
- Post-fix: the next epic run launched from a non-epic session root is expected to pass the
  preimplementation gate and wave barrier; `validate-orchestrator-output.ps1` may still block
  epic-orchestrator termination in that topology until its follow-up lands.
- Links: issue #690; epic #678; #669, #671, #687, PR #695, PR #726; related #565, #736, #737.
