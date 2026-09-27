# codex-gates-4-5-lack-epic-scope (Spec)

- **Issue:** #707
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-27T01-30
- **Status:** Draft
- **Version:** 0.3
- **Work Mode:** full-bug (the acceptance-criteria source is this file only; no `user-story.md` is produced)
- **Branch:** `bug/codex-gates-4-5-lack-epic-scope-707`
- **Research:** `docs/features/active/codex-gates-4-5-lack-epic-scope-707/research/research.2026-09-26T23-00.md`
- **Precedent:** #663, merged to `main` as PR #700 (merge commit `ae8d2ce3`); spec at `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/spec.md`
- **Decision mode:** Autonomous. Per the user instruction of 2026-09-26, every design decision below adopts the researcher's recommendation or the #663 precedent without an operator-review hold.

## Context

- **Summary.** Issue #663 (PR #700) added an epic-level checkpoint seam to the Claude preimplementation gate (gate 4) and pinned the Claude completion-consistency gate (gate 5) with tests. #663 decision D1 deferred the same work on the Codex surface. As a result, the Codex gate-4 hook `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` still evaluates every implementation-classified command, apply_patch, Edit, and Write call against the per-feature checkpoint `artifacts/orchestration/orchestrator-state.json` with a `docs/features/active/` feature-folder rule. A Codex-driven epic coordinator, which holds only `artifacts/orchestration/epic-orchestrator-state.json`, is denied with `PREIMPLEMENTATION_GATE_BLOCKED` when it stages main-sync merge resolutions on the integration branch.
- **Observed environment.** Any OS running the Codex runtime with PowerShell 7 hooks registered through `.codex/config.toml` (`^Bash$` at line 120 and `^(apply_patch|Edit|Write)$` at line 186). Python is not involved; the hooks are PowerShell-only.
- **Customer impact and severity.** Medium (per `issue.md`). Every Codex-driven epic that reaches a main-sync merge on its integration branch is affected. Claude-driven epics are not affected after #663.
- **First observed.** Recorded as follow-up item 1 of #663 (`docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/evidence/other/follow-ups.md`). Current-tree state was re-verified by research on 2026-09-26 against base `218b518e`.

## Repro & Evidence

- **Steps to reproduce.**
  1. Run an epic through the Codex surface so the session root holds `artifacts/orchestration/epic-orchestrator-state.json` with `route_id: "epic"` and an `integration_branch`, and no per-feature checkpoint (the #673 hygiene rule).
  2. On the integration branch, during a `git merge origin/main`, issue `git add <resolved production path>` (Bash), or apply a patch or Edit/Write to a production path.
  3. Observe `PREIMPLEMENTATION_GATE_BLOCKED` from `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`.
  4. Separately, write a completion-asserting update to `artifacts/orchestration/epic-orchestrator-state.json` through Write, Edit, or apply_patch.
- **Expected.** Step 2 is decided against the epic checkpoint exactly as the Claude gate decides it after #663: allowed when the epic checkpoint is ready and a merge is in progress in the effective worktree, denied with a reason that names the epic checkpoint and the failed conjunct otherwise. Step 4 is not intercepted by gate 5. Single-feature behaviour is unchanged.
- **Actual (current tree, per research section 2).**
  - Gate 4: the command and path legs go directly to the mode block (Codex gate lines 430-449) and then to `Test-OrchestrationReady` with `docs/features/active/` (lines 248-276, 451-463). No epic-scope hook-in exists. This is the AC-1 defect.
  - Gate 5: `Test-IsCheckpointPath` in `.codex/hooks/enforce-completion-consistency.ps1` (lines 96-105) matches only `(^|/)artifacts/orchestration/orchestrator-state\.json$`, so the epic checkpoint is not intercepted (lines 361-364 allow). For an apply_patch Update, `ConvertTo-CodexFileEditInput -GovernedPath` emits no record for the ungoverned epic path (`.codex/hooks/codex-pretooluse-file-mapping.ps1:299-305`). The Codex gate 5 therefore already behaves as the Claude gate 5 behaves after #663; see D6 and D12.
- **Logs.** See `issue.md` "Logs / Screenshots" and #663 `evidence/qa-gates/p7-d1-scope.md` (empty diff for the three Codex hooks under #663).
- **Frequency.** Deterministic for gate 4 whenever the conditions in step 1 and step 2 hold.

## Scope & Non-Goals

- **In scope.**
  - A Codex-local, dot-sourced port of the #663 gate-4 epic-scope seam: resolver, command-leg readiness predicate, `git -C` selector, and epic-scope decision (D1-D5, D13).
  - Wiring the Codex gate-4 hook to consult the epic-scope decision on the command, apply_patch, and path legs, in the same position the Claude gate uses.
  - Relocation of the two per-mode read seams out of the Codex gate to restore line headroom (D5).
  - Gate-5 pinning tests only, with no production change to either Codex gate-5 file (D6, D12).
  - Bundle byte copies, pack-manifest registration, and Pester coverage registration for new and changed Codex hook files (D7, D8).
  - Hermetic mocks of the epic checkpoint read seam in existing in-process Codex gate-4 suites that the port would otherwise expose to local epic state (D10).
- **Out of scope / non-goals.**
  - Any change under `.claude/` (the Claude side was completed by #663).
  - Any change to the four byte-identical copies of `enforce-orchestration-preimplementation-gate-helpers.ps1` (owned by sibling #710 in this parallel run).
  - Any change to `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, or `.codex/hooks/enforce-completion-helpers.ps1`.
  - Pre-existing, non-epic Codex/Claude divergences (malformed-input throw in Codex gate 4; unresolved-Edit and invalid-JSON denies in Codex gate 5; `codex-pretooluse-file-mapping.ps1` dot-source; `Get-StringProperty`). They are retained (D14).
  - The Codex delegation leg. No Agent matcher reaches the Codex gate (`.codex/config.toml`; #554 D5), so the delegation leg is unchanged.
  - Changes to `scripts/dev_tools/push_down_codex_and_agents_customizations.py` or introduction of a `.codex/lib/` folder.
  - Claude-surface test suites under `tests/scripts/claude-hooks/` (sibling #709 owns the equivalent remedy there).
- **Explicitly excluded systems.** Live GitHub and a live epic are not used by any automated test. A manual Codex epic main-sync rerun is an optional follow-up and is not required by any acceptance criterion.

## Root Cause Analysis

- **Confirmed root cause.** The Codex gate-4 hook resolves exactly one checkpoint family for the command and path legs: the cwd-relative per-feature `artifacts/orchestration/orchestrator-state.json`, validated with a `docs/features/active/` prefix. It has no function that decides whether a call is an epic-level operation, and it never reads `epic-orchestrator-state.json` on those legs. #663 added that decision to the Claude gate only, by D1.
- **Contributing constraint.** The Codex gate file is at the 500-line cap (research 2.1; enforced by `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:93-108`). The Codex hooks share code only through `. (Join-Path $PSScriptRoot '<file>.ps1')` siblings and cannot import `.claude/lib` modules, because the Codex bundle does not contain them and `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` runs every bundled hook from the bundle root (research 2.3).
- **Gate 5.** No defect on the Codex surface relative to the post-#663 Claude behaviour. The issue's Actual Behavior statement that the two Codex gate-5 files are "unchanged" is accurate, but no change is required for them to satisfy AC-2 (D12).
- **Affected components.** `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and its bundle copy.

## Design Decisions

Each decision states the options considered, the adopted option, and the rationale. D1-D11 carry over research section 5. D12-D15 are added to cover AC-2 reconciliation, the Codex-specific apply_patch leg, retained divergences, and the no-Python authority; D16 records the AC-25 wording amendment, D17 records the AC-7 ready-fixture amendment, and D18 records the AC-16 runner-wording amendment.

- **D1 — Resolver placement.**
  - Options: (A) a Codex-local, dot-sourced port in `.codex/hooks/`; (B) `Import-Module` of `.claude/lib/worktree-resolution/*.psm1` from `.codex/hooks`; (C) byte-identical copies of the four `.claude/lib/worktree-resolution` modules under a new `.codex/lib/`, loaded with `Import-Module`; (D) the codex-routing virtual-resource pattern (`VIRTUAL_RESOURCE_PAIRS` in the Python push-down script).
  - Adopted: A. Two new dot-sourced siblings: `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1`.
  - Rationale: B breaks Codex-only installs and the bundle hook probe. C copies about 1,400 lines, most unused, and neither the pack-manifest completeness test nor the core-closure test follows `Import-Module`. D requires a Python push-down change and missing-module tolerance at the bundle root. A follows the Codex dot-source convention, keeps the bundle self-contained, and is covered by both manifest guards. This is the intentional divergence from #663's module placement recorded under issue AC-5.

- **D2 — Seam names and decision set.**
  - Options: identical names, reason codes, and conjunct order to #663; or Codex-specific names.
  - Adopted: identical. Public seam names `Get-EpicScopeCheckpointText`, `ConvertFrom-EpicScopeCheckpointText`, `Get-EpicScopeWorktreeGitDirectory`, `Get-EpicScopeWorktreeHeadBranch`, `Test-EpicScopeMergeInProgress`, `Resolve-EpicScopeCheckpoint`, `Get-EpicCommandLegReadinessFailure`, `Get-OrchestrationEpicScopeSelector`, and `Get-OrchestrationEpicScopeDecision`. Resolver reason codes `no-branch-signal`, `session-root-unresolved`, `epic-checkpoint-absent-or-unparseable`, `route_id`, `integration_branch`, `selector-unresolved`, `branch-mismatch`, `epic-scope`. Predicate conjunct order `checkpoint-absent`, `route_id`, `epic_feature_folder`, `epic_manifest_path` (must match `(^|/)docs/features/epics/`), `integration_branch`, `features`, `merge-in-progress`. Deny-reason format identical to `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:126`. The #663 D2 merge-in-progress rule is carried over: in epic scope an implementation-classified operand is allowed only while `MERGE_HEAD` exists in the effective worktree's git directory.
  - Rationale: issue AC-5 requires the same seam and decision set; identical names let the Codex suites mirror the Claude EpicScope suite row for row. Ported worktree primitives keep their `WorktreeResolution` function names. Codex suites must not import the Claude modules, so that a module export cannot shadow the dot-sourced functions.

- **D3 — Resolver scope.**
  - Options: port both text-branch-signal and head-matching modes with the `-MatchWorktreeHead` switch; or port head-matching only with a fixed contract.
  - Adopted: head-matching only. The `-MatchWorktreeHead` switch is removed and the Codex `Resolve-EpicScopeCheckpoint` always decides scope from the effective worktree HEAD. `Find-WorktreeResolutionBranchSignal` is not ported.
  - Rationale: gate 4 uses only head-matching mode, and the text branch signal is ignored on the command and path legs (#663 remediation CR-2; resolver lines 335-338). Removing the switch avoids a dead branch that would lower coverage. The removal is a recorded signature divergence under issue AC-5.

- **D4 — Caller-identity signal.**
  - Options: session-root epic checkpoint plus HEAD match with session root from `(Get-Location).Path` (#663); the Codex payload `cwd` field; an `agent_type` envelope field.
  - Adopted: the #663 signal.
  - Rationale: #663 reads no envelope caller field. The Codex hook process is started as `pwsh -NoProfile -File "$(git rev-parse --show-toplevel)/..."` (`.codex/config.toml:136,220`), so `(Get-Location).Path` is the session root. Reading payload `cwd` would add a Codex-only input. Payload `cwd` and `agent_type` are rejected.

- **D5 — Line headroom.**
  - Options: move `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent` out of the Codex gate into the epic-scope sibling (#663 [P5-T4]); compress unrelated code in the gate.
  - Adopted: move the two read seams verbatim, names unchanged.
  - Rationale: frees 26 lines against about 12 needed for the dot-source line and the epic-scope call. Existing suites that use the seams by name (`tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1:14,173`) still reach them through the gate's dot-source.

- **D6 — Gate 5.**
  - Options: modify `.codex/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-helpers.ps1` to recognise the epic checkpoint; or make no production change and pin behaviour with tests (#663 D3).
  - Adopted: no production change; D3-style pinning tests in a new suite.
  - Rationale: see D12.

- **D7 — Dot-source form and manifest registration.**
  - Options: any dot-source form; the exact `. (Join-Path $PSScriptRoot '<file>.ps1')` form.
  - Adopted: every new dot-source line is written exactly as `. (Join-Path $PSScriptRoot '<file>.ps1')`. The gate dot-sources the epic-scope sibling; the epic-scope sibling dot-sources the resolution sibling. Both new files are registered in `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` next to the existing gate entries (lines 41-42 and 53).
  - Rationale: `tests/scripts/dev_tools/test_codex_core_manifest_closure.py:53` follows only that form, and the completeness test requires every `.codex/hooks` file to be registered.

- **D8 — Bundle mirrors.**
  - Adopted: each new or changed `.codex/hooks` file is copied byte-for-byte to `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` after each batch, not re-authored.
  - Rationale: `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:215-228` and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:111-117` enforce identity.

- **D9 — Test layout.**
  - Options: extend shared legacy suites; add one new suite per new or changed production concern.
  - Adopted: new suites under `tests/scripts/codex-hooks/`, Arrange-Act-Assert, seams mocked by name without `-ModuleName`, `/synthetic-worktrees/...` roots as in the Claude EpicScope suite, no files created and no directory changed.
  - Rationale: keeps the change set separate from siblings and keeps tests hermetic on Linux CI.

- **D10 — Existing in-process Codex gate-4 suites exposed to local epic state.**
  - Options: add a `Mock Get-EpicScopeCheckpointText { $null }` in `BeforeAll`/`BeforeEach` of each exposed suite in #707; defer to a follow-up as #663 did with CR-4.
  - Adopted: add the mocks in #707, as a separate batch, without changing any existing assertion.
  - Rationale: after the port, in-process suites that drive implementation-classified command or path legs call the real epic checkpoint read and HEAD read, which is the #709 hazard class on the Codex surface; #709 covers Claude suites only. The exposed suites were confirmed by reading each file for `Invoke-OrchestrationPreimplementationGateDecision` calls on command or path legs: `codex-preimplementation-gate-absolute-paths.Tests.ps1`, `enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`, `codex-pretooluse-transport.Tests.ps1`, and the in-process contexts of `legacy-codex-hook-contracts.Tests.ps1`. `enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1` drives only delegation legs and is not exposed. Child-process rows cannot be mocked; they remain deny-robust because an epic-scope deny still carries `PREIMPLEMENTATION_GATE_BLOCKED`.

- **D11 — Sibling overlap.**
  - Adopted: the rules in `## Merge-Order Independence`.
  - Rationale: research section 6.

- **D12 — AC-2 reconciliation for the Codex gate-5 hooks.**
  - Options: (a) modify `.codex/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-helpers.ps1` so they have a visible epic seam; (b) satisfy AC-2 by pinning tests only, as #663 D3 did on the Claude side.
  - Adopted: (b). `.codex/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-helpers.ps1`, and their bundle copies, are not modified.
  - Rationale: the "seam" the Claude gate 5 uses after #663 is non-interception of `artifacts/orchestration/epic-orchestrator-state.json`; #663 made no Claude gate-5 production change. The Codex gate 5 already has that property: `Test-IsCheckpointPath` uses the same regex as the Claude copy, and the apply_patch mapper emits no record for an Update to the ungoverned epic path. `Test-IsValidFeatureFolder` still requires `docs/features/active/`, which is the per-feature deny that Claude D3 kept. The issue's Actual Behavior text ("The three Codex hooks are unchanged") is factually correct, but its implied premise that the two gate-5 files need a code change does not hold. AC-2 is therefore met by pinning the existing behaviour with tests (AC-8 to AC-10 below), and any change to those files would add risk without changing a decision. Keeping them untouched also avoids overlap with sibling #708.

- **D13 — apply_patch leg.**
  - Options: treat apply_patch as a path leg by extracting file markers; keep the existing Codex classification, where the entry point passes the raw `tool_input` (patch in `command`) to the decision and `Test-ImplementationCommand` classifies it as a command leg.
  - Adopted: keep the existing classification. The epic-scope decision receives the patch text as `-Command`; it yields no `git -C` selector, so the session-root HEAD decides scope, which matches the path leg.
  - Rationale: no change to `Test-ImplementationCommand` (lines 127-176), which also keeps the gate edit away from sibling #713's region. This is a Codex-only leg with no Claude counterpart and is recorded under issue AC-5.

- **D14 — Retained pre-existing divergences.**
  - Options: align the Codex hooks with the Claude hooks where they differ; retain the differences.
  - Adopted: retain. The Codex gate still throws on malformed mapped `tool_input` (lines 385-392); Codex gate 5 still denies an unresolved Edit patch and invalid JSON; the delegation leg and the modes file are unchanged.
  - Rationale: none of these is epic-related; changing them is outside issue #707 and would alter AC-3 single-feature behaviour.

- **D15 — PowerShell authority and no Python.**
  - Options: rely on `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`; add a Codex-specific check.
  - Adopted: the new sibling headers declare the epic readiness predicate PowerShell-authoritative (#663 D5), and the new gate-4 suite asserts that the three new or changed gate-4 files contain no `python` or `poetry` token.
  - Rationale: the existing no-Python guard scans only `.claude/hooks` and `.claude/lib` (its `$script:ScanRoot`), so it does not cover `.codex/hooks`.

- **D16 — AC-25 wording for the unchanged gate classifier.**
  - Options: (A) keep the AC-25 literal wording (no `python` or `poetry` token in any AC-18 file) and leave AC-25 permanently unchecked; (B) amend AC-25 to state what is verified: the parser-based `Get-PythonInvocationFinding` detector reports no interpreter invocation in the three Codex gate-4 files and their bundle copies, and the two new sibling files contain neither token.
  - Adopted: B. AC-25 is reworded accordingly and remains unchecked until its tests pass; the token check stated in D15 applies to the two new siblings, and the gate file is covered by the invocation detector.
  - Rationale: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:152` already carries the literal `poetry` inside the `Test-ImplementationCommand` classifier regex, which recognises a Python toolchain command rather than invoking one. D13 forbids editing that function, so the literal condition could never pass, and it tests a classifier pattern rather than an invocation. Decision recorded autonomously by the orchestrator after executor preflight round 1.

- **D17 — AC-7 ready-fixture return value.**
  - Options: (A) the Codex `Get-EpicCommandLegReadinessFailure` returns `$null` for the ready fixture, satisfying the original AC-7 literal; (B) the Codex port keeps `return ''`, matching `.claude/lib/worktree-resolution/EpicScopeReadiness.psm1:173`, and AC-7 is amended to expect an empty result.
  - Adopted: B. AC-7 states that the ready fixture yields an empty result (the empty string, as the #663 predicate does; asserted with `Should -BeNullOrEmpty`) and remains unchecked until its tests pass.
  - Rationale: D2 requires behaviour identical to #663, whose predicate returns the empty string when ready. The only caller tests the value with `-not $failure` (`.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1:123`, ported unchanged to the Codex epic-scope sibling), so `$null` and the empty string decide alike. Mirroring the precedent avoids an unrecorded divergence from #663. Decision recorded autonomously by the orchestrator after executor preflight round 2.

- **D18 — AC-16 CI runner wording (spec deviation).**
  - Options: (A) keep "(Linux runner)" and leave AC-16 permanently unchecked; (B) amend the runner wording to the repository's actual CI Pester job and check AC-16 off on that run.
  - Adopted: B. AC-16's runner wording is amended from "(Linux runner)" to "(windows-latest, the repository's only CI Pester job)". AC-16 is checked off on PR #725 workflow run 36317849720, job 108615836563 (`poshqc / PowerShell QC`, head b7aff51d): 5416 passed, 0 failed, 9 skipped, with all eight named suites passing and no `artifacts/orchestration/*.json` present in the CI checkout.
  - Rationale: the original wording assumed a Linux Pester job that does not exist; `.github/workflows/_poshqc.yml` declares `runs-on: windows-latest` and is the only CI Pester run. Linux execution of these suites is not verified; the local hermeticity scan is the supporting evidence for portability, and a Linux Pester leg is recorded as a follow-up. Decision directed by the parallel-run coordinator on 2026-09-27 and recorded by the orchestrator.

## Proposed Fix

### Design summary (what changes where):

1. New `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1`: the head-matching resolver (D3) with the #663 read seams and the minimal worktree primitives it needs, ported from `.claude/lib/worktree-resolution/WorktreeResolution.psm1` (lines 61-99, 118-293) and `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` (lines 311-339).
2. New `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`: the relocated `Get-EpicCheckpointContent` and `Get-ParallelCheckpointContent` (D5), `Get-OrchestrationEpicScopeSelector`, `Get-EpicCommandLegReadinessFailure`, and `Get-OrchestrationEpicScopeDecision`. It dot-sources the resolution sibling.
3. Modified `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, limited to three regions: one dot-source line in the header (current lines 13-25); deletion of the inline read-seam block (current lines 289-314); and one insertion immediately before the mode block (current line 430) that calls `Get-OrchestrationEpicScopeDecision -Command $command -FilePath $filePath` when `$filePath -or $command`, returning the decision when it is not `$null`.
4. Gate 5: no production change (D6, D12). Pinning suite only.

### Boundaries and invariants to preserve:

- Epic scope is decided only from the session root's epic checkpoint plus an effective-worktree HEAD match with `integration_branch`. No checkpoint path is read from command, patch, or prompt text.
- Checkpoint paths are composed as absolute paths from a resolved root.
- Fail-closed to the per-feature path: an absent or unparseable epic checkpoint, a non-`epic` `route_id`, an empty `integration_branch`, an unresolved selector, or a HEAD mismatch means "not epic scope"; the unchanged single-feature path then runs, including its denials. Resolver errors never throw out of the hook.
- Single-feature decisions and reason text are unchanged (AC-3).
- The Codex gate file and both new siblings stay at or under 500 lines.
- The four helpers copies stay SHA-256 identical and are not modified.
- Every changed `.codex/hooks` file is byte-identical to its bundle copy.
- No `.claude/**` file changes.

### Dependencies or blocked work:

- Builds on #663 (PR #700, merge commit `ae8d2ce3`), #554, and #673, all merged.
- No new third-party package.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:

See `## Files`.

#### Functions/classes/CLI commands impacted:

- New (resolution sibling): `Get-EpicScopeCheckpointText`, `ConvertFrom-EpicScopeCheckpointText`, `Get-EpicScopeWorktreeGitDirectory`, `Get-EpicScopeWorktreeHeadBranch`, `Test-EpicScopeMergeInProgress`, `Resolve-EpicScopeCheckpoint`, and the ported worktree primitives used by them (`Find-WorktreeResolutionRoot`, `Join-WorktreeResolutionPath`, `ConvertTo-WorktreeResolutionNormalizedPath`, `Get-WorktreeResolutionGitEntryKind`, `Get-WorktreeResolutionGitFileText`, and the target-resolution helper the resolver uses).
- New (epic-scope sibling): `Get-OrchestrationEpicScopeSelector`, `Get-EpicCommandLegReadinessFailure`, `Get-OrchestrationEpicScopeDecision`.
- Relocated, unchanged: `Get-EpicCheckpointContent`, `Get-ParallelCheckpointContent`.
- Modified: `Invoke-OrchestrationPreimplementationGateDecision` (Codex), command/apply_patch and path legs only.

#### Data flow and validation changes:

- For an implementation-classified command, apply_patch, or path leg that is not exempt, the gate evaluates `Get-OrchestrationEpicScopeDecision` before the mode block. In epic scope it returns allow or an epic-scope deny; otherwise it returns `$null` and the single-feature path runs.
- `Resolve-EpicScopeCheckpoint` returns `{ IsEpicScope, CheckpointPath, Checkpoint, MergeInProgress, Reason }`, matching the #663 shape.

#### Error handling and logging updates:

- Epic-scope denials reuse `PREIMPLEMENTATION_GATE_BLOCKED` and name `epic-orchestrator-state.json` (absolute path) and the failed conjunct, using the #663 reason format.
- Unparseable or array-shaped epic checkpoint JSON is treated as "not epic scope" and does not throw.

#### Rollback/feature-flag considerations (if applicable):

- No feature flag. Rollback is a revert of the PR. The resolver only changes a decision when an epic checkpoint with a matching `integration_branch` exists at the session root.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:

- Hook inputs (Codex PreToolUse payloads mapped by `codex-pretooluse-file-mapping.ps1`) and outputs (allow/deny with reason) are unchanged in shape.

#### Required configuration keys and defaults:

- None. `.codex/config.toml` is not changed; the new files are dot-sourced, not registered as hooks.

#### Backward-compatibility expectations:

- Every single-feature decision and reason string is unchanged. Existing suites pass without assertion changes.

#### Performance constraints (latency/throughput/memory):

- One additional small JSON read and one git-directory probe per implementation-classified call when the session root holds an epic checkpoint. No process spawn is added.

## Assumptions, Constraints, Dependencies

- **Assumptions.** The Codex hook process runs with the session worktree root as its current location (`.codex/config.toml:136,220`). The Codex epic coordinator's session root holds `epic-orchestrator-state.json` and no per-feature checkpoint.
- **Constraints.** 500-line file cap (the Codex gate has zero headroom today); PowerShell batch cap of three production and three test files; bundle copies byte-for-byte; the agent-worktree isolation guard denies Bash text containing `pwsh`; the PoshQC MCP test result carries no output, so no pass count or coverage percentage may be asserted from it.
- **External dependencies.** None.

## Data / API / Config Impact

- **User-facing changes.** A Codex-driven epic coordinator can stage main-sync merge resolutions and edit production paths on the integration branch while a merge is in progress and the epic checkpoint is ready.
- **Data.** None. The epic checkpoint schema is unchanged.
- **Logging.** Epic-scope denial reasons name the epic checkpoint and failed conjunct.
- **Compatibility.** No CLI flag or configuration change. Pester coverage allow-list and pack-manifest entries only.

## Test Strategy

- **Regression tests (new).**
  - `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1`: every resolver reason code; selector precedence over session root; `.git` as file versus directory; detached HEAD; `MERGE_HEAD` present and absent; unparseable and array JSON; absolute checkpoint path composition; every predicate conjunct in order; read seams against non-existent `/synthetic-worktrees/...` paths and against mocked `Test-Path`/`Get-Content`.
  - `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`: gate-4 epic allow and deny rows on the command, apply_patch, and path legs; `-C` selector rows; standalone rows returning the exact single-feature reason string; relocated read-seam rows; the no-leg guard; seam-name presence; no-Python token scan; 500-line cap and bundle SHA-256 identity for the gate and both new siblings.
  - `tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1`: gate-5 pinning rows (D6, D12).
- **Regression tests (modified, mocks only).** The five suites named in D10 gain `Mock Get-EpicScopeCheckpointText { $null }`; no assertion changes.
- **Hermeticity.** Mock `Get-EpicScopeCheckpointText`, `Get-EpicScopeWorktreeHeadBranch`, `Test-EpicScopeMergeInProgress`, `Find-WorktreeResolutionRoot`, `Get-WorktreeResolutionGitEntryKind`, and `Get-WorktreeResolutionGitFileText` by name. Always pass `-CheckpointRaw` with a not-ready single-feature JSON so the fallback never reads `artifacts/orchestration/orchestrator-state.json`. No `origin/main`, no `git` subprocess, no Windows drive roots, no temporary files, no `TestDrive:`.
- **Logic parity (issue AC-5).** Reuse the Claude EpicScope suite fixture literals (ready epic JSON, conjunct names, reason fragments) without importing the Claude modules.
- **Edge cases.** Absent, unparseable, array, and non-`epic` checkpoints; empty `integration_branch`; empty `features`; `epic_manifest_path` outside `docs/features/epics/`; HEAD mismatch; detached HEAD; `-C` selector to an unresolvable path; bookkeeping operands in epic scope (still exempt before the epic decision).
- **Coverage.** Line coverage >= 85% for each new or changed Codex hook file. Plan rows for the relocated read seams and the no-leg guard up front (#663 needed a remediation pass at 66.67% for its sibling).
- **Toolchain.** `mcp__drm-copilot__run_poshqc_format` -> `mcp__drm-copilot__run_poshqc_analyze` -> `mcp__drm-copilot__run_poshqc_test` with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; then `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py tests/scripts/dev_tools/test_codex_core_manifest_closure.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py`. Coverage evidence comes from the self-hosted module invoked directly in a fresh PowerShell 7 process (`Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1; Invoke-PoshQCTest -Root <worktree> -SettingsPath scripts/powershell/PoshQC/settings/pester.runsettings.psd1`), read from `artifacts/pester/powershell-coverage.xml`, and recorded under `docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/coverage/`.
- **Manual validation.** Not required. An optional Codex epic main-sync rerun is a follow-up.

## Acceptance Criteria

Every item below is verified by a named test or a deterministic command. `<base>` denotes `git merge-base HEAD main`, evaluated locally; no test depends on `origin/main`.

Traceability to `issue.md`: issue AC-1 -> AC-1 to AC-7; issue AC-2 -> AC-8 to AC-10; issue AC-3 -> AC-11 to AC-13; issue AC-4 -> AC-14 to AC-16; issue AC-5 -> AC-6, AC-7, AC-17; structural and policy -> AC-18 to AC-26.

Gate 4 — epic-scope allow and deny (issue AC-1)

- [x] AC-1: `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` proves that `Invoke-OrchestrationPreimplementationGateDecision` (Codex) returns `allow` for the command leg `{"command":"git add <production path>"}` when the mocked epic checkpoint is ready (`route_id: epic`, `epic_feature_folder`, `epic_manifest_path` under `docs/features/epics/`, non-empty `integration_branch` and `features`), the mocked session-root HEAD equals `integration_branch`, and the mocked `Test-EpicScopeMergeInProgress` returns `$true`, with `-CheckpointRaw` set to a not-ready single-feature checkpoint.
- [x] AC-2: The same suite proves the path leg (`{"file_path":"<production path>"}`) and the apply_patch leg (a patch text carrying `*** Begin Patch` / `*** Update File:` markers in `command`) return the same `allow` decision under the AC-1 conditions, with scope decided by the session-root HEAD (D13).
- [x] AC-3: The same suite proves that under the AC-1 conditions with `Test-EpicScopeMergeInProgress` returning `$false`, the command, apply_patch, and path legs are denied with a reason matching `PREIMPLEMENTATION_GATE_BLOCKED`, containing `epic-orchestrator-state.json`, and naming the conjunct `merge-in-progress`.
- [x] AC-4: The same suite proves that, in epic scope, removing or invalidating each conjunct `route_id`, `epic_feature_folder`, `epic_manifest_path`, `integration_branch`, and `features` yields a `PREIMPLEMENTATION_GATE_BLOCKED` deny whose reason names that conjunct and `epic-orchestrator-state.json`.
- [x] AC-5: The same suite proves that a command `git -C <selector path> add <production path>` is decided by the mocked HEAD of the selector worktree, not the session root: allow when the selector HEAD matches `integration_branch` (with the other AC-1 conditions), and the unchanged single-feature deny when only the session-root HEAD matches.
- [x] AC-6: `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1` proves `Resolve-EpicScopeCheckpoint` (Codex) returns each reason code `session-root-unresolved`, `epic-checkpoint-absent-or-unparseable`, `route_id`, `integration_branch`, `selector-unresolved`, `branch-mismatch`, and `epic-scope` for its corresponding fixture; that an unparseable or array-shaped checkpoint yields `IsEpicScope = $false` without throwing; that `CheckpointPath` is absolute and composed from the resolved root; and that `.git` as a file (gitdir pointer) and as a directory, detached HEAD, and `MERGE_HEAD` present/absent are each decided through the mocked primitives. `no-branch-signal` is either returned for its fixture or, if unreachable under the fixed head-match contract (D3), its omission is recorded in the suite header.
- [x] AC-7: The same resolution suite proves `Get-EpicCommandLegReadinessFailure` (Codex) returns the conjuncts `checkpoint-absent`, `route_id`, `epic_feature_folder`, `epic_manifest_path`, `integration_branch`, `features`, `merge-in-progress` in that precedence order for the Claude EpicScope suite's fixture literals, and an empty result (the empty string, as the #663 predicate does; asserted with `Should -BeNullOrEmpty`) for the ready fixture with a merge in progress.

Gate 5 — epic checkpoint edits not intercepted (issue AC-2)

- [x] AC-8: `tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1` proves the Codex gate-5 decision function allows a completion-asserting Write and a completion-asserting Edit whose `file_path` is `artifacts/orchestration/epic-orchestrator-state.json`, and allows an apply_patch Add of that path; and proves `ConvertTo-CodexFileEditInput -ResolveUpdateContent -GovernedPath artifacts/orchestration/orchestrator-state.json` emits no record for an apply_patch Update of the epic checkpoint path. Rows use Write-shaped payloads or a checkpoint reader that ignores its path argument, and no row asserts the path passed to the reader.
- [x] AC-9: The same suite proves that a completion-asserting Write to `artifacts/orchestration/orchestrator-state.json` whose `feature-folder` is `docs/features/epics/<slug>` is still denied with a reason matching `COMPLETION_CONSISTENCY_BLOCKED`.
- [x] AC-10: `git diff --name-only <base> HEAD -- .codex/hooks/enforce-completion-consistency.ps1 .codex/hooks/enforce-completion-helpers.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-helpers.ps1` produces no output (D6, D12).

Unchanged single-feature behaviour (issue AC-3)

- [x] AC-11: `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` standalone rows prove that with (a) no epic checkpoint, (b) an `integration_branch` that differs from the effective HEAD, (c) a missing `route_id`, and (d) an empty `integration_branch`, the command, apply_patch, and path legs return exactly the single-feature decision and reason string `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json to contain issue number, feature folder, route metadata, lifecycle readiness, and checkpoint state before implementation begins.` (the Codex gate literal at `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:463` on the base), and `allow` for a ready single-feature `-CheckpointRaw`.
- [x] AC-12: Every existing Codex gate-4 and gate-5 suite passes: every `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-*.Tests.ps1` file present on the base, `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1`, `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1`, `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, and `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1`. For each of these files, `git diff -U0 <base> HEAD -- <file>` contains no removed line (other than the `---` header) and no added line containing `Should`.
- [x] AC-13: `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1` pass with an empty `git diff <base> HEAD` for both files, proving the delegation leg and the relocated read seams keep their behaviour (D5, D14).

Hermetic, Linux-CI tests (issue AC-4)

- [x] AC-14: Each of `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`, `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1`, and `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` registers `Mock Get-EpicScopeCheckpointText { $null }` in a `BeforeAll` or `BeforeEach` that covers every in-process row calling `Invoke-OrchestrationPreimplementationGateDecision` on a command or path leg, and passes.
- [x] AC-15: A case-insensitive search of `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1`, and `tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1` for `New-TemporaryFile`, `TestDrive`, `GetTempPath`, `GetTempFileName`, `origin/main`, `orchestrator-state.json` read through `Get-Content`, `Set-Location`, `Push-Location`, and the regex `\b[A-Za-z]:[\\/]` returns no match, and every epic checkpoint, HEAD, root, and `MERGE_HEAD` read in those files is supplied through a Pester `Mock` of the named seam.
- [x] AC-16: The new suites listed in AC-15 and the D10-modified suites listed in AC-14 pass in the repository CI Pester run on the pull request (windows-latest, the repository's only CI Pester job), with no dependency on `artifacts/orchestration/*.json` being present or absent.

Design parity (issue AC-5)

- [x] AC-17: `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1` asserts, after dot-sourcing the Codex gate, that `Get-Command` resolves every seam name listed in D2 as a function; and this spec records every intentional divergence from #663 as a numbered decision (D1 placement, D3 fixed head-match contract, D13 apply_patch leg, D14 retained divergences, D15 Codex-local no-Python check), verified by inspection of `## Design Decisions`.

Structure, bundle, manifest, and coverage

- [x] AC-18: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1`, and the bundle copy of each under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` each have at most 500 lines, asserted by the new gate-4 suite and by the existing line-cap rows in `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`.
- [x] AC-19: Each `.codex/hooks` file listed in AC-18 is SHA-256 identical to its copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`, asserted by the new gate-4 suite and by `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` passing.
- [x] AC-20: `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` lists `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1`, and `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py` and `tests/scripts/dev_tools/test_codex_core_manifest_closure.py` pass.
- [x] AC-21: `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` passes, proving the bundled gate-4 and gate-5 hooks load and exit 0 from the bundle root with the new dot-sourced siblings.
- [x] AC-22: Both `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1` list the two new `.codex/hooks` files in `CodeCoverage.Path`; `tests/scripts/dev_tools/test_poshqc_bundled_parity.py` passes; and the coverage evidence under `docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/coverage/` reports line coverage >= 85% for `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, and `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1`, taken from `artifacts/pester/powershell-coverage.xml` of a direct self-hosted PoshQC run.
- [x] AC-23: `git diff --name-only <base> HEAD -- .claude` produces no output.
- [x] AC-24: `git diff --name-only <base> HEAD -- .claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1 .codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1 scripts/dev_tools/push_down_codex_and_agents_customizations.py` produces no output, and `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1` passes.
- [x] AC-25: The new gate-4 suite asserts that the repository's parser-based Python-invocation detector (`Get-PythonInvocationFinding` in `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1`) reports no interpreter invocation in each of the three `.codex/hooks` files listed in AC-18 and in its bundle copy; that the two new sibling files contain neither the `python` nor the `poetry` token (case-insensitive); and that each new sibling's comment header declares the epic readiness predicate PowerShell-authoritative (D15, D16). The pre-existing `poetry` token in the unchanged `Test-ImplementationCommand` classifier regex of `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` is a classifier pattern, not an invocation, and is outside this token check.
- [x] AC-26: The PowerShell toolchain passes in a single pass (`mcp__drm-copilot__run_poshqc_format`, `mcp__drm-copilot__run_poshqc_analyze`, `mcp__drm-copilot__run_poshqc_test` with `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`) and the Python guard tests named in the `poetry run pytest` command in `## Test Strategy` pass, with results recorded under `docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/qa-gates/`.

## Files

### Files written

Production (Codex surface):

- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (modified: dot-source line, epic-scope call, read-seam block removed)
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` (new)
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1` (new)

Bundle copies (byte copies of the production files above):

- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-epic-resolution.ps1`

Manifests and settings:

- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json`
- `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`
- `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`

Tests (new):

- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-resolution.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-completion-consistency-epic-scope.Tests.ps1`

Tests (modified; mock registration only, D10):

- `tests/scripts/codex-hooks/codex-preimplementation-gate-absolute-paths.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-command-exemption.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1`
- `tests/scripts/codex-hooks/codex-pretooluse-transport.Tests.ps1`
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`

Feature documents (not code):

- `docs/features/active/codex-gates-4-5-lack-epic-scope-707/spec.md`
- The plan and the evidence files are created under `docs/features/active/codex-gates-4-5-lack-epic-scope-707/` (plan) and `docs/features/active/codex-gates-4-5-lack-epic-scope-707/evidence/<kind>/` (evidence); their file names are assigned at planning and execution time.

### Files read only

- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`
- `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`
- `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`
- `.claude/lib/worktree-resolution/EpicScopeReadiness.psm1`
- `.claude/lib/worktree-resolution/WorktreeResolution.psm1`
- `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1`
- `.claude/hooks/enforce-completion-consistency.ps1`
- `.claude/hooks/enforce-completion-helpers.ps1`
- `.codex/hooks/enforce-completion-consistency.ps1`
- `.codex/hooks/enforce-completion-helpers.ps1`
- `.codex/hooks/codex-pretooluse-file-mapping.ps1`
- `.codex/hooks/enforce-checkpoint-monotonic.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`
- `.codex/config.toml`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1`
- `tests/scripts/claude-lib/worktree-resolution/EpicScopeResolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-completion-consistency.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-routing.Tests.ps1`
- Guard tests, run but not edited: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-helpers.Parity.Tests.ps1`, `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1`, `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py`, `tests/scripts/dev_tools/test_push_down_codex_and_agents_pack_manifest_completeness.py`, `tests/scripts/dev_tools/test_codex_core_manifest_closure.py`, `tests/scripts/dev_tools/test_poshqc_bundled_parity.py`
- `docs/features/active/enforcement-gates-lack-epic-level-checkpoint-seam-663/spec.md`
- `docs/features/active/codex-gates-4-5-lack-epic-scope-707/issue.md`
- `docs/features/active/codex-gates-4-5-lack-epic-scope-707/research/research.2026-09-26T23-00.md`

## Merge-Order Independence

Sibling items #708, #709, #710, and #713 run in the same parallel run. The rules below (D11) keep #707 correct whether each sibling merges before or after it.

| Sibling | Its write set | Overlap with #707 | Why #707 is correct in either order |
| --- | --- | --- | --- |
| #708 | The Claude gate-5 Edit branch (`Resolve-EditedCheckpointContent` literal relative path) and possibly `.codex/hooks/enforce-completion-consistency.ps1` near line 308 | Possible on the Codex gate-5 file | #707 does not edit either Codex gate-5 file (D6, D12). The #707 gate-5 pinning rows use Write-shaped payloads or a checkpoint reader that ignores its path argument, and never assert the path passed to the reader, so they hold whether the Edit branch reads a literal or `file_path`-derived path. The rows live in a new file, not in `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1`. |
| #709 | Claude gate 1/3/4 suites under `tests/scripts/claude-hooks/` | None on files; same remedy class | #707 applies the local-epic-state mock remedy only to Codex suites (D10) and writes nothing under `tests/scripts/claude-hooks/`. |
| #710 | The four copies of `enforce-orchestration-preimplementation-gate-helpers.ps1`, including `.codex/hooks/` and the Codex bundle copy | The helpers copy; the `-C` selector depends on helpers parsing | #707 modifies no helpers copy (AC-24). The parity test compares the four copies with each other, so it holds whichever item merges first. The selector rows use unquoted paths without backslashes, so their tokens do not depend on #710's escape handling. |
| #713 | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` no-checkpoint commit admission; possibly the Codex gate | Possible on `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`, which has zero line headroom | #707 limits its gate edits to three regions: the dot-source header, deletion of the inline read-seam block, and one insertion before the mode block. It does not touch `Test-ImplementationCommand`. Plan phase 0 re-reads the Codex gate on the current base, records its line count and whether the read seams are still inline, and adapts the relocation. Tests assert behaviour, not line numbers; AC-18 is re-evaluated after every rebase. |

General rule: rebase on `main` before opening the PR, and rerun the parity, manifest, bundle, and line-cap tests (AC-18 to AC-24) after each rebase. No assertion encodes a sibling's intermediate state.

## Risks & Mitigations

- **Epic scope over-matches.** A single-feature run in a worktree that also holds an epic checkpoint could be treated as epic scope. Mitigation: scope requires `route_id == epic` and an exact effective-HEAD match with `integration_branch`; AC-11 standalone rows.
- **D2 opens production staging on the integration branch.** Mitigation: implementation operands are allowed only while `MERGE_HEAD` exists; AC-3 deny rows.
- **Logic drift between the Codex port and the Claude modules.** Mitigation: identical seam names, reason codes, and conjunct order (D2); AC-6, AC-7, and AC-17 reuse the Claude fixture literals.
- **Line-cap breach on the Codex gate.** Mitigation: D5 relocation frees 26 lines against about 12 needed; AC-18; phase-0 re-read for #713 overlap.
- **Existing Codex suites read local epic state.** Mitigation: D10 mocks (AC-14); child-process rows remain deny-robust.
- **Coverage evidence not collected by the MCP runner.** Mitigation: register `CodeCoverage.Path` in both runsettings copies and take evidence from a direct self-hosted PoshQC run (AC-22).
- **Bundle load failure.** Mitigation: dot-source only, no `Import-Module` of `.claude/lib` (D1); AC-21 bundle hook probe.
- **Rollback.** Revert the PR.

## Rollout & Follow-up

- **Rollout.** Standalone PR to `main`; the Codex bundle picks up the byte copies on the next extension release.
- **Follow-ups.** Optional manual Codex epic main-sync rerun (same kind as #663 follow-up 5). The no-Python guard's scan roots do not include `.codex/hooks`; extending it is a candidate follow-up and is not part of #707.
- **Links.** Issue #707; precedent #663 (PR #700, merge commit `ae8d2ce3`); related #554, #673; siblings #708, #709, #710, #713; research `research/research.2026-09-26T23-00.md`.
