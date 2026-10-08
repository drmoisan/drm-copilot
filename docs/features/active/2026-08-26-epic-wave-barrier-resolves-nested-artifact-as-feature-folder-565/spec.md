# 2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder (Spec)

- **Issue:** #565 (bundles #568 and #696)
- **Parent (optional):** Epic #852 `enforcement-hook-precision`, child C2 (`docs/features/epics/enforcement-hook-precision/epic.md`)
- **Owner:** drmoisan
- **Last Updated:** 2026-10-08T14-30
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug (this file is the sole acceptance-criteria source; no `user-story.md`)
- **Design baseline:** `research/research.2026-10-08T14-00.md` (cited below as "research")

## Context

Several enforcement hooks resolve the target feature folder of a delegation by scanning the prompt for `docs/features/active/...` tokens and selecting the longest token. The selection is wrong in two ways:

1. **Nested citation.** A prompt that cites `docs/features/active/<f>/research/<x>.md` or `docs/features/active/<f>/evidence/<kind>/<x>.md` yields an artifact path as the longest token. Its basename is `research` or `<kind>`, the record lookup fails, and the hook issues a false deny.
2. **Multiple folders.** When a prompt cites the target folder and an upstream dependency folder (for example, the epic kickoff's mandated `Upstream context for ...` lines), the longer string wins. Nothing ties the selection to the declared target. During epic #770 the launch of #621 was denied because the prompt cited #508's folder (`2026-08-22-blast-radius-config-has-no-merge-decorator-508`, 57 characters), which is longer than #621's (`2026-09-29-push-down-destination-exclusion-manifest-621`, 55 characters). #508 was already merged, so the preimplementation gate failed the `merge_status` predicate for a correct launch (research section 2). In the epic wave barrier the same misselection evaluates the upstream's dependencies instead of the target's, which can fail open (#565 comment 1).

Issue #518 (PR #569) fixed the planner gate and deferred the remaining hooks to this issue. The #565 consolidation comments add the parallel cohort barrier (#566), the parallel drift gate (#567), the preimplementation gate's `-modes.ps1` resolver, and the epic child-launch occurrence from epic #770.

This child also delivers:

- **#568.** `enforce-feature-folder-order.ps1` requires `issue.md`, `spec.md`, and `user-story.md` regardless of work mode, and matches only a literal `plan.md`. Active feature folders use timestamped plan files, so the gate does not fire on them today.
- **#696.** `Get-PrdFeatureCheckpointFolder` has direct coverage only of its absent-file early return; every other suite mocks the function.

Environment: Windows 11 Pro; PowerShell 7.6.5; PreToolUse hooks under `.claude/hooks/` and `.codex/hooks/`; bundled mirrors under `extensions/drm-copilot/resources/`.

Impact / Severity: High. A false deny halts a correctly-formed delegation, and the deny reason names a folder the operator did not intend as the target. The upstream-selection direction can also evaluate the wrong record and allow a delegation whose own dependencies are unmerged.

## Repro & Evidence

Steps to reproduce (wave barrier, nested citation):

1. Prepare an epic run whose checkpoint records a target feature that legitimately satisfies the wave barrier.
2. Issue an epic-mode orchestrator delegation whose prompt cites `docs/features/active/<target>/research/<file>.md` rather than the folder alone.
3. Observe that `Find-EpicWaveBarrierFeatureFolderFromPrompt` resolves `research`, the record lookup fails, and the hook denies.

Steps to reproduce (upstream citation, #770 occurrence):

1. Epic checkpoint records features 507 (merged), 508 (merged), and 621 (`not_started`, `depends_on: [507, 508]`).
2. Issue the #621 child launch with the skill-mandated upstream lines citing the #507 and #508 folders.
3. Observe that `Find-OrchestrationDelegationTargetFolder` selects #508's folder by length and the gate denies with `PREIMPLEMENTATION_GATE_BLOCKED ... failed readiness predicate is 'merge_status'`.

Expected: every prompt form (folder alone; folder plus nested artifact; nested artifact alone; target plus upstream citation lines) resolves to the declared target folder, and the decision is identical across forms.

Current code locations (research section 1; issue line numbers have drifted):

| Resolver | Function | Length sort |
|---|---|---|
| `.claude/hooks/enforce-epic-wave-barrier.ps1` | `Find-EpicWaveBarrierFeatureFolderFromPrompt` | line 134 |
| `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | `Find-ParallelCohortBarrierFeatureFolderFromPrompt` | line 185 |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | `Find-ParallelDriftGateFeatureFolderFromPrompt` | line 233 |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `Find-OrchestrationDelegationTargetFolder` | line 236 |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | `Find-OrchestrationDelegationTargetFolder` | line 236 |

Each Claude file above has a bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/`, and the Codex file has one under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`. The complete family of length-selecting code files was derived by two independent searches with identical member sets (research, Numeric Derivation Evidence, claim N1).

## Scope & Non-Goals

- In scope:
  - A new pure shared resolver file, `feature-folder-resolution.ps1`, byte-identical in `.claude/hooks/` and `.codex/hooks/`, with bundled mirrors and pack-manifest registration.
  - Applying the shared resolution rule in the epic wave barrier, the parallel cohort barrier, the parallel drift gate, and both surfaces of the preimplementation gate's `-modes.ps1` (which covers the epic child-launch occurrence from epic #770).
  - The adjacent wave-barrier defect: `depends_on` entries recorded as issue numbers never match a record.
  - #568: work-mode-aware prerequisites and timestamped plan-file matching in `enforce-feature-folder-order.ps1`.
  - #696: direct Pester coverage of `Get-PrdFeatureCheckpointFolder`.
  - `Resolve-PrdFeatureWorkMode` in `enforce-prd-feature-before-planner-helpers.ps1` becomes a delegate to the shared work-mode parser so that one parser exists.
- Out of scope / non-goals:
  - **Upstream-only citation gap (follow-up).** A prompt that cites only an upstream folder, and not the target, still resolves to that upstream. Closing this requires adding the canonical issue-number line to the epic child kickoff contract (`.claude/skills/epic-orchestrate/SKILL.md`, kickoff element at line 118) and making it the primary signal for the epic gates. That is a skill-contract change outside C2. It is recorded here as a follow-up to be filed at completion.
  - Python in any hook, and any bash or Python port of a hook.
  - The Codex `enforce-epic-wave-barrier.ps1`: it keys on the launcher receipt or local checkpoint and does not parse prompts (research section 1.5).
  - The Codex child-launch scripts (`.codex/scripts/epic-child-launch-contract*.ps1`): they match `feature_folder` by exact equality from structured specifications.
  - `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1` and the planner gate's candidate finder: neither selects by length.
  - Guarding pre-existing unguarded sibling dot-sources across all hooks (C4, #786). C2 adds no new unguarded dot-source.
  - Adding `ValidatePattern` for absoluteness to `Get-PrdFeatureCheckpointFolder` (#696 is test-only).
  - Claude/Codex `-modes.ps1` parity test (C5b, #737). C2 makes symmetric edits so that test can pass.
- Explicitly excluded systems: GitHub workflows, `settings.json` hook registrations, `pester.runsettings.psd1`, both `enforce-orchestration-preimplementation-gate.ps1` main files.

## Root Cause Analysis

Longest-match is the wrong selection rule. The feature folder is identified structurally: it is the single path segment immediately below `docs/features/active/`. Length correlates with neither the folder (nested artifacts are longer) nor the target (an upstream folder may have a longer slug or a deeper citation).

The #518 reference (four-segment truncation, order-preserving dedupe, per-item checkpoint preference) fixes the nested case but is not sufficient for the run-level gates. Run checkpoints (`features[]`, `items[]`) record both the target and every cited upstream, so "the checkpoint names it" is true for both candidates. The #569 earliest-occurrence fallback was positional and has since been removed from the reference by #672/#673. A declared-target signal is required: dependency pruning for epic gates and the canonical issue-number line as a tie-break (research section 3).

The adjacent wave-barrier defect has a separate cause. `Test-EpicWaveBarrierDependenciesMerged` compares each `depends_on` entry to `feature_folder` by exact string equality, but the epic manifest contract records `depends_on` as `issue_num` values. An integer edge never matches, so the dependency is reported missing and the gate denies. The Python validator (`_epic_orchestrator_state_resolution.py`) and the Codex wave barrier both accept issue-number edges.

For #568, `Get-FeatureFolderMissingFile` hardcodes the full-feature set, and `Test-IsFeaturePlanPath` matches only `plan\.md$`.

## Proposed Fix

### Design summary (what changes where)

One resolution rule, implemented once in a pure shared file and parameterized per gate:

- **R1 Candidate extraction.** Scan for `docs/features/active/` tokens (any prefix, either separator). Normalize to forward slashes, truncate to exactly four segments, discard `.` segments, trim trailing sentence punctuation (`.`, `,`, `;`, `:`) from the folder segment, deduplicate in first-occurrence order, return basenames. A token with fewer than four segments yields no candidate.
- **R2 Record mapping.** Normalize each record's `feature_folder` to a basename by stripping separators, a trailing slash, and an `active/`, `completed/`, or `docs/features/<lifecycle>/` prefix (matching `_normalize_folder_hint`). Map each candidate to at most one record.
- **R3 Dependency pruning (epic gates).** Resolve `depends_on` entries through a union index: a non-string entry matches `issue_num`; a string entry matches `issue_num` when numeric, otherwise the normalized folder hint. Remove every candidate whose record is a transitive dependency of another cited candidate's record.
- **R4 Selection.** Unmatched candidates remain in the set.
  - Exactly one remaining candidate: resolved.
  - More than one remaining, and a declared issue number (from the canonical issue-number line) selects exactly one remaining record: resolved. This is a tie-break only; it cannot select a record outside the cited set.
  - Zero candidates and a fallback issue number supplied: resolve by `issue_num` (preserves the existing `-modes.ps1` decision-D3 fallback).
  - Otherwise: zero yields `NoTarget`, more than one yields `Ambiguous`. Both deny.
- **R5 Deny reasons** keep each gate's leading token. The ambiguity reason lists the remaining candidates.
- **R6** Neither string length nor prompt position participates in selection.

### Boundaries and invariants to preserve

- Leading deny tokens: `EPIC_WAVE_BARRIER_BLOCKED:`, `PARALLEL_COHORT_BARRIER_BLOCKED:`, `PARALLEL_DRIFT_GATE_BLOCKED:`, `PREIMPLEMENTATION_GATE_BLOCKED:`, `FEATURE_FOLDER_ORDER_BLOCKED:`.
- Fail closed on an unresolvable or ambiguous target, on a missing or malformed work-mode marker, and on a failed dot-source of the shared file.
- The shared file is pure: no filesystem, process, network, or environment access, and no `Import-Module`.
- Claude and Codex copies of `feature-folder-resolution.ps1` are byte-identical. Every changed or new file under `.claude/hooks/` or `.codex/hooks/` has a bundled mirror with identical content.
- No production or test file exceeds 500 lines.

### Dependencies or blocked work

- Upstream: none (epic wave 0).
- Downstream consumers of the public API defined below: C1b (#732), which edits the `-modes.ps1` family, and C6 (#787/#840), which reuses the epic checkpoint feature lookup in `validate-orchestrator-output.ps1`. The public function names and contracts below are therefore a cross-child contract.

### Implementation strategy (what changes, not sequencing)

#### Files/modules to change

Production PowerShell:

- `.claude/hooks/feature-folder-resolution.ps1` (new)
- `.codex/hooks/feature-folder-resolution.ps1` (new, byte-identical to the Claude copy)
- `.claude/hooks/enforce-epic-wave-barrier.ps1`
- `.claude/hooks/enforce-parallel-cohort-barrier.ps1` (and `enforce-parallel-cohort-barrier-helpers.ps1` only if the record lookup must change)
- `.claude/hooks/enforce-parallel-drift-gate.ps1`
- `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
- `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
- `.claude/hooks/enforce-feature-folder-order.ps1`
- `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1` (`Resolve-PrdFeatureWorkMode` delegates)
- The bundled mirror of each file above under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` or `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`.

JSON:

- `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (add the new file)
- `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (add the new file)

Tests (new unless noted):

- `tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1`
- `tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-parallel-drift-gate.FolderResolution.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1`
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1`
- `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1`
- Edit: `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` (the case "accepts a backslash-separated token and returns the longest match" encodes the defect and is rewritten).
- Edit: `tests/scripts/claude-hooks/enforce-feature-folder-order.Tests.ps1` (#568 cases; mock the new issue-content seam).
- Edit: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` (`$script:SharedModuleNames` gains the new file).

The write set exceeds the direct-mode cap of three production PowerShell files, so the run uses the orchestrated large route.

#### Functions/classes/CLI commands impacted

Public API of `feature-folder-resolution.ps1` (names are the contract consumed by C1b and C6; all functions are pure and return values without writing to the success stream beyond their return value):

| Function | Parameters | Returns | Contract |
|---|---|---|---|
| `Find-FeatureFolderCandidate` | `-Text [string]` | `[string[]]` basenames | R1. Distinct basenames in first-occurrence order. Empty array for null, empty, or no qualifying token. |
| `ConvertTo-FeatureFolderBasename` | `-Value [string]` | `[string]` or `$null` | R2. Normalizes a record value or token to a basename; `$null` when no folder segment remains. |
| `Find-FeatureFolderRecord` | `-Records [object[]]`, `-Reference [object]` | record or `$null` | Union-index lookup: a non-string or numeric-string reference matches `issue_num`; any other string matches the normalized `feature_folder`. Returns `$null` on zero or multiple matches. |
| `Select-FeatureFolderTarget` | `-Records [object[]]`, `-Candidate [string[]]`, `[-DeclaredIssueNumber [int]]`, `[-FallbackIssueNumber [int]]`, `[-DependencyAware [switch]]` | `[pscustomobject]` `{ Status; Record; Basename; Remaining; Detail }` | R2-R4. `Status` is `Resolved`, `NoTarget`, or `Ambiguous`. `Remaining` lists candidate basenames after pruning. `Detail` is a single-line description suitable for a deny reason. Selection is independent of candidate length and order. |
| `Resolve-FeatureFolderWorkMode` | `-IssueContent [string]`, `[-UnresolvedMode [string]]` (default `full-feature`) | `[string]` | Parses the persisted `- Work Mode:` marker. Returns `minor-audit`, `full-bug`, or `full-feature`; legacy `full` normalizes to `full-feature`; missing, empty, malformed, or unrecognized returns `-UnresolvedMode`, which is `full-feature` by default. The optional parameter lets `Resolve-PrdFeatureWorkMode` delegate while still returning `$null` for a missing marker. |
| `Get-FeatureFolderPlanPrerequisite` | `-WorkMode [string]` | `[string[]]` | `minor-audit`: `issue.md`. `full-bug`: `issue.md`, `spec.md`. `full-feature`: `issue.md`, `spec.md`, `user-story.md`. Any other value: the `full-feature` set. |

Callers:

- `enforce-epic-wave-barrier.ps1`: `Find-EpicWaveBarrierFeatureFolderFromPrompt` returns candidates via `Find-FeatureFolderCandidate`; target selection uses `Select-FeatureFolderTarget -DependencyAware`; `Find-EpicWaveBarrierFeatureRecord` and `Test-EpicWaveBarrierDependenciesMerged` resolve through `Find-FeatureFolderRecord`, which fixes integer `depends_on` edges.
- `enforce-parallel-cohort-barrier.ps1` and `enforce-parallel-drift-gate.ps1`: candidates via the shared finder; selection via `Select-FeatureFolderTarget` with `-DeclaredIssueNumber` from the canonical issue-number line when present. The drift gate uses the resolved basename for both the item record and the `remediation-inputs.<ts>.md` probe.
- `-modes.ps1` (both surfaces): `Find-OrchestrationDelegationTargetFolder` and `Find-OrchestrationModeRecord` become thin delegates. Epic mode uses `-DependencyAware`; the keyed `issue_num:` form supplies `-FallbackIssueNumber`. A new readiness failure name, `target-ambiguous`, is formatted by the existing `Get-OrchestrationModeDenyReason`. The readiness predicates may retype `-TargetFolder` to accept the candidate array without edits to the gate main files.
- `enforce-feature-folder-order.ps1`: `Test-IsFeaturePlanPath`, `Get-FeatureFolderMissingFile`, and a new read seam `Get-FeatureFolderIssueContent -FeatureFolder`.
- `enforce-prd-feature-before-planner-helpers.ps1`: `Resolve-PrdFeatureWorkMode` keeps its name and delegates to `Resolve-FeatureFolderWorkMode`. Its existing deny-on-unknown branch in the planner gate is unchanged.

#### Data flow and validation changes

- The three barrier hooks read and parse the run checkpoint before selecting the folder, because R2-R4 require the records. The existing "must reference the target feature folder" deny still fires first when R1 yields no candidate and no issue fallback applies.
- `enforce-feature-folder-order.ps1` gates paths matching `(^|/)docs/features/(active|archive)/[^/]+/plan(\.\d{4}-\d{2}-\d{2}T\d{2}-\d{2})?\.md$`. The `archive` lifecycle remains in scope unchanged. The feature folder is derived by stripping the matched plan leaf. Required files come from `Get-FeatureFolderPlanPrerequisite (Resolve-FeatureFolderWorkMode <issue.md content>)`. Because `issue.md` is in every set, an absent `issue.md` always denies.

#### Error handling and logging updates

- A failed dot-source of the shared file in each Claude barrier hook sets the existing import-failure variable and denies with the gate's leading token. In `-modes.ps1`, a modes-local failure flag makes the target functions return a deny-producing result.
- Ambiguity deny reasons name the remaining candidate basenames. `NoTarget` deny reasons keep the existing "must reference" wording.
- The feature-folder-order deny reason names the plan file, the resolved work mode, and the missing files.
- `Get-FeatureFolderIssueContent` returns `$null` on absence or read error; this fails closed to the full-feature set.

#### Rollback/feature-flag considerations

None. Rollback is a revert of the merge commit; each file and its mirror revert together.

### Technical specifications (interfaces/contracts)

#### Inputs/outputs and formats

- Hook input: the PreToolUse JSON envelope with nested `tool_input` (unchanged).
- Hook output: the existing allow/deny decision shape (unchanged).
- Declared issue number: the canonical issue-number line parsed by the existing `Find-WorktreeItemIssueSignal` where the hook already imports it; otherwise the existing keyed `issue_num:` form in `-modes.ps1`.

#### Required configuration keys and defaults

None. Coverage registration is automatic for files under `.claude/hooks` and `.codex/hooks` (`config/poshqc-coverage.json`).

#### Backward-compatibility expectations

- Leading deny tokens unchanged.
- Existing function names in the changed hooks remain available; their return values for single-folder prompts are unchanged.
- `-modes.ps1` decision-D3 issue-number fallback preserved.
- A prompt citing two distinct non-dependency folders now denies as ambiguous instead of selecting the longer one. This is an intended behavior change.

#### Performance constraints

Resolution is in-memory string processing over one prompt and one checkpoint. No additional file reads are introduced except the single `issue.md` read in `enforce-feature-folder-order.ps1` for plan-path writes.

## Assumptions, Constraints, Dependencies

- Assumptions: epic checkpoints copy `depends_on` as issue numbers per the manifest contract (likely; not confirmed against a live checkpoint, research section 1.1). The fix is correct for both integer and folder-string edges.
- Constraints:
  - 500-line cap per production and test file. `-modes.ps1` is at 480 (Claude) and 477 (Codex) lines; the delegation to the shared file is expected to shrink both, and neither may exceed 500. `enforce-parallel-drift-gate.ps1` is at 444 lines.
  - Line coverage >= 85% for every changed PowerShell file, including each copy of the shared file independently. Pester has no branch threshold.
  - No temporary files in tests: no `TestDrive`, no temp-file APIs. Use mocks of read seams or built-ins with absolute synthetic paths.
  - No Python in hooks.
- External dependencies: none.

## Data / API / Config Impact

- User-facing or API changes: new shared PowerShell API (table above); new `target-ambiguous` readiness failure name in the preimplementation gate.
- Data or migration considerations: none.
- Logging/telemetry: deny reason text extended as described; leading tokens unchanged.
- Compatibility notes: both `core.json` pack manifests list the new file; the Codex core manifest must contain the dot-source closure of every registered hook.

## Test Strategy

Required matrix for every changed resolver (epic wave barrier, parallel cohort barrier, parallel drift gate, Claude `-modes.ps1`, Codex `-modes.ps1`) and for the shared functions:

1. Folder alone.
2. Folder plus `research/<x>.md`, and folder plus `evidence/<kind>/<x>.md`.
3. Nested artifact alone, for both `research/` and `evidence/<kind>/`.
4. An upstream-dependency citation line naming another run member's folder. Epic: the dependency is pruned and the target selected. Parallel and drift: `Ambiguous` deny unless the canonical issue-number line selects one.
5. Two distinct non-dependency target folders: `Ambiguous` deny, leading token preserved, candidates named in the reason.
6. A token truncating to fewer than four segments (`docs/features/active/`, `docs/features/active/.`): no candidate; the existing "must reference" deny, or the D3 issue fallback in `-modes.ps1`.
7. Regression fixture for #621/#508: features 507 (merged), 508 (merged), 621 (`not_started`, `depends_on: [507, 508]`); prompt cites 621's folder plus upstream lines for 507 and 508.

Additional edge cases: trailing `.`, `,`, `;`, `:`; backslash separators; absolute-prefixed token; record values in `active/<b>` and `docs/features/active/<b>` forms; duplicate citations of one folder; a candidate that matches no record; the same two candidates in both prompt orders and with either slug longer (proves R6); integer and string `depends_on` entries.

#568 cases: each work mode; legacy `full`; missing, empty, malformed, and unrecognized markers; unreadable `issue.md`; literal `plan.md`; timestamped `plan.<yyyy-MM-ddTHH-mm>.md`; non-plan near-misses (for example `plan.2026-08-23.md`, `planning.md`, `research/plan.md`).

#696 cases (`Mock Test-Path` and `Mock Get-Content`, absolute synthetic `-CheckpointPath`, no mock of the function under test): field present; field missing; field empty; invalid JSON; `Get-Content` throws; file absent.

Invocation pattern: dot-source the hook (the `$MyInvocation.InvocationName -eq '.'` guard returns before the entrypoint), mock the target and checkpoint-read seams, and call `Invoke-*Decision -ToolInputRaw` with the nested envelope.

Toolchain: PoshQC format, analyze, and test (`mcp__drm-copilot__run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`); `poetry run pytest` for the bundle-contract and manifest tests. Coverage evidence comes from the self-hosted `Invoke-PoshQCTest` (`scripts/powershell/PoshQC/PoshQC.psd1`) and `artifacts/pester/powershell-coverage.xml`, because the MCP test summary carries no coverage figures. Coverage evidence is stored under `evidence/qa-gates/` (final QC) and `evidence/baseline/` (baseline) in this feature folder, per the canonical evidence scheme.

Known local false failure: `test_push_down_claude_resource_contracts.py` can fail locally on gitignored `.claude/state/*.json` (issue #510). CI is authoritative for that test.

## Acceptance Criteria

### Shared resolver

- [x] `.claude/hooks/feature-folder-resolution.ps1` and `.codex/hooks/feature-folder-resolution.ps1` exist and have equal SHA256 hashes, and each per-surface `feature-folder-resolution.Tests.ps1` contains a hash-equality assertion that passes.
- [x] `feature-folder-resolution.ps1` defines `Find-FeatureFolderCandidate`, `ConvertTo-FeatureFolderBasename`, `Find-FeatureFolderRecord`, `Select-FeatureFolderTarget`, `Resolve-FeatureFolderWorkMode`, and `Get-FeatureFolderPlanPrerequisite` with the parameters and return contracts stated in the Functions table of this spec.
- [x] `feature-folder-resolution.ps1` contains no `Import-Module`, no filesystem cmdlets (`Get-Content`, `Set-Content`, `Test-Path`, `Out-File`, `New-Item`, `Get-ChildItem`), no `Start-Process` or `Invoke-WebRequest`, and no `$env:` reference, verified by search of the file.
- [x] `Find-FeatureFolderCandidate` tests pass for: four-segment truncation of `research/` and `evidence/<kind>/` paths; order-preserving dedupe of repeated citations; backslash and absolute-prefixed tokens; trailing `.`, `,`, `;`, `:` trimmed; `docs/features/active/` and `docs/features/active/.` yielding no candidate.
- [x] `Find-FeatureFolderRecord` tests pass for an integer reference, a numeric-string reference, a bare folder basename, an `active/<b>` value, and a `docs/features/active/<b>` value, and return `$null` for zero or multiple matches.
- [x] `Select-FeatureFolderTarget` tests pass for `Resolved`, `NoTarget`, and `Ambiguous` outcomes, including dependency pruning with `-DependencyAware`, the declared-issue-number tie-break, the declared issue number being unable to select a record outside the cited set, and the fallback-issue-number path for zero candidates.
- [x] A `Select-FeatureFolderTarget` test supplies the same two non-dependency candidates in both orders and with either slug as the longer one, and every case returns `Ambiguous` with both candidates in `Remaining`.

### #565 resolvers

- [x] `enforce-epic-wave-barrier.ps1` resolves the target through the shared resolver, and `enforce-epic-wave-barrier.FolderResolution.Tests.ps1` passes every case of the Test Strategy matrix (items 1-7).
- [x] `enforce-epic-wave-barrier.ps1` treats a `depends_on` entry recorded as an issue number as matching the record with that `issue_num`, verified by a test that allows when that dependency is merged and denies when it is `pr_open`.
- [x] `enforce-parallel-cohort-barrier.ps1` resolves the target through the shared resolver, and `enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1` passes every case of the Test Strategy matrix (items 1-6), including a case where the canonical issue-number line resolves an otherwise ambiguous pair.
- [x] `enforce-parallel-drift-gate.ps1` resolves the target through the shared resolver, uses the resolved basename for both the item record and the `remediation-inputs` probe, and `enforce-parallel-drift-gate.FolderResolution.Tests.ps1` passes every case of the Test Strategy matrix (items 1-6).
- [x] The `enforce-parallel-drift-gate.Tests.ps1` case that expected the longest of two distinct folders is rewritten to expect an `Ambiguous` deny, and the suite passes.
- [x] `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` resolves the delegation target through the shared resolver, and the Claude `...-mode-resolution.TargetFolder.Tests.ps1` passes every case of the Test Strategy matrix (items 1-7) and the existing decision-D3 issue-number fallback cases.
- [x] `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` resolves the delegation target through the shared resolver, and the Codex `...-mode-resolution.TargetFolder.Tests.ps1` passes every case of the Test Strategy matrix (items 1-7) and the existing decision-D3 issue-number fallback cases.
- [x] #621/#508 regression: with the fixture in Test Strategy item 7, the epic wave barrier evaluates feature 621 (allow while 507 and 508 are merged; deny when 508 is `pr_open`), and the preimplementation gate on both surfaces resolves 621 and does not fail the `merge_status` predicate.
- [x] An ambiguous target produces a deny whose reason begins with the gate's existing leading token (`EPIC_WAVE_BARRIER_BLOCKED:`, `PARALLEL_COHORT_BARRIER_BLOCKED:`, `PARALLEL_DRIFT_GATE_BLOCKED:`, or `PREIMPLEMENTATION_GATE_BLOCKED:` with failure name `target-ambiguous`) and names the remaining candidates, verified by a test per gate.
- [x] A simulated dot-source failure of the shared file produces a deny decision in each of the three Claude barrier hooks and a deny-producing result from both `-modes.ps1` surfaces, verified by tests.
- [x] A search of `*.ps1` and `*.psm1` files under `.claude/`, `.codex/`, and `extensions/drm-copilot/resources/` for `Sort-Object` ordered by `Length` returns no feature-folder selection.
- [x] Existing Pester suites for the epic wave barrier, parallel cohort barrier, parallel drift gate, and preimplementation gate (both surfaces) pass without changes to their assertions other than the drift-gate case named above.

### #568 feature-folder-order

- [x] `enforce-feature-folder-order.ps1` gates both `plan.md` and `plan.<yyyy-MM-ddTHH-mm>.md` under `docs/features/active/<f>/` and `docs/features/archive/<f>/`, and does not gate the non-plan near-misses listed in the Test Strategy, verified by tests.
- [x] `enforce-feature-folder-order.ps1` requires `issue.md` for `minor-audit`; `issue.md` and `spec.md` for `full-bug`; `issue.md`, `spec.md`, and `user-story.md` for `full-feature` and legacy `full`; and the `full-feature` set when the marker is missing, empty, malformed, unrecognized, or `issue.md` is unreadable, verified by a test per case.
- [x] A plan write to a `full-bug` folder containing `issue.md` and `spec.md` only, and to a `minor-audit` folder containing `issue.md` only, is allowed; a plan write missing any mode-required file is denied with a reason beginning `FEATURE_FOLDER_ORDER_BLOCKED:` that names the plan file, the resolved work mode, and the missing files.
- [x] `enforce-feature-folder-order.ps1` reads `issue.md` only through `Get-FeatureFolderIssueContent`, and `enforce-feature-folder-order.Tests.ps1` mocks that seam so no case reads the repository filesystem.
- [x] `Resolve-PrdFeatureWorkMode` delegates to `Resolve-FeatureFolderWorkMode`, and the existing `enforce-prd-feature-before-planner` suites pass unchanged.

### #696 Get-PrdFeatureCheckpointFolder

- [x] `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1` calls `Get-PrdFeatureCheckpointFolder` with an absolute synthetic `-CheckpointPath` and does not mock `Get-PrdFeatureCheckpointFolder`.
- [x] That suite passes for: field present (returns the value, and asserts `Test-Path` and `Get-Content -Raw` were invoked with the exact `LiteralPath`); field missing; field empty; invalid JSON; `Get-Content` throwing; and file absent (returns `$null` and asserts `Get-Content` was not invoked).

### Mirrors, manifests, and parity

- [x] Every new or changed file under `.claude/hooks/` has a bundled mirror under `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` with an equal SHA256 hash.
- [x] Every new or changed file under `.codex/hooks/` has a bundled mirror under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` with an equal SHA256 hash.
- [x] Both `pack-manifests/core.json` files list `feature-folder-resolution.ps1`, and `$script:SharedModuleNames` in `legacy-codex-hook-contracts.Tests.ps1` includes it.
- [ ] `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_codex_core_manifest_closure.py`, `codex-epic-runtime-contracts.Tests.ps1`, and `legacy-codex-hook-contracts.Tests.ps1` pass in CI on the pull request.

### Size, coverage, purity, and toolchain

- [x] No new or changed production or test file exceeds 500 lines, including both `enforce-orchestration-preimplementation-gate-modes.ps1` copies and `enforce-parallel-drift-gate.ps1`, verified by line count.
- [x] Line coverage is at least 85% for every new or changed production PowerShell file, including each copy of `feature-folder-resolution.ps1` measured independently, as reported in `artifacts/pester/powershell-coverage.xml` from the self-hosted `Invoke-PoshQCTest` run and recorded under `evidence/qa-gates/`.
- [x] No new or changed test file uses `TestDrive`, `New-TemporaryFile`, `[System.IO.Path]::GetTempPath`, or `[System.IO.Path]::GetTempFileName`, and the PowerShell test-purity hook raises no finding on them.
- [x] No Python file is added under `.claude/hooks/` or `.codex/hooks/`, and no changed hook invokes `python`, `py`, or `poetry`.
- [x] PoshQC format, analyze, and test complete without errors on all changed PowerShell files in a single pass.

## Risks & Mitigations

- **Behavior change for two-folder prompts.** Prompts that cite two non-dependency folders now deny instead of selecting one. Mitigation: the ambiguity reason names the candidates; the parallel and drift gates accept the canonical issue-number line as a tie-break.
- **Upstream-only citation.** A prompt citing only an upstream folder still resolves to that upstream. Mitigation: recorded follow-up to add the canonical issue-number line to the epic kickoff contract.
- **#568 activation.** The gate begins to fire on timestamped plan writes in active and archived folders. Mitigation: work-mode-aware prerequisites; the work-mode change and the regex change land in the same pull request, because the regex change alone would deny most active folders that lack `user-story.md`. Archived folders without a marker are held to the full-feature set.
- **Merge conflict with C1b (#732).** C1b edits `-modes.ps1`. Mitigation: C2 merges first (wave 0); C2 reduces `-modes.ps1` line count, which leaves C1b headroom.
- **Mirror drift.** Mitigation: hash-equality assertions and bundle-parity tests.

## Rollout & Follow-up

- Release: merge into `epic/enforcement-hook-precision-integration` through the epic child pull request; the PR closes #565, #568, and #696. An epic-child PR may require a manual `workflow_dispatch` of `ci.yml` to obtain CI results.
- Follow-up to file at completion: add the canonical issue-number line to the epic child kickoff contract (`.claude/skills/epic-orchestrate/SKILL.md`) and make it the primary target signal for the epic wave barrier and the epic leg of the preimplementation gate.
- Downstream notification: C1b (#732) and C6 (#787/#840) consume the shared API defined in this spec.
- Links: issue #565 (consolidates #566, #567), #568, #696; reference fix PR #569 (#518), revised by PR #695 (#672, #673); epic #852; occurrence epic #770.
