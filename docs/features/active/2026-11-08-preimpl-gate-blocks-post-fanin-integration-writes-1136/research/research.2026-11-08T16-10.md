# Research: preimplementation gate blocks post-fan-in integration writes (Issue #1136)

- Issue: #1136
- Branch: bug/preimpl-gate-post-fanin-writes
- Timestamp note: the filename stamp was not read from a clock (the researcher has no shell). The orchestrator confirms or renames it.
- Scope: read-only investigation; every claim below was verified by reading the cited file in this worktree unless marked "unverified".

## 1. Current decision flow and the exact deny sites

Entry: `Invoke-OrchestrationPreimplementationGateDecision` in `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`. Order for a Write/Edit or Bash call:

1. Dependency-failure decision, then payload parse (fail closed on anomaly).
2. Classification. Path leg: `Test-ImplementationPath` returns false for `docs/features/active/` (`Test-FeatureDocumentationOrEvidencePath`), for the seven `$script:CheckpointPaths` literals, and for any extension outside `py|ps1|psm1|ts|tsx|js|jsx|cs|json|yml|yaml`. Command leg: `Test-ImplementationCommand`; the `git add|commit` trigger is cleared only by `Test-ExemptOrchestrationStagingCommand` (helpers file, issue #539).
3. Not classified as implementation: allow.
4. `Get-OrchestrationEpicScopeDecision` (`-epic-scope.ps1`): resolves targets (`Get-OrchestrationCommandTarget`, targets file), then `Resolve-EpicScopeCheckpoint -MatchWorktreeHead` per target (EpicScopeResolution.psm1). Epic scope holds when the effective worktree HEAD equals `integration_branch` of the epic checkpoint that `Resolve-WorktreeEpicTarget` finds in any live worktree. In scope, `Resolve-OrchestrationEpicTargetOutcome` evaluates `Get-EpicCommandLegReadinessFailure` (EpicScopeReadiness.psm1). Out of scope: `$null`.
5. Delegation-mode branch (not reached by path/command legs).
6. Single-feature checkpoint (`Read-OrchestrationGateCheckpoint`, `Test-OrchestrationReady`), then the cleanup legs (`Get-OrchestrationCleanupContextResult`, issue #1026), then the final generic deny.

What is actually denied today (scope correction for the planner):

| Operation | Classified? | Outcome on the integration worktree after fan-in |
|---|---|---|
| Write `artifacts/pr_body_<N>.md` | No (`.md`) | Already allowed. |
| Write/Edit `docs/features/epics/<slug>/epic-status.md` | No (`.md`) | Already allowed. |
| Write `artifacts/pr_body_<N>.receipt.json` | Yes (`.json`) | Denied. |
| `git add docs/features/epics/<slug>/epic-status.md` (optionally `git -C <abs> add`) | Cleared by #539 (`docs/features/epics/` is an exempt tree) | Already allowed. |
| `git commit -m "<msg>" -- docs/features/epics/<slug>/epic-status.md` | Cleared by #539 | Already allowed (pinned allow rows in `CommandExemption.Tests.ps1`, context "issue #663 quote-aware angle brackets"). |
| `git commit -m "<msg>"` with no pathspec | Not cleared (D4 row 4) | Denied; the same file pins this as a deny row ("a pathless commit whose message carries angle brackets"), outside epic scope. |
| `git commit -F <file>` (with or without pathspec) | Not cleared (`-F` is not a modelled option in `Test-ExemptOrchestrationSegmentToken`) | Denied. |
| `git add ... && git commit -m ...` chained, commit pathless | Not cleared (every segment must qualify) | Denied. |

Deny text. When the target worktree HEAD equals the checkpoint's `integration_branch`, the call is epic scope and every readiness conjunct passes except the last, so the deny is the epic-scope text from `Resolve-OrchestrationEpicTargetOutcome`: `PREIMPLEMENTATION_GATE_BLOCKED: this epic-scope operation was evaluated against <checkpoint path>, and the failed readiness predicate is 'merge-in-progress'. ...` (or the `target-not-ready` variant from `Get-OrchestrationEpicTargetDenyReason` when the target is not the session root). When the target worktree is not on the integration branch (for example a relative receipt path written from a coordinator on `main`), the call is not epic scope and receives the generic `PREIMPLEMENTATION_GATE_BLOCKED: Implementation operations require artifacts/orchestration/orchestrator-state.json ...` text. The issue quotes the generic text; which of the two the incident produced is unverified, and the planner should treat both as reachable.

Existing allow legs before the deny: the `.md` extension filter, the `docs/features/active/` path exemption, the seven checkpoint literals, the #539 staging exemption, and the epic-scope merge-in-progress allow. No `artifacts/pr_body_*` exemption exists outside the cleanup consolidation leg, which admits the receipt only inside the `documentationandmemories` worktree (`Get-OrchestrationCleanupConsolidationWriteResult`). The cleanup legs run only at the final deny, after the epic-scope decision has already returned, so they cannot serve as the plug-in point.

## 2. Codex twin

- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` has the same order (epic-scope decision before the delegation branch, cleanup before final deny, with `-AllowPatchManifest`).
- `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` is not byte-identical to the Claude file: it carries its own copy of `Get-EpicCommandLegReadinessFailure` and its own `Get-OrchestrationEpicScopeDecision`, and it dot-sources `-epic-resolution.ps1` (Codex copy of `Resolve-EpicScopeCheckpoint`, same result shape: `IsEpicScope`, `CheckpointPath`, `Checkpoint`, `WorktreeRoot`, `Branch`, `MergeInProgress`, `Reason`). Codex hooks cannot import `.claude/lib`, and no Codex counterpart of `Get-EpicPrCreationReadinessFailure` exists.
- The Codex gate must change in parity: the defect is runtime-independent and the gate pair is pinned by `enforce-orchestration-preimplementation-gate.Parity.Tests.ps1` (behavioral rows from `.Parity.Cases.ps1`, declared divergences, and the AC-18 function inventory of the two main gate files only).
- `enforce-orchestration-preimplementation-gate.EpicScopeHelperParity.Tests.ps1` pins three function texts across the two `-epic-scope.ps1` files; it does not cover `Get-OrchestrationEpicScopeDecision`, so editing that function on both surfaces needs no row there unless the plan adds one.
- `hook-cleanup-context.Parity.Tests.ps1` pins byte identity of four copies of `hook-cleanup-context.ps1` and `enforce-orchestration-preimplementation-gate-cleanup.ps1`; it is the precedent for a new shared file.

## 3. Epic checkpoint shape and the fan-in predicate

- Fields: `route_id` (`epic`), `epic_feature_folder` (slug), `epic_manifest_path`, `epic_status_doc_path`, `integration_branch`, `epic_issue_num`, `features[]` with per-feature `merge_status` (enum in `VALID_MERGE_STATUS`, `scripts/dev_tools/validate_epic_orchestrator_state.py`; required keys in `REQUIRED_EPIC_KEYS`). Skill text: `## Epic-Level Checkpoint` in `.claude/skills/epic-orchestrate/SKILL.md`.
- "Every feature merged": `features` present and non-empty, and every entry's `merge_status` is in `{merged, worktree_removed}` (`MERGED_STATUSES` in `_epic_orchestrator_state_wave_barrier.py`; `$script:TerminalMergeStatuses` in EpicScopeReadiness.psm1).
- Existing PowerShell reader: `Get-EpicPrCreationReadinessFailure -Checkpoint -HeadBranch` in `.claude/lib/worktree-resolution/EpicScopeReadiness.psm1` already returns `''` exactly when `route_id` is `epic`, `integration_branch` is non-blank and equals `HeadBranch` (case-sensitive), `features` is non-empty, and every `merge_status` is terminal. It is pure and exported, and it is already loaded by the Claude gate. Checkpoint location is solved by `Resolve-EpicScopeCheckpoint` (Claude module) and its Codex twin; no new reader is needed.
- Other readers (`enforce-epic-merge-gate.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-epic-worktree-removal-gate.ps1`) restate the terminal status pair locally; none is a better reuse target.

## 4. Branch and target-worktree resolution inside the hook

- Current branch: `Get-EpicScopeWorktreeHeadBranch` (EpicScopeResolution.psm1; Codex copy in `-epic-resolution.ps1`) reads `HEAD` of the worktree git directory through the `Get-WorktreeResolutionGitFileText` seam; `Test-EpicScopeMergeInProgress` probes `MERGE_HEAD`.
- Targets: `Get-OrchestrationCommandTarget` maps a relative file path to the session root, an absolute file path to itself, each git segment to its `-C` selector or the session root, and rejects directory changes, relocation, wrappers, and dot segments. `Resolve-EpicScopeCheckpoint -WorktreeSelector <target>` ascends to the enclosing worktree root (`Find-WorktreeResolutionRoot`), which becomes `Scope.WorktreeRoot`.
- The single-feature path resolves through `Resolve-HookTargetWorktree` (`.claude/lib/worktree-resolution/HookTargetWorktree.psm1`; Codex `hook-target-worktree.ps1`) with the recording listing invoker; `Get-HookTargetWorktreeRelativePath` (both surfaces) converts an absolute path to a root-relative one and is already used by the cleanup legs.
- Staged index: `Get-OrchestrationGateStagedIndex -WorktreeRoot` (cleanup file, both surfaces) runs `git diff --cached --name-only -z ...` through `Invoke-DocsOnlyGitExe`; `ConvertFrom-DocsOnlyNameList` parses it.

## 5. Existing tests

Claude (`tests/scripts/claude-hooks/`): `enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` (393 lines; dot-sources the gate, imports EpicScopeResolution without `-Force`, mocks `Find-WorktreeResolutionRoot`, `Get-EpicScopeCheckpointText`, `Get-EpicScopeWorktreeHeadBranch`, `Test-EpicScopeMergeInProgress` with `-ModuleName EpicScopeResolution` through `Set-EpicScopeSeam`, `Resolve-WorktreeEpicTarget` returns the session root, `Register-EpicStateBaselineMock` from `EpicStateIsolation.Baseline.Helpers.ps1`, synthetic `/synthetic-worktrees/` roots, no files). Also `.Cleanup.Tests.ps1` (receipt allow/deny rows for the consolidation worktree), `.CommandExemption.Tests.ps1`, `.EpicScopeTargets.Tests.ps1`, `.Parity.Tests.ps1`/`.Parity.Cases.ps1`, `.EpicScopeHelperParity.Tests.ps1`, `hook-cleanup-context.Parity.Tests.ps1`.
Codex (`tests/scripts/codex-hooks/`): `enforce-orchestration-preimplementation-gate-epic-scope.Tests.ps1`, `-epic-scope.Decision.Tests.ps1`, `-epic-scope-targets.Tests.ps1`, `-epic-resolution.Tests.ps1`, `-cleanup.Tests.ps1`.

Tests whose asserted behavior the change touches, with disposition:
- EpicScope rows "denies git add/Write of a production path when no merge is in progress": unchanged (production path is outside the allowlist).
- EpicScope rows for missing `epic_feature_folder`/`epic_manifest_path`/`features`: unchanged, provided the new leg runs only when the failure is exactly `merge-in-progress`.
- CommandExemption "pathless commit" deny row: unchanged (not epic scope in that fixture: `Get-WorktreeRunCheckpointText` returns `$null`).
- Cleanup receipt rows: unchanged (cleanup legs untouched).
- Parity AC-18 inventory: unchanged if no function is added to either main gate file.

## 6. Documentation, mirrors, pins, manifests

- `.claude/skills/epic-orchestrate/SKILL.md` (paragraph "Integration-PR checkpoint shape (issue #663)") and its bundle copy `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`. The `.agents` copy and its bundle copy are a Codex variant without that paragraph (not byte-identical); add an equivalent sentence there. No `.github` copy exists.
- `.claude/agents/epic-orchestrator.md` and its bundle copy (no `.github`/`.agents` copy found). Optional edit; any edit moves its pin.
- Execution-environment brief, `## Hook Execution Context`: add one bullet for #1136 in all six byte-identical copies (`.claude`, `.agents`, `.github` skills and the three bundle copies under `claude-customizations`, `codex-and-agents-customizations`, `customizations`).
- Pinned hashes: `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, consumed by `test_frozen_epic_surface_matches_pinned_baseline_digest` in `test_parallel_orchestrator_surface_contracts.py`, via `file_sha256` (raw bytes; the checkout is LF under `* text=auto eol=lf`). Update: after the final edit, compute SHA-256 of the committed LF bytes (`Get-FileHash -Algorithm SHA256`, lower-cased) for each edited file, replace the digest, and append a "RE-BASELINED by issue #1136" comment paragraph naming which digests moved, following the existing comment series.
- New files: list each new `.claude/hooks/*.ps1` in `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and each new `.codex/hooks/*.ps1` in `.../codex-and-agents-customizations/pack-manifests/core.json` (core, because the gate is in core). `test_push_down_pack_manifest_dependency_closure.py` requires every `$PSScriptRoot` dot-source of a manifested file to be in core. The Codex generator (`generate_codex_agent_variants.py --check`) manages agent-variant entries only (`PACK_FAMILIES`); hook entries appear hand-listed; run `--check` anyway. Bundle copies must be text-equal (`test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, both `*_pack_manifest_completeness.py`).
- `hook-dependency-guard-completeness.Tests.ps1` (S2/S4): dot-source the new file in its own single-statement `try { . (...) } catch { Add-HookDependencyFailure ... }`.

## 7. File sizes (logical lines, from the read view)

| File | Lines | Tier |
|---|---|---|
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | 473 | below 500 (its header calls 500 a cap) |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 387 | ok |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-cleanup.ps1` (four identical copies) | 481 | near 500 |
| `.claude/lib/worktree-resolution/EpicScopeReadiness.psm1` | 176 | ok |
| `.claude/lib/worktree-resolution/EpicScopeResolution.psm1` | 390 | ok |
| `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | 493 | near 500 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | 447 | ok |
| `tests/.../enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1` | 393 | ok; add new tests in a new file |

No in-scope file is at or above 700. Markdown files are exempt. Do not grow the two main gate files or the cleanup file.

## 8. Recommended design

Approach A (selected): a shared, byte-identical pure hook file plus a one-line hook in each surface's epic-scope decision.
- Advantages: follows the #1026 precedent (`hook-cleanup-context.ps1` + parity test), one implementation for Claude and Codex, no edit to either main gate file (AC-18 inventory unchanged), no growth of the 481/493-line files, keeps the allowance inside epic scope so it inherits target resolution, ambiguity denies, and the HEAD = `integration_branch` binding.

Rejected alternatives: (B) a Claude `.psm1` module plus a Codex function-text twin: two implementations and an extra parity mechanism for the same pure logic. (C) widening the #539 exemption to model `-F` or to admit pathless commits: not branch-bound, not fan-in-bound, and contrary to the owner constraint. (D) a leg at the final deny beside the cleanup legs: unreachable for epic-scope calls, because the epic-scope decision returns first.

New file: `hook-epic-fan-in.ps1`, byte-identical at `.claude/hooks/`, `.codex/hooks/`, and both bundle mirrors; dot-sourced (guarded) by each surface's `enforce-orchestration-preimplementation-gate-epic-scope.ps1`. Pure functions (no disk, process, or environment access except through named seams already defined by the gates):
- `Test-EpicFanInComplete -Checkpoint -Branch` -> bool. Restates the predicate of `Get-EpicPrCreationReadinessFailure` (route `epic`, `integration_branch` non-blank and `-ceq Branch`, non-empty `features`, every `merge_status` in `$script:EpicFanInTerminalMergeStatuses = @('merged','worktree_removed')`). A parity row pins the restated pair equal to `$script:TerminalMergeStatuses` read from EpicScopeReadiness.psm1 scope, and pins agreement with `Get-EpicPrCreationReadinessFailure` over a fixture matrix (Claude test only).
- `Get-EpicFanInStatusDocRelativePath -Checkpoint` -> `docs/features/epics/<epic_feature_folder>/epic-status.md`, or `$null` when the slug is blank or not a plain segment (`^[A-Za-z0-9][A-Za-z0-9._-]*$`). When `epic_status_doc_path` is present it must equal that string, else `$null`.
- `Test-EpicFanInWriteRelativePath -RelativePath -Checkpoint` -> true only for `^artifacts/pr_body_[0-9]+\.receipt\.json$` (same regex as `Test-CleanupConsolidationRelativePath -AllowReceipt`) or `^artifacts/pr_body_[0-9]+\.md$` or the status-doc path. The `.md` entries are never reached through the gate today; keep them so the helper states the full owner allowlist for the follow-ups.
- `Test-EpicFanInCommitShape -Token` -> 'add' | 'commit' | `$null`. `git [-C <abs>] add [--] <status doc>` and `git [-C <abs>] commit` with only `-m`, `--message`, `-F`, `--file`, `--trailer` (separate or `=` value) and either no pathspec or `-- <status doc>`.
- `Get-EpicFanInAllowance -Scope -FilePath -Command -StagedIndexReader` -> `[pscustomobject]@{ Allowed; Detail }`. Extension seam for findings 3 and 9: it takes an already-resolved scope object (shape of `Resolve-EpicScopeCheckpoint`, identical on both surfaces) and a staged-index reader scriptblock, so a later stop hook or follow-up leg can resolve the target worktree with its own resolver (`Resolve-HookTargetWorktree` then `Resolve-EpicScopeCheckpoint -WorktreeSelector`) and reuse the predicate. Path leg: relative path from `Get-HookTargetWorktreeRelativePath` (absolute) or the literal (relative, target = session root), then `Test-EpicFanInWriteRelativePath`. Command leg: text must pass `Test-OrchestrationCommandTextUnresolvable` = false and `Split-OrchestrationCommandLine` balanced; every segment must pass `Test-EpicFanInCommitShape`; a pathless commit requires the staged index of `Scope.WorktreeRoot` to be readable, NUL-terminated, non-empty, and exactly `{status doc}`. Never throws (errors answer not allowed).

Plug-in point (both surfaces, `Get-OrchestrationEpicScopeDecision`): the readiness scriptblock becomes "compute `Get-EpicCommandLegReadinessFailure`; if it is exactly `merge-in-progress` and `Test-EpicFanInComplete -Checkpoint $Scope.Checkpoint -Branch $Scope.Branch` and `(Get-EpicFanInAllowance ...).Allowed`, return `''`; else return the failure". Every other conjunct, every target-verdict deny, and every deny text stay unchanged. Optionally append ` Fan-in leg not applied: <code>` only when the fan-in predicate held and the path/shape check failed (mirrors the cleanup `DenySuffix` rule); recommend deferring this to keep wording pins stable.

Limits to document: a `-F` value or any token with a backslash makes the text unresolvable (use a forward-slash path or `-m`); a chained `git add && git commit` with a pathless commit reads the index before the add runs, so issue the commit as its own call or use `-- <status doc>`; the receipt Write must target the worktree that has the integration branch checked out (relative from that session, or absolute into it).

Test list (new files `tests/scripts/claude-hooks/hook-epic-fan-in.Tests.ps1`, `.../enforce-orchestration-preimplementation-gate.EpicFanIn.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-epic-fan-in.Tests.ps1`, and a byte-identity row added to a parity test; fixtures reuse `Set-EpicScopeSeam` style mocks and a mocked `Get-OrchestrationGateStagedIndex`; no temp files):
1. Fail-before: epic scope, fan-in complete, no merge in progress, Write `artifacts/pr_body_7.receipt.json` -> currently deny with `'merge-in-progress'`; after the change, allow. Same for pathless `git commit -m` with staged index exactly the status doc, and `git commit -F /scratch/msg.txt`.
2. Positive: absolute receipt path inside the integration worktree; `git -C <abs> commit -m ...` with the staged index check; `-- <status doc>` form with `-F`.
3. Negatives: one feature `merge_status` `pr_open` (incomplete fan-in) -> deny `'merge-in-progress'`; other path (`artifacts/pr_body_7.json`, `scripts/powershell/Sample.ps1`, `docs/features/epics/<other-slug>/epic-status.md`) -> deny; HEAD not the integration branch -> not epic scope, generic single-feature deny unchanged; missing or unparseable epic checkpoint -> not epic scope, generic deny; staged index with an extra path, empty, unreadable, or not NUL-terminated -> deny; commit with an unmodelled option (`--amend`, `-a`) -> deny; blank or non-plain `epic_feature_folder`, and `epic_status_doc_path` disagreeing -> deny.
4. Unit rows for each pure function, including the `$script:TerminalMergeStatuses` pin and agreement with `Get-EpicPrCreationReadinessFailure`.
5. Codex rows for the Write mapping and for an `apply_patch` adding the receipt (marker path leg).

## Pre-Mortem

- Review checklists: a reviewer can flag the allowance as a gate weakening; mitigate by keeping it inside epic scope, conditioned on the exact `merge-in-progress` failure plus `Test-EpicFanInComplete`, with the allowlist limited to the receipt/body and the slug-bound status doc, and by stating the policy-level (not security) nature in the skill text.
- Coverage: the new hook file must reach 85% line coverage in `artifacts/pester/powershell-coverage.xml`; its error-catch branch needs a row that makes the staged-index reader throw. `config/poshqc-coverage.json` derives the population, so confirm the new `.ps1` is included.
- Mirror parity: four copies of `hook-epic-fan-in.ps1`, both edited `-epic-scope.ps1` bundle copies, the epic-orchestrate skill copies (Claude and Codex variant plus bundles), the agent if edited, six execution-environment copies, both `core.json` manifests, and the `PINNED_FROZEN_SURFACE_HASHES` digests; the `Mirror parity` bullet of the plan must name the brief-update task.
- File size: the two main gate files (473, 493) and the cleanup file (481) must not grow; all new logic goes in the new file; new tests go in new files rather than the 393-line EpicScope suite.
- Test isolation: module-scoped mocks (`-ModuleName EpicScopeResolution`) and `Register-EpicStateBaselineMock` must be used as in the EpicScope suite; no global functions or environment variables; `Invoke-PoshQCLeakScan` must stay clean without new allowlist entries.
- CI-only behavior: the Linux hook-suite job is case-sensitive and has no drive letters; use `/synthetic-worktrees/` roots and forward slashes, and never read gitignored `artifacts/` state.
- Evidence: the fail-before run must be captured before the leg lands (Pester JUnit under the feature `evidence/regression-testing/`); counts and coverage come from `artifacts/pester/*.xml`, not from PoshQC MCP results.
