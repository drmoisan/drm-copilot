# preimpl-gate-blocks-post-fanin-integration-writes (Spec)

- **Issue:** #1136
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-11-08T16-30
- **Status:** Draft
- **Version:** 0.2

## Context
After every child feature of an epic has merged into the epic integration branch (fan-in complete), the preimplementation gate still blocks legitimate writes on that integration branch: the commit of the updated `docs/features/epics/<slug>/epic-status.md`, and the pr-author receipt `artifacts/pr_body_<N>.receipt.json` for the integration-to-main PR. The epic-orchestrator therefore cannot finish an epic without a human workaround.

Environment:
- OS/version: Windows 11 Pro, Claude Code CLI
- Python version: n/a (PowerShell hooks)
- Command/flags used: `/epic-run` on the iar-migration three-layer redesign epic (E1/E2), 2026-11-07/08
- Data source or fixture: epic checkpoint `artifacts/orchestration/epic-orchestrator-state.json` showing every feature merged

Impact / Severity:
- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Repro & Evidence
Steps to Reproduce:
1. Run an epic with `/epic-run` until every child PR has merged into `epic/<slug>-integration`.
2. On the integration branch, have epic-orchestrator update `epic-status.md` and `git add` / `git commit` it.
3. Delegate pr-author for the integration-to-main PR; it writes `artifacts/pr_body_<N>.md` and `artifacts/pr_body_<N>.receipt.json`.

Expected:
When the epic checkpoint records every feature as merged (fan-in complete), the gate allows both the epic-status commit and the pr-author receipt write on the integration branch, without a per-item readiness checkpoint and without a hand-authored checkpoint.

Actual:
The preimplementation gate denies the operations. On the integration worktree the call is epic scope and the deny text names the failed readiness predicate `'merge-in-progress'`; when the target worktree is not on the integration branch the generic `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json ...` text is returned. Which text the incident produced is unverified; both are reachable (research section 1).

Verified deny surface (research section 1): Write of `artifacts/pr_body_<N>.receipt.json` (`.json` is classified); a pathless `git commit -m`; `git commit -F <file>` with or without a pathspec; a chained `git add ... && git commit` whose commit is pathless. Already allowed today: Write of `artifacts/pr_body_<N>.md` and of `epic-status.md` (`.md` is not classified), `git add <status doc>`, and `git commit -m ... -- <status doc>` (issue #539 exemption).

## Scope & Non-Goals
- In scope: a narrow fan-in allowance evaluated inside `Get-OrchestrationEpicScopeDecision` on the Claude and Codex surfaces; a new shared pure hook file with a byte-identity parity test; Pester tests; skill and execution-environment brief documentation; pinned-hash re-baseline; pack manifest entries.
- Out of scope / non-goals: follow-up on an already-merged feature (finding 3); orchestrator stop hook validating the wrong worktree's checkpoint (finding 9); widening the issue #539 staging exemption (for example modelling `-F` or admitting pathless commits outside epic scope); any change to the cleanup legs.
- Explicitly excluded systems, integrations, or datasets: Python validators and any new Python code; the main gate files `enforce-orchestration-preimplementation-gate.ps1` (both surfaces) and `enforce-orchestration-preimplementation-gate-cleanup.ps1` must not grow.

## Root Cause Analysis
The preimplementation gate recognizes only per-item orchestrator checkpoints. In epic scope (worktree HEAD equals the epic checkpoint's `integration_branch`), `Get-EpicCommandLegReadinessFailure` returns `'merge-in-progress'` whenever no merge is in progress, so every classified operation after fan-in is denied. The gate has no notion of the epic checkpoint's fan-in-complete state. The cleanup legs, which admit the receipt for the consolidation worktree, run only at the final deny and are unreachable for epic-scope calls because the epic-scope decision returns first.

Constraint from the owner: do not weaken the gate's intent; make the legitimate path pass. The allowance must be narrow: only the epic-status file and the pr-author body/receipt paths, only on the integration branch named in the epic checkpoint, only when every feature is recorded merged.

## Proposed Fix

### Design summary (what changes where):
Approach A from research section 8. A new pure hook file `hook-epic-fan-in.ps1`, byte-identical at `.claude/hooks/`, `.codex/hooks/`, and both bundle mirrors under `extensions/drm-copilot/resources/` (`claude-customizations/.claude/hooks/` and `codex-and-agents-customizations/.codex/hooks/`), is dot-sourced (guarded) by each surface's `enforce-orchestration-preimplementation-gate-epic-scope.ps1`. In `Get-OrchestrationEpicScopeDecision`, the readiness evaluation returns `''` (allow) only when the readiness failure is exactly `'merge-in-progress'`, `Test-EpicFanInComplete` holds for the scope checkpoint and branch, and `Get-EpicFanInAllowance` reports `Allowed`. Otherwise the original failure and deny text are returned unchanged.

### Boundaries and invariants to preserve:
- The allowance applies only inside epic scope, so it inherits target resolution, ambiguity denies, and the HEAD = `integration_branch` binding.
- Every other readiness conjunct, every target-verdict deny, and every deny text stay unchanged.
- Allowlist: Write/Edit of `artifacts/pr_body_<N>.md` and `artifacts/pr_body_<N>.receipt.json`; `git add` / `git commit` of the checkpoint's status doc only. A pathless commit is allowed only when the staged index of the target worktree is exactly the status doc.
- Fan-in complete: `route_id` is `epic`, `integration_branch` is non-blank and case-sensitively equal to the worktree HEAD branch, `features` is non-empty, and every `merge_status` is in `{merged, worktree_removed}`.
- The allowance function never throws; any error answers not allowed.

### Dependencies or blocked work:
Findings 3 and 9 touch the same gate and target resolution and run sequentially after this item. `Get-EpicFanInAllowance` takes an already-resolved scope object and a staged-index reader so those follow-ups can reuse it.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- New: `.claude/hooks/hook-epic-fan-in.ps1`, `.codex/hooks/hook-epic-fan-in.ps1`, and both bundle copies.
- Edit: `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, and their bundle copies.
- Docs: `.claude/skills/epic-orchestrate/SKILL.md` and bundle copy; the Codex-variant epic-orchestrate skill (`.agents`) and bundle copy; every byte-identical copy of the execution-environment brief (`## Hook Execution Context`).
- Pins/manifests: `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`; `pack-manifests/core.json` under `claude-customizations` and `codex-and-agents-customizations`.

#### Functions/classes/CLI commands impacted:
- New: `Test-EpicFanInComplete`, `Get-EpicFanInStatusDocRelativePath`, `Test-EpicFanInWriteRelativePath`, `Test-EpicFanInCommitShape`, `Get-EpicFanInAllowance`.
- Edited: `Get-OrchestrationEpicScopeDecision` (both surfaces).

#### Data flow and validation changes:
Path leg: every non-blank path (one on Claude, one or more `apply_patch` marker paths on Codex) must match the allowlist; an absolute path is converted with `Get-HookTargetWorktreeRelativePath` against the scope worktree root, and a path outside it is not allowed; a relative path targets the session root. Command leg: the command text must be resolvable (`Test-OrchestrationCommandTextUnresolvable` false) and split balanced (`Split-OrchestrationCommandLine`); every segment must pass `Test-EpicFanInCommitShape` (`git [-C <abs>] add [--] <status doc>`, or `git [-C <abs>] commit` with only `-m`, `--message`, `-F`, `--file`, `--trailer` and either no pathspec or `-- <status doc>`). A pathless commit reads the staged index of `Scope.WorktreeRoot` through the injected reader; the list must be readable, NUL-terminated, non-empty, and exactly the status doc. The status doc path is `docs/features/epics/<epic_feature_folder>/epic-status.md`, with the slug a plain segment (`^[A-Za-z0-9][A-Za-z0-9._-]*$`) and, when present, equal to `epic_status_doc_path`.

#### Error handling and logging updates:
The new file is dot-sourced in its own single-statement `try { . (...) } catch { Add-HookDependencyFailure ... }` so a load failure fails closed. No deny-text changes; the optional "Fan-in leg not applied" suffix is deferred to keep wording pins stable.

#### Rollback/feature-flag considerations (if applicable):
No flag. Rollback is reverting the dot-source and the one-condition change in `Get-OrchestrationEpicScopeDecision`; the gate then returns to current behavior.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `Test-EpicFanInComplete -Checkpoint <pscustomobject> -Branch <string>` -> `[bool]`.
- `Get-EpicFanInStatusDocRelativePath -Checkpoint` -> `[string]` or `$null`.
- `Test-EpicFanInWriteRelativePath -RelativePath -Checkpoint` -> `[bool]`.
- `Test-EpicFanInCommitShape -Token <string[]>` -> `'add'`, `'commit'`, or `$null`.
- `Get-EpicFanInAllowance -Scope -FilePath <string[]> -Command <string> -StagedIndexReader <scriptblock>` -> `[pscustomobject]@{ Allowed = [bool]; Detail = [string] }`. Blank `FilePath` entries are ignored; any non-blank entry makes the call a path leg in which every entry must be allowlisted. Claude passes `@($FilePath)` and the command text; Codex passes `$legPaths` and `$legCommand`, so an `apply_patch` leg is judged on every marker path. `Scope` has the `Resolve-EpicScopeCheckpoint` result shape (`IsEpicScope`, `CheckpointPath`, `Checkpoint`, `WorktreeRoot`, `Branch`, `MergeInProgress`, `Reason`), identical on both surfaces.

#### Required configuration keys and defaults:
None. Inputs come from existing epic checkpoint fields (`route_id`, `epic_feature_folder`, `epic_status_doc_path`, `integration_branch`, `features[].merge_status`).

#### Backward-compatibility expectations:
All existing gate test rows keep their outcomes (research section 5): production-path denies in epic scope, missing-field denies, the CommandExemption pathless-commit deny outside epic scope, cleanup receipt rows, and the parity AC-18 function inventory of the main gate files.

#### Performance constraints (latency/throughput/memory):
The staged-index read occurs only for a pathless commit after the fan-in predicate and shape checks pass. No other new process or disk access.

## Assumptions, Constraints, Dependencies
- Assumptions: the epic checkpoint is located by the existing `Resolve-EpicScopeCheckpoint` (Claude) and its Codex twin; the receipt Write targets the worktree that has the integration branch checked out.
- Constraints: no Python; main gate files and the cleanup file do not grow; the new file is pure apart from injected seams; Linux CI is case-sensitive with no drive letters.
- External dependencies: destinations receive the change only after an extension release and a push-down refresh.

## Data / API / Config Impact
- User-facing or API changes: epic-orchestrator and pr-author can complete the post-fan-in writes on the integration branch.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes: documented limits: a `-F` value or any token containing a backslash makes the command unresolvable (use a forward-slash path or `-m`); a chained `git add && git commit` with a pathless commit reads the index before the add runs (issue the commit separately or use `-- <status doc>`).

## Test Strategy
Seeded from issue:

- [ ] Unit coverage areas: gate allows the two writes when the epic checkpoint shows all features merged; still denies them when any feature is not merged; still denies other production paths on the integration branch; still denies on a branch that is not the checkpoint's integration branch.
- [ ] Integration scenario to retest: post-fan-in epic-status commit and pr-author receipt write on an integration branch.
- [ ] Manual verification notes: update the epic-orchestrate skill and the gate's documentation to describe the recognized path; destinations need a push-down refresh.

- Regression tests to add or update: new `tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1`, `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-fan-in.Tests.ps1`, and a byte-identity parity row for `hook-epic-fan-in.ps1`.
- Unit tests (Pester) for the fixed behavior and boundaries: a fail-before hook-level test captured before the leg lands; unit rows for each pure function, including a pin that the restated terminal status pair equals `$script:TerminalMergeStatuses` and agreement with `Get-EpicPrCreationReadinessFailure` over a fixture matrix.
- Edge cases and negative scenarios: incomplete fan-in; other paths; wrong branch; missing or unparseable epic checkpoint; staged index with an extra path, empty, unreadable, or not NUL-terminated; unmodelled commit options (`--amend`, `-a`); blank or non-plain slug; `epic_status_doc_path` disagreeing.
- Error handling and logging verification: a row in which the staged-index reader throws yields not allowed.
- Coverage impact and targets: the new hook file meets the repository line-coverage threshold in `artifacts/pester/powershell-coverage.xml`.
- Tests use `Set-EpicScopeSeam`-style module-scoped mocks, `Register-EpicStateBaselineMock`, `/synthetic-worktrees/` roots, and a mocked staged-index reader; no temp files, no global state.
- Toolchain commands to run: Invoke-Formatter -> PSScriptAnalyzer -> Pester (parallel run) with coverage; the Python contract tests for pinned hashes and pack manifests.
- Manual validation steps: none beyond the push-down refresh after release.

## Acceptance Criteria
- [x] A fail-before test in `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1` (Write of `artifacts/pr_body_7.receipt.json` in epic scope with fan-in complete) is recorded denying with `'merge-in-progress'` before the fix, with evidence under the feature `evidence/regression-testing/` folder, and passes (allow) after the fix.
- [x] `hook-epic-fan-in.ps1` exists at `.claude/hooks/`, `.codex/hooks/`, and both bundle mirrors under `extensions/drm-copilot/resources/`, defines `Test-EpicFanInComplete`, `Get-EpicFanInStatusDocRelativePath`, `Test-EpicFanInWriteRelativePath`, `Test-EpicFanInCommitShape`, and `Get-EpicFanInAllowance`, and a parity test asserts the copies are byte-identical.
- [x] `Get-OrchestrationEpicScopeDecision` in both surfaces' `enforce-orchestration-preimplementation-gate-epic-scope.ps1` (and bundle copies) allows only when the readiness failure is exactly `'merge-in-progress'`, `Test-EpicFanInComplete` holds, and `Get-EpicFanInAllowance` returns `Allowed`; the new file is dot-sourced in a guarded `try`/`catch` that calls `Add-HookDependencyFailure`.
- [x] Positive Pester rows on both surfaces allow: Write of the receipt (relative and absolute into the integration worktree); Write of `artifacts/pr_body_<N>.md`; `git add` of the status doc; `git [-C <abs>] commit -m` and `-F <forward-slash path>` with no pathspec when the staged index is exactly the status doc; and `git commit -F <path> -- <status doc>`.
- [x] Negative Pester rows deny with unchanged deny text when any feature `merge_status` is not terminal, when `features` is empty, and when the path is outside the allowlist (`artifacts/pr_body_7.json`, a production `.ps1`, another slug's `epic-status.md`).
- [x] Negative Pester rows confirm the generic single-feature deny is unchanged when the worktree HEAD is not the checkpoint's `integration_branch` and when the epic checkpoint is missing or unparseable.
- [x] Negative Pester rows deny a pathless commit when the staged index has an extra path, is empty, is unreadable, is not NUL-terminated, or the reader throws; and deny commits carrying unmodelled options (`--amend`, `-a`), a blank or non-plain `epic_feature_folder`, or an `epic_status_doc_path` that disagrees with the derived path.
- [x] `tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1` pins the restated terminal status set equal to `$script:TerminalMergeStatuses` in `EpicScopeReadiness.psm1` and shows `Test-EpicFanInComplete` agrees with `Get-EpicPrCreationReadinessFailure` over a fixture matrix.
- [x] Existing suites (`EpicScope`, `CommandExemption`, `Cleanup`, `EpicScopeTargets`, `Parity`, `EpicScopeHelperParity`, `hook-dependency-guard-completeness`, and the Codex gate suites) pass unchanged, and neither main gate file nor the cleanup file grows in line count.
- [x] The new hook file meets the repository line-coverage threshold, PSScriptAnalyzer reports zero findings on changed files, and `Invoke-PoshQCLeakScan` is clean without new allowlist entries.
- [x] Documentation is updated: the epic-orchestrate skill (Claude copy, Codex variant, and bundle copies) describes the post-fan-in allowance and its limits, and every copy of the execution-environment brief carries a #1136 bullet under `## Hook Execution Context`.
- [ ] `PINNED_FROZEN_SURFACE_HASHES` is re-baselined with a "RE-BASELINED by issue #1136" comment, both `pack-manifests/core.json` files list the new hook file, and the Python surface-contract, pack-manifest completeness, and dependency-closure tests pass.

## Risks & Mitigations
- Technical or operational risks: a reviewer may read the allowance as a gate weakening; mirror drift across the bundle copies; Linux-only path or case failures in CI; test-isolation leaks from module-scoped mocks.
- Mitigations and rollbacks: keep the allowance inside epic scope and conditioned on the exact `'merge-in-progress'` failure plus fan-in completeness, with a slug-bound allowlist; byte-identity parity test; synthetic forward-slash roots; follow the EpicScope suite mock pattern. Rollback by reverting the dot-source and condition.

## Rollout & Follow-up
- Release/rollout steps: merge, release the extension, then run a push-down refresh on each destination.
- Post-fix monitoring or clean-up tasks: findings 3 and 9 reuse `Get-EpicFanInAllowance` through its scope-object input.
- Links: issue https://github.com/drmoisan/drm-copilot/issues/1136; research `research/research.2026-11-08T16-10.md`.
