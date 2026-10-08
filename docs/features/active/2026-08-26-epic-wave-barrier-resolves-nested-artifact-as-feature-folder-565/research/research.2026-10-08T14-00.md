# Research: Feature-Folder Target Resolution Across Enforcement Hooks (Issue #565, bundling #568 and #696)

- Issue: #565 (work mode full-bug); bundled #568, #696
- Epic: #852 enforcement-hook-precision, child C2
- Branch: `bug/epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565` (from `origin/epic/enforcement-hook-precision-integration`)
- Researched: 2026-10-08
- Mode: preparation (research only; no production, test, or policy file changed)

## 0. Sources and Method

Verified by direct reads of the current tree (all line numbers below are against this worktree), repository-wide ripgrep searches, and the GitHub REST API (fetched through WebFetch because the `gh` CLI is not available to this agent):

- `GET /repos/drmoisan/drm-copilot/issues/565/comments` (three comments, 2026-09-08, 2026-09-29, 2026-09-30).
- `GET /repos/drmoisan/drm-copilot/issues/568`, `.../issues/696`, `.../pulls/569` (body only; merged 2026-08-26, merge commit `958d0d2b3e41ed20dc05b96b17aa14266a052253`).
- The PR #569 diff was not fetched. The reference implementation was read from the current tree instead, because it has since been revised by #672/#673 (PR #695) and the current form is the one this child must align with (Section 3).

Corrections to stale statements in `issue.md` and `spec.md`:

- The line numbers cited in the issues have drifted. Current locations: `enforce-epic-wave-barrier.ps1:134` (not 99), `enforce-parallel-cohort-barrier.ps1:185` (not 150), `enforce-parallel-drift-gate.ps1:233` (not 196); `-modes.ps1:236` is unchanged.
- "Exactly eight files" is stale. The current count is ten code files (Section 1.5 and Numeric Derivation Evidence), because the #554 Codex port added a Codex copy of `-modes.ps1` and its bundled mirror.
- The #518 fallback "earliest occurrence" no longer exists in the reference hook. #672/#673 removed it; an unresolved multi-folder tie now denies with the ambiguity reason code (Section 3).
- The #518 objection to a shared module ("two `pester.runsettings.psd1` edits") no longer applies. Issue #527 removed the coverage `Path` list; coverage population is derived from `config/poshqc-coverage.json`, whose roots already include `.claude/hooks`, `.claude/lib`, and `.codex/hooks` (`scripts/powershell/PoshQC/settings/pester.runsettings.psd1:23-24`, `config/poshqc-coverage.json:3-9`).

## 1. Current Behavior of Each Affected Resolver (Q1)

All four Claude resolvers share one shape: scan the prompt with `docs[\\/]+features[\\/]+active[\\/]+[^\s"'``]+`, normalize, deduplicate, sort by string length descending, take the first element, strip a `.md` leaf, and return the last path segment. The defect has two parts, and both apply to each resolver:

1. Nested citation: `docs/features/active/<f>/research/<x>.md` reduces to `.../<f>/research`, whose basename is `research`. `docs/features/active/<f>/evidence/<kind>/<x>.md` reduces to `evidence/<kind>`'s last segment. The record lookup then fails.
2. Multiple folders (the upstream-dependency citation): with two folder tokens, the longer string wins, which is the folder with the longer slug or the more deeply cited path. Nothing ties the selection to the delegation's actual target.

### 1.1 `.claude/hooks/enforce-epic-wave-barrier.ps1` (381 lines)

- `Find-EpicWaveBarrierFeatureFolderFromPrompt` at lines 95-142. Pattern at 122; the hashtable dedupe at 128-132 (unordered); `Sort-Object -Property Length -Descending` at 134; `.md` parent strip at 137-139; basename at 141.
- Called at 315 after the epic target worktree is resolved by `integration_branch:` (310-313). An empty result denies at 316-318 with `EPIC_WAVE_BARRIER_BLOCKED: an epic-mode orchestrator delegation must reference the target feature folder...`.
- Record lookup `Find-EpicWaveBarrierFeatureRecord` (144-183) compares `feature_folder` by exact string equality (178). It does not normalize a lifecycle prefix such as `active/<b>`.
- Adjacent defect, verified by reading: `Test-EpicWaveBarrierDependenciesMerged` resolves each `depends_on` entry through the same exact-folder comparison (223-226). The epic manifest contract makes `depends_on` an array of `issue_num` values (`.claude/skills/epic-orchestrate/SKILL.md:49,59-61`), and both the Python validator (`scripts/dev_tools/_epic_orchestrator_state_resolution.py:74-149`, union index of issue_num and folder hint) and the Codex wave barrier (`.codex/hooks/enforce-epic-wave-barrier.ps1:62-86`, matches `issue_num` or basename) accept issue-number edges. The Claude hook stringifies an integer edge and compares it to `feature_folder`. That never matches, so the dependency is reported missing and the gate denies. This is fail-closed, but it is wrong for every dependent child whose checkpoint carries issue-number edges. Whether live epic checkpoints copy issue-number edges is likely given the manifest contract, but no live checkpoint was available to confirm it.
- Comment 1 on #565 (2026-09-08) records the fail-open direction: when the upstream folder wins, the barrier evaluates the upstream's dependencies rather than the target's, and those are typically already merged.

### 1.2 `.claude/hooks/enforce-parallel-cohort-barrier.ps1` (331 lines; helpers 278 lines)

- `Find-ParallelCohortBarrierFeatureFolderFromPrompt` at 147-187. Pattern at 173; hashtable dedupe at 179-183; sort at 185; basename via `Get-ParallelCohortBarrierFolderBasename` (113-145, which handles separators, trailing slash, and a `.md` leaf).
- Called at 265; an empty result denies at 266-268 with `PARALLEL_COHORT_BARRIER_BLOCKED: ...`. Record lookup is `Find-ParallelCohortBarrierItemRecord` (`enforce-parallel-cohort-barrier-helpers.ps1:31`, basename-normalized at 65).

### 1.3 `.claude/hooks/enforce-parallel-drift-gate.ps1` (444 lines)

- `Find-ParallelDriftGateFeatureFolderFromPrompt` at 209-238. Pattern at 222; hashtable dedupe at 228-231; sort at 233; `.md` strip at 234-236.
- Called at 355; an empty result denies at 356-358 with `PARALLEL_DRIFT_GATE_BLOCKED: ...`. Item lookup `Find-ParallelDriftGateItemRecord` (240-271) compares the case-sensitive basename (266). The resolved basename is also the folder probed for `remediation-inputs.<ts>.md` at 394, so a misresolution changes both the record and the finding probe.
- The test `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1:302-305` ("accepts a backslash-separated token and returns the longest match") encodes the longest-match rule with two distinct folders. It must be rewritten.

### 1.4 `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` (480 lines) and `.codex/hooks/...-modes.ps1` (477 lines)

- `Find-OrchestrationDelegationTargetFolder` at 215-251 (identical logic on both surfaces). Pattern at 230; an ordered dictionary keyed on the raw token (234-235), so `a/` and `a` do not collapse; sort at 236; punctuation trim at 242-245; `.md` strip at 246; basename at 248.
- `Find-OrchestrationModeRecord` (331-363) matches the folder basename first and `issue_num` second. The issue number comes from `Find-OrchestrationDelegationIssueNumber` (253-275): a keyed `issue_num:` form first, then a bare `#N` form (272) that also matches pull-request references.
- The epic and parallel readiness predicates return `target-record` when no record is found (404, 459) and `merge_status` when the record is terminal (405, 460).
- Callers: `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:385-391` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1:426-427`. The predicates bind `-TargetFolder` as `[string]`.
- Headroom: Claude has 20 lines left (480/500) and Codex has 23 (477/500). C1b (#732) also edits this file.

### 1.5 Complete enumeration of longest-match selection

Primary search: `Sort-Object -Property Length -Descending` and its variants. Cross-check: the shared prompt-scan regex, plus the word "longest" in code under `.claude`, `.codex`, and the bundles. Ten code files match. Full derivation is in the Numeric Derivation Evidence section.

| # | File | Line |
|---|---|---|
| 1 | `.claude/hooks/enforce-epic-wave-barrier.ps1` | 134 |
| 2 | `.claude/hooks/enforce-parallel-cohort-barrier.ps1` | 185 |
| 3 | `.claude/hooks/enforce-parallel-drift-gate.ps1` | 233 |
| 4 | `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 236 |
| 5 | `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1` | 236 |
| 6-9 | `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` mirrors of 1-4 | 134/185/233/236 |
| 10 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` mirror of 5 | 236 |

Out of scope, but verified because they also scan for feature folders: `enforce-prd-feature-before-planner-helpers.ps1:187` (already fixed by #518/#672), and `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:53`, whose first-match pattern stops at the basename and so truncates inherently. Neither selects by length. The Codex `enforce-epic-wave-barrier.ps1` does not parse prompts. It keys on the launcher receipt or the local checkpoint (`.codex/hooks/enforce-epic-wave-barrier.ps1:39-109`), so it needs no change. The Codex runtime has no cohort-barrier, drift-gate, feature-folder-order, or prd-feature hook (`.codex/hooks/` listing).

## 2. The Epic Child-Launch Gate (Q2)

Comment 3 on #565 (2026-09-30) reports that during epic #770 "the launch for #621 was denied because the prompt cited the longer feature-folder name belonging to #508." Most likely the gate was the epic-mode delegation leg of `enforce-orchestration-preimplementation-gate.ps1`, with the selection made at `-modes.ps1:236`. It is not a separate resolver. The chain below was established by code reading and the folder names in the tree; the event itself was not reproduced.

1. A child launch is `Agent(orchestrator)` with `Epic mode: true` (`.claude/skills/epic-orchestrate/SKILL.md:115-118`). `Test-ImplementationDelegation` classifies every non-preparation orchestrator delegation as implementation (`enforce-orchestration-preimplementation-gate.ps1:204-223`), so the gate's epic branch runs (369-395).
2. The dependent child's prompt carries one `Upstream context for <issue_num>: depends on <dep> (spec: <dep_resolved_folder>/spec.md; plan: ...)` line per dependency (`epic-orchestrate/SKILL.md:189-202`). #621 depends on #507 and #508 (`docs/features/epics/push-down-payload-correctness/epic.md:97`).
3. The slugs are `2026-08-22-blast-radius-config-has-no-merge-decorator-508` (57 characters) and `2026-09-29-push-down-destination-exclusion-manifest-621` (55 characters). Both folders are under `docs/features/active/` in this tree. At equal citation depth the #508 token is longer, and an upstream `.../spec.md` citation is longer still than a bare target folder.
4. `Find-OrchestrationModeRecord` returns #508's record. At #621's launch #508 was merged, so `Test-OrchestrationModeTerminalMergeStatus` returns true and the predicate fails with `merge_status` (`-modes.ps1:405`). The result is `PREIMPLEMENTATION_GATE_BLOCKED ... failed readiness predicate is 'merge_status'`, a denial of a correct launch.
5. The same prompt reaches `enforce-epic-wave-barrier.ps1`, which evaluates #508's dependencies. Comment 1 calls this direction fail-open.

The Codex child-launch scripts (`.codex/scripts/epic-child-launch-contract.ps1`, `-runtime.ps1`) match `feature_folder` by exact equality from structured launch specifications (for example `epic-child-launch-contract.ps1:216,252`). They contain no length selection.

## 3. The #518 Reference Fix and the Declared-Target Requirement (Q3)

### 3.1 Current reference implementation

`.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`:

- `Find-PrdFeatureFolderCandidate` (163-209) returns the distinct folders in first-occurrence order, using a `List[string]` because hashtable order is unspecified (193-206).
- `ConvertTo-PrdFeatureFolderToken` (98-161) truncates to exactly four segments (155-160) and discards `.` segments, so `docs/features/active/.` is rejected. It normalizes absolute prefixes through `ConvertTo-WorktreeResolutionRepoRelativePath`, which reads git worktree metadata, so it is not pure.
- `Find-PrdFeatureFolderFromPrompt` (251-305) uses a single candidate directly and resolves two or more against the resolved worktree's own checkpoint (`Select-PrdFeatureFolderByCheckpoint`, 211-249). An unresolved tie returns `$null` and the hook denies with the ambiguity reason code (`enforce-prd-feature-before-planner.ps1:371-373`). Prompt position is explicitly rejected as a disambiguator (helpers 217-222).

### 3.2 Sufficiency

- Nested artifacts: four-segment truncation is sufficient. Folder alone, folder plus `research/`, folder plus `evidence/<kind>/`, and nested-only all reduce to one candidate.
- The upstream-dependency citation: the reference is not sufficient for the run-level gates. Its disambiguator is a per-item checkpoint that records exactly one `feature-folder`. The epic and parallel gates read a run checkpoint whose `features[]` / `items[]` record both the target and the cited upstream, so "the checkpoint names it" is true for both candidates. The #569 positional fallback would pick whichever line came first, and the kickoff contract does not fix that order. The tie must be broken by a declared-target signal.

### 3.3 Declared-target signal per gate (verified)

| Gate | Records consulted | Declared target signals available in the prompt | Verified at |
|---|---|---|---|
| Epic wave barrier (Claude) | epic checkpoint `features[]` | folder token(s). The kickoff line carries no target field. Upstream lines name dependency folders. The canonical issue-number line is not mandated for epic-marked orchestrator delegations. | `epic-orchestrate/SKILL.md:118,193`; `orchestrate/SKILL.md:278` |
| Preimplementation gate, epic mode (both surfaces) | epic checkpoint `features[]` | as above, plus the keyed `issue_num:` and `#N` forms | `-modes.ps1:253-275` |
| Preimplementation gate, parallel mode | parallel checkpoint `items[]` | folder token (kickoff element 2) and the canonical issue-number line (element 3) | `parallel-orchestrate/SKILL.md:244-259` |
| Parallel cohort barrier | parallel checkpoint `items[]` | same as parallel mode | same |
| Parallel drift gate (feature-review) | parallel checkpoint `items[]` | folder token and the canonical issue-number line, which is mandatory for feature-review | `orchestrate/SKILL.md:263,272-274` |

The canonical issue-number line already has a strict, case-sensitive parser that returns distinct numbers in order: `Find-WorktreeItemIssueSignal` (`.claude/lib/worktree-resolution/WorktreeItemResolution.psm1:40,105-...`, exported at 398-407).

### 3.4 Recommended resolution rule (one rule, parameterized per gate)

R1. Candidate extraction (pure). Scan with a pattern that keeps any prefix but reads the remainder from the `docs/features/active/` index. Truncate to four segments, discard `.` segments, trim trailing sentence punctuation (`.`, `,`, `;`, `:`) from the folder segment, and deduplicate in first-occurrence order. Return basenames. A token with fewer than four segments yields no candidate. No filesystem access: the run gates place the checkpoint by run identity (`integration_branch:` or `parallel_slug:`), not by a path prefix.

R2. Record mapping. Normalize every record's `feature_folder` to a basename. Strip separators, a trailing slash, and the `active/`, `completed/`, or `docs/features/<lifecycle>/` prefix, matching `_normalize_folder_hint` in the Python validator. Map each candidate to at most one record.

R3. Dependency exclusion (epic gates only). Resolve `depends_on` with the union index (non-string to `issue_num`, string to folder hint), mirroring `resolve_feature_reference`. Remove every candidate whose record is a transitive dependency of another cited candidate's record. This handles the skill-mandated upstream lines.

R4. Selection. Unmatched candidates stay in the remaining set, because a cited folder that is not a run member cannot be excluded.
- Exactly one remaining candidate with a record: that is the target.
- More than one remaining, and the caller supplied a declared issue number (the canonical line; for parallel and drift, mandatory upstream) that selects exactly one remaining record: that record is the target. This is a tie-break only. It cannot select a record outside the cited set.
- Zero candidates, and the caller supplied an issue number: resolve by `issue_num` (preserves the `-modes.ps1` decision-D3 fallback and its existing tests).
- Otherwise: zero gives NoTarget and more than one gives Ambiguous. Both deny.

R5. Fail-closed reasons keep each gate's leading token: `EPIC_WAVE_BARRIER_BLOCKED:`, `PARALLEL_COHORT_BARRIER_BLOCKED:`, `PARALLEL_DRIFT_GATE_BLOCKED:`, and for the preimplementation gate `PREIMPLEMENTATION_GATE_BLOCKED:` via a new failure name, for example `target-ambiguous`. `Get-OrchestrationModeDenyReason` (`-epic-scope.ps1:112-125`) formats any failure name, so it needs no change. The ambiguity reason should list the remaining candidates.

R6. Neither string length nor prompt position takes part in selection.

Residual risk, recorded rather than solved: a prompt that cites only an upstream folder still resolves to that upstream. This direction already exists today. Closing it would require a mandatory target field in the epic kickoff line, which is a skill-contract change outside C2's declared scope. Recommend a follow-up that adds the canonical issue-number line to the epic child kickoff (`epic-orchestrate/SKILL.md:118`) and makes it the primary signal for the epic gates.

Ordering consequence: R2-R4 need the run checkpoint's records, so the three barrier hooks must read and parse the checkpoint before selecting the folder. Today the folder check (315/265/355) runs before the read (320/270/360). The "must reference a folder" deny still fires first when R1 yields no candidate and no issue fallback applies.

## 4. Shared Helper Decision (Q4)

### 4.1 Constraints found

- Codex hooks import no `.claude/lib` module. Every `.codex/hooks` dependency is a dot-sourced sibling (search of `.codex/hooks` for `Import-Module`: none), and the Codex pack manifest lists no `.claude/` path. A `.claude/lib` module therefore cannot serve the Codex `-modes.ps1`.
- There is precedent for cross-surface shared code. `hook-command-scanner.ps1` and `hook-command-invocation.ps1` exist byte-identically in `.claude/hooks` and `.codex/hooks` (483 lines each), are documented as "shared by the Claude and Codex enforcement hooks" (`.codex/hooks/hook-command-scanner.ps1:3`), are pure, are dot-sourced, and have per-surface test files (`tests/scripts/claude-hooks/hook-command-scanner.Tests.ps1`, `tests/scripts/codex-hooks/hook-command-scanner.Tests.ps1`).
- Headroom: the corrected selector (R1-R4) is roughly 70-100 lines. It does not fit inline in either `-modes.ps1` (20 and 23 lines left), so option (b) also forces a headroom split there.
- Coverage registration is automatic for new files under `.claude/hooks`, `.claude/lib`, and `.codex/hooks` (`config/poshqc-coverage.json`). A new file adds no `pester.runsettings.psd1` edit.
- Packaging: the Claude bundle must contain every distributable `.claude` file with equal text (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110`). Every bundled hook must be listed in a Claude pack manifest (`test_push_down_claude_pack_manifest_completeness.py:139`). The Codex core manifest must contain the dot-source closure of every registered hook (`test_codex_core_manifest_closure.py:277`).

### 4.2 Options

| | (a) `.claude/lib` module | (b) per-hook duplication | (c) recommended: pure shared `.ps1`, byte-identical on both surfaces |
|---|---|---|---|
| Implementations of R1-R4 | 2 (the lib module plus a Codex sibling, because Codex cannot import lib) | 5 (wave, cohort, drift, Claude modes, Codex modes) plus a headroom sibling per modes surface | 1 (two byte-identical copies) |
| C1b/C6 consumption | Claude only | copy again | both surfaces; C6's `validate-orchestrator-output.ps1` can dot-source it |
| Drift risk | Claude and Codex logic can diverge | highest | low; the copies are byte-checked by test |
| `-modes.ps1` size | shrinks on Claude; Codex still needs a sibling | still needs a split | both shrink (finder and record lookup become thin delegates), which gives C1b room |

Recommendation: (c). Add `feature-folder-resolution.ps1` (name indicative) to `.claude/hooks/` and `.codex/hooks/`, byte-identical, pure (no filesystem, process, network, or environment access, no `Import-Module`), and dot-sourced. Proposed API, all pure:

- `Find-FeatureFolderCandidate -Text` returns `[string[]]` of distinct basenames in first-occurrence order (R1).
- `ConvertTo-FeatureFolderBasename -Value` normalizes a record value or token (R2).
- `Find-FeatureFolderRecord -Records -Reference` is the union-index lookup (issue_num or folder hint). It is the epic checkpoint feature lookup C6 reuses, and it fixes the wave barrier's dependency lookup (1.1).
- `Select-FeatureFolderTarget -Records -Candidate [-DeclaredIssueNumber] [-FallbackIssueNumber] [-DependencyAware]` returns `{ Status = Resolved|NoTarget|Ambiguous; Record; Basename; Remaining; Detail }` (R3-R4).
- `Resolve-FeatureFolderWorkMode -IssueContent` and `Get-FeatureFolderPlanPrerequisite -WorkMode` (for #568; Section 6).

A dot-source that fails must deny, not fail open. In the three Claude barrier hooks, wrap the new dot-source with the existing import-failure variable pattern (for example `enforce-epic-wave-barrier.ps1:43-50`). In `-modes.ps1`, which is itself dot-sourced unguarded by the gate, a guard needs a modes-local failure flag that makes the target functions return a deny-producing result. Guarding all pre-existing sibling dot-sources is C4's (#786) scope. C2 should not add a new unguarded one in the Claude barrier hooks.

### 4.3 Write sets

Option (c), recommended. Production PowerShell (18 files):

1. `.claude/hooks/feature-folder-resolution.ps1` (new)
2. `.claude/hooks/enforce-epic-wave-barrier.ps1`
3. `.claude/hooks/enforce-parallel-cohort-barrier.ps1`
4. `.claude/hooks/enforce-parallel-drift-gate.ps1`
5. `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
6. `.claude/hooks/enforce-feature-folder-order.ps1`
7. `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1`: optional but recommended. `Resolve-PrdFeatureWorkMode` (29-62) becomes a one-line delegate to the shared parser and keeps its name for existing tests. This removes a second parser. If excluded, record a follow-up.
8. `.codex/hooks/feature-folder-resolution.ps1` (new, byte-identical to 1)
9. `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
10-16. `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` mirrors of 1-7
17-18. `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/` mirrors of 8-9

JSON: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` and `extensions/drm-copilot/resources/codex-and-agents-customizations/pack-manifests/core.json` (add the new file to each).

Unchanged by design: both `enforce-orchestration-preimplementation-gate.ps1` main files (Claude 466 lines, Codex 487). The readiness predicates' `-TargetFolder` parameter can be retyped to `[string[]]` inside `-modes.ps1`, so the callers at Claude 385-391 and Codex 426-427 bind an array without edits. `enforce-prd-feature-before-planner.ps1` (#696 is test-only). The Codex wave barrier. `settings.json`. `pester.runsettings.psd1`.

Option (a), for comparison: `.claude/lib/feature-folder/FeatureFolderResolution.psm1` plus mirror, Claude hooks 2-7 plus mirrors, a Codex sibling `.codex/hooks/<name>.ps1` plus mirror, Codex modes plus mirror, and both `core.json` files. That is about 20 files and two implementations.

Option (b), for comparison: hooks 2-6 plus mirrors, Codex modes plus mirror, a headroom sibling for each modes surface plus mirrors and manifest entries. That is about 18 files and five copies of the selector.

All three exceed the direct-mode cap of three production PowerShell files (`.claude/rules/powershell.md:39-41`). The run must use the orchestrated large path.

## 5. Mirrors, Line Counts, and Parity (Q5)

| File | Lines (Claude / mirror) | Codex copy (lines) | Codex mirror |
|---|---|---|---|
| `enforce-epic-wave-barrier.ps1` | 381 / 381 | separate implementation (295), unchanged | n/a |
| `enforce-parallel-cohort-barrier.ps1` | 331 / 331 | none | n/a |
| `enforce-parallel-cohort-barrier-helpers.ps1` | 278 / 278 (only if touched) | none | n/a |
| `enforce-parallel-drift-gate.ps1` | 444 / 444 | none | n/a |
| `enforce-orchestration-preimplementation-gate-modes.ps1` | 480 / 480 | 477 (not byte-identical to Claude; header says "Codex surface") | 477 |
| `enforce-feature-folder-order.ps1` | 197 / 197 | none | n/a |
| `enforce-prd-feature-before-planner.ps1` | 477 / 477 | none | n/a |
| `enforce-prd-feature-before-planner-helpers.ps1` | 332 / 332 | none | n/a |

Line counts were taken by ripgrep line counting on the current tree.

Parity guards:

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:89-110`: every distributable `.claude` file must exist in the bundle with equal UTF-8 text (`read_text`). Byte equality applies only to the planner-review resources (113-123). Known local false failure: gitignored `.claude/state/*.json` counters (issue #510; memory note). It passes in CI.
- `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:215-229`: the same text-equality check for `.codex`.
- `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:162-183`: SHA256 root/bundle identity for a listed path set, and the 500-line cap for every `.codex/hooks/*.ps1`.
- `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:30`: `$script:SharedModuleNames` (static checks: parse, 500-line cap, root/bundle byte identity). Add the new Codex shared file here.
- Pack manifests: `test_push_down_claude_pack_manifest_completeness.py:139`, `test_push_down_codex_and_agents_pack_manifest_completeness.py`, `test_codex_core_manifest_closure.py:277`.
- No repository sync script for these mirrors was found (search of `scripts/**` for sync/mirror/bundle names returned only unrelated tools). Mirrors are kept identical by writing the same content to both paths and verifying with the parity tests and a hash comparison (#518 recorded SHA-1 equality as evidence).
- Claude/Codex `-modes.ps1` parity is not test-enforced today. C5b (#737) adds that test. C2 should make symmetric edits so C5b's test can pass.

## 6. #568: `enforce-feature-folder-order.ps1` (Q6)

Current behavior:

- `Get-FeatureFolderMissingFile` derives the folder with `-replace '/plan\.md$'` (61) and always requires `issue.md`, `spec.md`, and `user-story.md` (62).
- `Test-IsFeaturePlanPath` (87) matches only `(^|/)docs/features/(active|archive)/[^/]+/plan\.md$`.
- `Invoke-FeatureFolderOrderDecision` reads `file_path` (120), normalizes separators (125), and gates only matching paths (127-131). The deny reason starts `FEATURE_FOLDER_ORDER_BLOCKED:` (141).
- The hook is registered on `Write|Edit` (`.claude/settings.json:127-157`). There is no Codex copy.

Change:

1. Path match: `(^|/)docs/features/(active|archive)/[^/]+/plan(\.\d{4}-\d{2}-\d{2}T\d{2}-\d{2})?\.md$`, with the folder derived by stripping the same suffix.
2. Add an injectable read seam, for example `Get-FeatureFolderIssueContent -FeatureFolder`, following `Get-PrdFeatureIssueContent` (`enforce-prd-feature-before-planner.ps1:129-153`). Test-Path plus `Get-Content -Raw` in try/catch returns `$null` on absence or error.
3. Mode to prerequisites, per the issue.md acceptance conditions: `minor-audit` requires `issue.md`; `full-bug` requires `issue.md` and `spec.md`; `full-feature` and legacy `full` require all three. A missing, unreadable, or unrecognized marker fails closed to the full-feature set. This intentionally differs from the planner gate, which denies on its own branch. Because `issue.md` is in every set, an absent `issue.md` always denies.
4. Reuse rather than a new parser: the only existing parser is `Resolve-PrdFeatureWorkMode` (`enforce-prd-feature-before-planner-helpers.ps1:29-62`, regex at 52, mirroring `scripts/dev_tools/prompt_mode_contract.py`). Dot-sourcing that helpers file is not recommended. It carries an unguarded `Import-Module` of `WorktreeResolution.psm1` (27) into a hook that fires on every Write and Edit. Host the parser in the shared resolver file (Section 4) and have the planner helper delegate.
5. Keep the leading token. The reason should name the actual plan file and the resolved work mode.

Activation risk, verified: all 41 active feature folders in this tree use timestamped plan files only (`docs/features/active/*/plan*.md`), so the gate currently never fires there.

- After the fix, every one of the 41 is allowed. Each has a `- Work Mode:` marker and the files its mode requires (25 full-bug with `spec.md`, 2 full-feature with `spec.md` and `user-story.md`, 14 minor-audit).
- This run's own folder (#565, full-bug, `issue.md` and `spec.md` present) is allowed, so the atomic-planner's plan writes are unaffected.
- If the regex alone were fixed without the work-mode change, 38 of 41 folders would be denied. Only #645, #690, and #621 carry `user-story.md`.
- `docs/features/archive/` contains at least 29 folders with timestamped plans that would also come under the gate. Their markers were not audited. An edit to an archived plan without a marker would be held to the full-feature set. Keep `archive` in the regex (unchanged scope), or remove it as a deliberate decision recorded in the spec.

## 7. #696: Direct Coverage of `Get-PrdFeatureCheckpointFolder` (Q7)

Function: `enforce-prd-feature-before-planner.ps1:155-184`. It takes a mandatory `[string] $CheckpointPath`. Test-Path returns `$null` when the file is absent (168-170). `Get-Content -Raw` and `ConvertFrom-Json` run in try/catch, returning `$null` on error (172-178). It returns the `feature-folder` field when present and non-empty (180-183). The only production caller composes an absolute path through `Get-WorktreeItemCheckpointPath`, which throws on a non-absolute root (`WorktreeItemResolution.psm1:59-76`). Every call site passes `-CheckpointPath` explicitly, which `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1:108-115` enforces. The function itself has no `ValidatePattern` for absoluteness, unlike the barrier read seams (for example `enforce-epic-wave-barrier.ps1:67`).

Existing coverage: one absent-file case (`enforce-prd-feature-before-planner.Tests.ps1:207-209`). Every other suite mocks the function itself.

Repository precedent for testing file reads without files:

- `Mock Test-Path` plus `Mock Get-Content` with an absolute synthetic path and `-ParameterFilter`/`Should -Invoke` on `$LiteralPath` (`enforce-orchestration-preimplementation-gate.EpicScope.Tests.ps1:256-291`).
- The same suite family mocks the built-ins for `Get-PrdFeatureIssueContent` (`enforce-prd-feature-before-planner.Tests.ps1:296-300`).
- `TestDrive` has zero uses under `tests/`, and the purity hook bans temp-file APIs (`check-powershell-test-purity.ps1:105-109`).

Recommendation (test-only): add `tests/scripts/claude-hooks/enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1`. The existing suite is 446 lines, so a new file is needed. Dot-source the hook and helpers, and use an absolute synthetic path such as `/synthetic-worktrees/session-root/artifacts/orchestration/orchestrator-state.json`. Cases:

- Present checkpoint with `feature-folder`: returns the value. Assert that Test-Path and Get-Content were invoked once with that exact `LiteralPath` and with `-Raw`.
- Present checkpoint without the field: `$null`.
- Field present but empty: `$null`.
- Unparseable JSON: `$null`.
- Get-Content throws: `$null`.
- Absent file: `$null`, and Get-Content is not invoked.

These exercise the read, parse, and extraction body directly without mocking the function. Optional hardening, a production change and not required by #696: add `ValidatePattern('^([A-Za-z]:[\\/]|/)')` so the "absolute" contract is enforced at binding and a relative path can be asserted to fail. It would add the hook and its mirror to the write set.

## 8. Test Design (Q8)

Invocation pattern (all suites): dot-source the hook (the `$MyInvocation.InvocationName -eq '.'` guard returns before the entrypoint, for example `enforce-epic-wave-barrier.ps1:377-379`). Mock the target and read seams (`Resolve-EpicWaveBarrierTarget`, `Get-EpicWaveBarrierCheckpointContent`, and the parallel equivalents). Call `Invoke-*Decision -ToolInputRaw '<envelope json>'` with the nested `tool_input` shape (`enforce-epic-wave-barrier.Tests.ps1:9-13,49-58`). The `-modes.ps1` tests dot-source the modes file alone (`enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1:21`). If modes dot-sources the shared file, those tests still load it.

Matrix, required for each changed resolver (wave, cohort, drift, Claude modes, Codex modes) and for the shared functions:

1. Folder alone.
2. Folder plus `research/<x>.md`.
3. Folder plus `evidence/<kind>/<x>.md`.
4. Nested artifact alone (`research/` and `evidence/<kind>/`).
5. Upstream-dependency citation line naming another run member's folder. Epic: the dependency is excluded and the target is selected. Parallel and drift: two remaining candidates are Ambiguous, unless the canonical issue line selects one.
6. Two distinct non-dependency folders: Ambiguous deny, leading token preserved, candidates named.
7. A token that truncates to fewer than four segments (`docs/features/active/`, `docs/features/active/.`): no candidate, so the existing "must reference" deny (or the D3 issue fallback in modes).
8. Edge cases: trailing `.`/`,`/`;`; backslash separators; absolute-prefixed token; record values with `active/<b>` and `docs/features/active/<b>`; duplicate citations of one folder; a candidate that matches no record.
9. Regression fixture for the #770 occurrence: features 507 (merged), 508 (merged), 621 (`not_started`, `depends_on: [507, 508]`), with a prompt citing 621's folder plus two upstream lines. The wave barrier must evaluate 621 (allow while both are merged; deny when 508 is `pr_open`). The preimplementation gate must resolve 621 (not terminal), so it allows.
10. Wave-barrier dependency lookup with integer `depends_on` entries (union index).

Suite placement: new files, because several existing suites are near the cap (cohort 458, drift 440, Claude mode-resolution 492, Codex mode-resolution 332):

- `tests/scripts/claude-hooks/feature-folder-resolution.Tests.ps1` and `tests/scripts/codex-hooks/feature-folder-resolution.Tests.ps1`. Each copy needs its own coverage because both are in the denominator. Include a Claude/Codex hash-equality assertion.
- `tests/scripts/claude-hooks/enforce-epic-wave-barrier.FolderResolution.Tests.ps1`, `enforce-parallel-cohort-barrier.FolderResolution.Tests.ps1`, `enforce-parallel-drift-gate.FolderResolution.Tests.ps1`.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1` and the Codex counterpart under `tests/scripts/codex-hooks/`.
- Edit `enforce-parallel-drift-gate.Tests.ps1:302-305` (longest-match expectation) and `enforce-feature-folder-order.Tests.ps1` (181 lines). Add #568 cases for each mode, the legacy marker, missing/malformed markers, a timestamped plan path, and a non-plan timestamped near-miss. Mock the new issue-content seam so existing cases stop reading disk.
- Edit `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1:30` (`SharedModuleNames`).
- New `enforce-prd-feature-before-planner.CheckpointFolder.Tests.ps1` (Section 7).

## 9. Toolchain, Batch Budget, and Coverage (Q9)

- Toolchain: format, analyze, test through the PoshQC MCP tools (`mcp__drm-copilot__run_poshqc_format`, `run_poshqc_analyze`, `run_poshqc_test`; `.claude/rules/powershell.md:13-20`). Python parity tests run with `poetry run pytest` for the bundle-contract files in Section 5.
- Operational cautions, from agent memory and not re-verified in this session: the MCP PoshQC test runner reads installed-extension settings, may not pick up new coverage entries, and returns no output body. Plans should not assert counts or percentages from the MCP summary. For coverage evidence, import the self-hosted module (`scripts/powershell/PoshQC/PoshQC.psd1`, which exports `Invoke-PoshQCTest`; `PoshQC.psm1:137-147`) and read `artifacts/pester/powershell-coverage.xml`. Confirm the new files appear in that XML.
- Coverage: line coverage of at least 85% per changed PowerShell file, uniform across tiers. There is no branch threshold for Pester (`.claude/rules/general-unit-test.md`). No production file may be excluded. Both copies of the shared file must reach the threshold independently.
- Batch budget: `enforce-powershell-batch-budget.ps1` counts distinct production `.ps1/.psm1/.psd1` paths per session id (state file `.claude/state/powershell-batch-budget.<session_id>.json`) and denies the fourth (lines 10-15). Test files do not count (25-27). A non-terminal orchestrator checkpoint with `route_id` (or `path_selected`) of `large`, `remediation`, or `preparation` exempts all counting (16-23; `enforce-batch-budget-route.ps1:101,130`). No manual reset command exists. A different session id starts a new set, which is not a sanctioned bypass. With 18 production PowerShell files, C2 must run on the large route.
- Python must not be added to any hook (epic NFR; memory note). The shared resolver is PowerShell only.

## 10. Automation Feasibility

No third-party UI is involved. Every change is to PowerShell hooks, JSON manifests, and Pester/pytest suites, all of which run headless. No human-interaction requirement was found. CI dispatch for an epic-child PR may need a manual `workflow_dispatch`, because `ci.yml` triggers only on PRs into `main` or `development` (agent memory, not re-verified here). That is an operator action on GitHub, not a UI dependency of the change.

## 11. Constraints to Carry into the Spec

- No Python in any hook.
- 500-line cap per production and test file. Watch `-modes.ps1` (480/477), `enforce-parallel-drift-gate.ps1` (444), and the Codex gate main (487, which should stay untouched).
- Every changed Claude hook updates its bundled mirror. The changed Codex `-modes.ps1` and the new Codex shared file update the `codex-and-agents-customizations` mirror. Both `core.json` manifests list the new file.
- Bundle-parity and manifest tests stay green (Section 5).
- Deny reasons keep their existing leading tokens.
- Fail closed on unresolvable or ambiguous targets. Never select by length or position.
- No temporary files in tests (no `TestDrive`, no temp-file APIs). Use mocks of the read seams or built-ins with absolute synthetic paths.
- Line coverage of at least 85% for every changed PowerShell file, including both copies of the shared file.

## Rejected Alternatives (brief)

- Port #569 verbatim (truncate plus checkpoint preference plus earliest occurrence). Rejected. Run checkpoints record both target and upstream, and the earliest-occurrence rule is positional and was already removed from the reference by #672/#673.
- `.claude/lib` module (option a). Rejected. Codex cannot import it, so it produces two implementations.
- Per-hook duplication (option b). Rejected. Five copies, and `-modes.ps1` needs a headroom split anyway.
- Dot-sourcing the planner helpers into `enforce-feature-folder-order.ps1` for the work-mode parser. Rejected. It brings an unguarded module import into a Write/Edit hook.

## Numeric Derivation Evidence

### Claim N1: ten code files contain a longest-match feature-folder selection

- Complete Family: every PowerShell file (`*.ps1`, `*.psm1`) under `.claude/`, `.codex/`, and `extensions/drm-copilot/resources/` that selects a feature folder from prompt text by string length.
- Exhaustive Search Scope: the whole worktree with ripgrep, restricted to code by excluding `docs/`; covers `.claude/hooks`, `.claude/lib`, `.codex/hooks`, and both bundle roots.
- Inclusion Rules: a code line that orders candidate path tokens by length to pick a folder.
- Exclusion Rules: Markdown under `docs/`; `Sort-Object ... -Descending` on non-length keys (for example `LastWriteTime` in `.codex/hooks/validate-feature-review-coverage.ps1:58`); `.Length` comparisons not used for selection.
- Primary Search Strategy or Query Expression: `Sort-Object\s+-Property\s+Length\s+-Descending|Sort-Object\s+Length\s+-Descending|Sort-Object\s+-Descending\s+-Property\s+Length|Sort-Object\s+\{\s*\$_\.Length\s*\}\s+-Descending` over the worktree, keeping non-`docs/` hits.
- Primary Member Set: `.claude/hooks/enforce-epic-wave-barrier.ps1:134`; `.claude/hooks/enforce-parallel-cohort-barrier.ps1:185`; `.claude/hooks/enforce-parallel-drift-gate.ps1:233`; `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:236`; `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:236`; `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-wave-barrier.ps1:134`; `.../claude-customizations/.claude/hooks/enforce-parallel-cohort-barrier.ps1:185`; `.../claude-customizations/.claude/hooks/enforce-parallel-drift-gate.ps1:233`; `.../claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:236`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1:236`.
- Primary Count: 10.
- Cross-check Search Strategy or Query Expression: enumerate every prompt scanner by the shared token regex `docs\[\\\\/\]\+features` over `*.ps1`/`*.psm1` (14 files), then inspect each scanner's selection rule; independently grep `(?i)longest|Sort-Object[^\n|]*Length|OrderByDescending` in `.claude` and `.codex` code.
- Cross-check Member Set: the 14 scanners are the 10 primary files plus `.claude/hooks/enforce-prd-feature-before-planner-helpers.ps1:187` and its mirror (ordered dedupe with checkpoint selection, no length sort), and `.claude/lib/worktree-resolution/WorktreeTargetResolution.psm1:53` and its mirror (first match, basename-bounded, no length sort). That gives 14 - 4 = 10 length-selecting files. The "longest" grep returned exactly the four `.claude` hooks and the one `.codex` modes file, which are the non-mirror members; the mirrors appear in the bundle roots.
- Cross-check Count: 10.
- Member-set Comparison: the normalized sets (path without line number) are identical. Ten in the primary and ten in the cross-check, with no member present in only one set.

### Claim N2: 41 active feature folders; all 41 allowed by the #568 rule; 38 denied under the regex-only fix

- Complete Family: feature folders directly under `docs/features/active/` in this worktree.
- Exhaustive Search Scope: Glob and ripgrep over `docs/features/active/*/`. Limit: a folder containing neither `issue.md` nor `plan*.md` would not be enumerated, because no directory-listing tool was available.
- Inclusion Rules: a folder containing `issue.md` or a `plan*.md`.
- Exclusion Rules: `docs/features/archive/`, `completed/`, `potential/`, `epics/`.
- Primary Search Strategy or Query Expression: Glob `docs/features/active/*/{issue,spec,user-story}.md`, then the distinct folders holding `issue.md`.
- Primary Member Set (by issue number): 338, 405, 406, 464, 484, 507, 508, 509, 510, 512, 523, 527, 532, 543, 565, 609, 621, 623, 645, 647, 658, 659, 690, 723, 734, 739, 740, 741, 743, 744, 756, 762, 763, 764, 765, 769, 773, 776, 802, 823, 830.
- Primary Count: 41.
- Cross-check Search Strategy or Query Expression: (i) Glob `docs/features/active/*/plan*.md`, taking the distinct folders; (ii) ripgrep `Work Mode:` over `**/issue.md` under `docs/features/active`, excluding the prose hit at this folder's `issue.md:91`.
- Cross-check Member Set: (i) the same 41 folders, all with timestamped plans only and no literal `plan.md`. (ii) The same 41 folders, each with one marker: full-feature {621, 645}; minor-audit {338, 406, 658, 659, 723, 739, 740, 741, 756, 764, 765, 776, 802, 830}; full-bug {the remaining 25}. The `spec.md` set (27) equals full-bug plus full-feature. The `user-story.md` set is {621, 645, 690}.
- Cross-check Count: 41 (plans), 41 (markers).
- Member-set Comparison: all three sets are identical. Under the #568 rule every folder's required set is present, so 41 are allowed. Under the regex-only fix (all three files required), only {621, 645, 690} pass, so 38 are denied.
