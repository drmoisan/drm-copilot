# Research: Parallel Run Closing records PR blocked by the routing-receipt gate (Issue #1182)

- Issue: #1182 (full-bug)
- Branch: `bug/parallel-close-records-pr-routing-receipt`
- Timestamp: 2026-11-14T10-43 (UTC; read from the timeapi.io UTC endpoint because the researcher has no shell tool)
- Scope: read-only analysis of the item worktree. Facts that need `git` or `gh` are marked "to confirm by orchestrator".

## 1. Summary of Findings

1. The model-routing gate `.claude/hooks/enforce-model-routing-receipt.ps1` (`Invoke-ModelRoutingReceiptDecision`) has three non-item legs (epic scope, cleanup, docs-estate) and no parallel leg. A `branch: parallel/<slug>-plan` prompt resolves through `Resolve-WorktreeItemTarget` to the coordinator root, whose per-feature checkpoint is absent by #673 hygiene, so the decision reaches the generic `MODEL_ROUTING_RECEIPT_BLOCKED` deny. This reproduces the reported denial (verified by code reading).
2. A second gap exists on the same path and is not named in the issue: the pr-author agent's Write of `artifacts/pr_body_<N>.receipt.json` at the coordinator root is denied by the Claude preimplementation gate (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`). The path ends in `.json`, so `Test-ImplementationPath` requires a ready per-feature checkpoint; none exists; the cleanup leg needs the consolidation worktree, and the docs-estate leg (`enforce-orchestration-preimplementation-gate-docs.ps1`) declines because `parallel-orchestrator-state.json` is listed in `$script:DocsEstateCheckpointPaths`. Verified by code reading, not by execution; the plan needs a fail-before Pester case.
3. The pr-author command gate (`enforce-pr-author-skill.ps1`) already admits `gh pr create --head parallel/<slug>-plan --base main --body-file artifacts/pr_body_<N>.md` from the coordinator root through the docs-only exemption of issue #901 (`Get-PrAuthorDocsOnlyExemption`), because the resolved per-feature checkpoint is absent and the branch diff is `docs/` only. No parallel leg is needed there.
4. The merge gate (`enforce-epic-merge-gate.ps1`) already admits `gh pr merge <PR> --merge` for the records PR through the docs-only branch of issue #927 (`Get-DocsOnlyMergeExemption`), because no item, epic, or parallel checkpoint records the records PR number. Its parallel branch (`Test-ParallelCheckpointAllowsMerge`) does not apply and must not be made to apply. `review_mode` is not relevant.
5. Codex has no parallel-orchestrator agent, no model-routing receipt gate twin, and no pr-author command gate twin, so no Codex change is required. The Codex preimplementation gate is at its 500-line cap and must not be edited.

## 2. Current State Analysis

### 2.1 Model-routing gate checkpoint resolution and its three precedents (Q1)

`Invoke-ModelRoutingReceiptDecision` in `.claude/hooks/enforce-model-routing-receipt.ps1` runs in this order for a gated `subagent_type` (`Get-ModelRoutingGatedAgent`: atomic-planner, atomic-executor, feature-review, task-researcher, prd-feature, pr-author):

1. Epic scope: `Resolve-EpicScopeCheckpoint -Text $prompt` (module `.claude/lib/worktree-resolution/EpicScopeResolution.psm1`).
2. Item resolution: `Get-ModelRoutingTargetCheckpointResolution` → `Resolve-ModelRoutingWorktreeTarget` → `Resolve-WorktreeItemTarget` (`.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`). `SessionRoot`/`OtherWorktree` yields the per-feature checkpoint path via `Get-WorktreeItemCheckpointPath`; `NoTarget`/`Ambiguous` denies with the resolver reason code.
3. Per-feature receipt: `Get-ModelRoutingCheckpoint` (seam) then `Test-ModelRoutingReceiptPresent` (presence of a `model_routing_receipts[]` entry whose `agent` equals the subagent type); for pr-author, `Get-ModelRoutingAuthorAssertedReason` (issue #989) follows.
4. Cleanup leg (only pr-author, only when the checkpoint is `$null`): `Test-ModelRoutingCleanupDelegation`.
5. Docs-estate leg (only pr-author, only when the checkpoint is `$null`): `Get-ModelRoutingDocsEstateDecision` in `enforce-model-routing-receipt-docs.ps1`; its `DenySuffix` is appended to the final deny.
6. Final deny: `MODEL_ROUTING_RECEIPT_BLOCKED: cannot delegate to '<agent>' before a model_routing_receipts entry ...` plus the docs suffix.

| Precedent | Scope identification | Checkpoint read | Allow condition | Tests | Codex twin | Bundle mirror |
|---|---|---|---|---|---|---|
| Epic scope (#663), `Resolve-EpicScopeCheckpoint` | First branch signal of the prompt (`Find-WorktreeResolutionBranchSignal`: `--head`, `--branch`, or `branch:`) equal to `integration_branch` of an epic checkpoint; located by `Resolve-WorktreeEpicTarget` in `WorktreeRunResolution.psm1` | `artifacts/orchestration/epic-orchestrator-state.json` beneath the resolved live worktree (`route_id` `epic`, non-empty `integration_branch`) | `Test-ModelRoutingReceiptPresent` on the epic checkpoint; runs before item resolution; author-asserted rule not applied | `tests/scripts/claude-hooks/enforce-model-routing-receipt.EpicScope.Tests.ps1` | None for this gate (the epic-scope module is Claude-side; Codex preimplementation gate has its own epic-scope sibling) | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/worktree-resolution/EpicScopeResolution.psm1` (module header states byte-identical mirror) |
| Cleanup leg (#1026), `Test-ModelRoutingCleanupDelegation` with `hook-cleanup-context.ps1` | Exactly one `branch: documentationandmemories` label and no `--head`/`--branch` token (`Test-CleanupConsolidationBranchLabel`) | No checkpoint; session-root manifest `artifacts/orchestration/cleanup-worktrees-manifest.json` read via `Get-CleanupWorktreeManifestContent` (`.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`) | `Test-CleanupManifestText` with the `Get-CleanupWorktreeManifestUtcNow` clock seam; evaluated only when the per-feature checkpoint is `$null` | `tests/scripts/claude-hooks/enforce-model-routing-receipt.Cleanup.Tests.ps1`; end to end `tests/scripts/claude-hooks/cleanup-merged-worktrees-workflow.EndToEnd.Tests.ps1` | `hook-cleanup-context.ps1` has a `.codex/hooks/` copy (used by the Codex preimplementation gate); no Codex model-routing twin | `.claude/hooks/enforce-model-routing-receipt.ps1` bundled; `hook-cleanup-context.ps1` bundled |
| Docs-estate leg (#1169), `Get-ModelRoutingDocsEstateDecision` | Exactly one `branch:` line and one `base:` line (`Get-DocsEstateDelegationLabel`), and a docs profile beneath the resolved root | No checkpoint; docs profile, `refs/remotes/origin/<base>...HEAD` diff, and validation receipt beneath the resolved root | Diff non-empty and entirely in the docs path set; `docs-complete` pass receipt accepted by `Get-DocsReceiptRevisionDecision`; returns `Allowed`/`DenySuffix` | `tests/scripts/claude-hooks/enforce-model-routing-receipt.DocsEstate.Tests.ps1`; `tests/scripts/claude-hooks/docs-estate-workflow.EndToEnd.Tests.ps1` | None (Claude only, per the file header) | `pack-manifests/core.json` lists `.claude/hooks/enforce-model-routing-receipt-docs.ps1` |

Other model-routing suites: `enforce-model-routing-receipt.Tests.ps1`, `.WorktreeResolution.Tests.ps1`, `.AuthorAsserted.Tests.ps1`, `.EpicModeStrict.Tests.ps1`, all under `tests/scripts/claude-hooks/`. No suite under `tests/scripts/codex-hooks/` covers this gate.

Trace for the reported prompt (`branch: parallel/harness-learnings-2026-11-09-plan`, no issue line): epic scope declines (no epic checkpoint records the branch); `Resolve-WorktreeItemTargetByBranch` resolves the single live worktree that has the branch checked out (the coordinator root; the current main checkout is on that branch per the session git status, to confirm by orchestrator); the per-feature checkpoint there is absent (moved to `artifacts/orchestration/handoff/` per `completed_steps`), so `$checkpoint` is `$null`; the cleanup leg declines (label); the docs leg declines with an empty suffix (no docs profile); the generic deny is returned.

### 2.2 Parallel checkpoint shape (Q2)

Authority: `.claude/rules/parallel-orchestration.md` `## Invariants (parallel orchestrator checkpoint)`, enforced by `scripts/dev_tools/validate_parallel_orchestrator_state.py` with the TypeScript port `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts`.

- Required keys (invariant 1): `objective`, `completed_steps`, `next_step`, `last_updated`, `route_id`, `parallel_slug`, `parallel_manifest_path`, `parallel_status_doc_path`, `mode`, `max_concurrency`, `current_cohort`, `recolor_generation`, `cohorts`, `items`, `conflict_edges`, `mutations`, `drift_events`.
- Run slug field: `parallel_slug`. Route field: `route_id` exactly `parallel`.
- Plan/coordinator branch field: none. The branch `parallel/<slug>-plan` is a naming convention stated in `.claude/skills/parallel-orchestrate/SKILL.md` `## Parallel Manifest Consumption` ("the planner-owned branch `parallel/<slug>-plan`"); it is derived from `parallel_slug`, not stored. Invariant 11 prohibits `integration_branch` at any level, so a branch must not be recorded under that name.
- `model_routing_receipts` / `complexity_assessments`: not declared by the rule; not read by the Python validator (searched `scripts/dev_tools/*parallel*state*.py`; only `_parallel_planner_state_routing.py` reads the planner's per-item `model_routing_receipt`). Unknown top-level keys are not rejected: the only prohibited keys are `depends_on`, `integration_branch`, and `epic_merge_pr` (invariants 10 and 11; `test_validate_parallel_orchestrator_state.py` asserts only those). The skill section `## Parallel-Level Checkpoint` nevertheless states "add no field to it that `.claude/rules/parallel-orchestration.md` does not declare", so a new key needs a rule amendment.
- Closing fields: no run-status field. Completion is per-item (invariants 20 and 21: under `require_complete`, every non-withdrawn item has `merge_status` `merged` or `worktree_removed`; open mode also needs a `mutations[]` entry with `op` `close`).
- Receipt arrays tolerated as lists: `delegation_receipts`, `skill_receipts`, `mcp_call_receipts` (invariant 19).

Real checkpoint of run harness-learnings-2026-11-09 (session root `artifacts/orchestration/parallel-orchestrator-state.json`, read only):

- `route_id`: `parallel`; `parallel_slug`: `harness-learnings-2026-11-09`; `mode`: `closed`; `max_concurrency`: 8; `recolor_generation`: 6; `current_cohort`: 0.
- Top-level keys present: `objective`, `route_id`, `parallel_slug`, `parallel_manifest_path`, `parallel_status_doc_path`, `mode`, `max_concurrency`, `completed_steps`, `next_step`, `last_updated`, `current_cohort`, `recolor_generation`, `cohorts`, `items`, `conflict_edges`, `tolerated_overlaps`, `precedence`, `mutations`, `drift_events`, `delegation_receipts`, `skill_receipts`, `mcp_call_receipts`. No `model_routing_receipts`, no `complexity_assessments`, no `owner_directives`, no `review_mode`.
- Items: 1159 (`state` merged, `merge_status` worktree_removed, `pr_number` 1177) and 1160 (merged, worktree_removed, 1174); 1156, 1157, 1158, 1161, 1162, 1163 withdrawn with `merge_status` not_started. Every non-withdrawn item is terminal.
- `delegation_receipts`: four `orchestrator` entries; no pr-author entry.
- `completed_steps` entry 2026-11-14T09-49 records the LV3 deferral with the exact denial and states that `git diff --name-only origin/main...HEAD` lists only `docs/features/parallel/harness-learnings-2026-11-09/` (5 files) at commit c295f89d1 (to confirm by orchestrator).

Run Closing text: `.claude/skills/parallel-orchestrate/SKILL.md` `### Run Closing` substep 3 says "delegate the pull request to `Agent(pr-author)` with a `branch:` label in place of an issue number" and names LV3 as the deferral when that delegation "failed its model-routing receipt check". It does not say where or how a pr-author receipt is recorded. By contrast `.claude/skills/epic-orchestrate/SKILL.md` `## Epic-Level Checkpoint` ("Integration-PR checkpoint shape (issue #663)") states that `epic-orchestrator` records the pr-author routing receipt in the epic checkpoint's `model_routing_receipts[]` before the delegation. The same gap is in `.claude/agents/parallel-orchestrator.md` `### Run Closing` substep 3.

### 2.3 pr-author command gate (Q4)

`Get-PrAuthorBypassReason` in `.claude/hooks/enforce-pr-author-skill-helpers.ps1`: for a `--body-file` command it resolves the artifact root (`Resolve-PrAuthorArtifactRoot`), checks `PR_CONTEXT_MISSING`, then runs `Invoke-OrchestratorStatePreflight` (the `--require-pr-creation-ready` preflight of `OrchestratorState.psm1`) on the resolved per-feature checkpoint. On failure it calls `Get-PrAuthorPreflightExemption` (`enforce-pr-author-skill.cleanup.ps1`), which calls `Get-PrAuthorDocsOnlyExemption` (`enforce-pr-author-skill.docs-only.ps1`, E1-E7). For the records PR: E1 `gh pr create`; E2 no file at the resolved per-feature checkpoint path (only `orchestrator-state.json` is probed, so the parallel checkpoint does not block); E3 exactly one `--base main`; E4 `refs/remotes/origin/main` resolves; E5-E7 the `<base>...HEAD` diff is non-empty and all under `docs/`. Receipt checks 1-6 of `Test-PrAuthorReceiptVerification` then apply. Conclusion: the gate allows the records PR today, provided the body and receipt exist beneath the coordinator root and the context summary is refreshed there (`mcp__drm-copilot__collect_pr_context` is in the parallel-orchestrator `tools:` list). No parallel leg is needed.

Other Agent-matcher gates in `.claude/hooks/pretooluse-dispatch.json` for `Agent(pr-author)`:

- Preimplementation gate: `Test-ImplementationDelegation` returns false for pr-author (allow list `$script:OrchestrationImplementationAgentAllowList` in `enforce-orchestration-preimplementation-gate-modes.ps1` names only the four engineers and atomic-executor). The delegation is allowed. The pr-author's receipt Write is not (finding 2).
- Owner-directive pass-down (`enforce-owner-directive-pass-down.ps1`, `Get-OwnerDirectivePassDownRoleSet`): pr-author is in neither the acknowledgement nor the relay set; not gated.
- Epic invocation origin (`enforce-epic-invocation-origin.ps1`, `$script:GatedSubagentTypes`): gates only epic/parallel planner and orchestrator types; not gated.
- `enforce-epic-wave-barrier.ps1` and `enforce-parallel-cohort-barrier.ps1` activate only for `orchestrator`; `enforce-parallel-drift-gate.ps1` only for `feature-review`; `enforce-prd-feature-before-planner.ps1` only for the planner path.
- SubagentStop `validate-pr-author-output.ps1` requires only a PR URL or number in the final message.

Precedent for a preimplementation receipt-Write leg: the cleanup leg (`enforce-orchestration-preimplementation-gate-cleanup.ps1`, receipt pattern `/artifacts/pr_body_[0-9]+\.receipt\.json$`), the docs-estate leg (`enforce-orchestration-preimplementation-gate-docs.ps1`, condition D1+D2 for the receipt Write), and the epic fan-in allowance (`Get-EpicFanInAllowance` in `hook-epic-fan-in.ps1`, Write of `artifacts/pr_body_<N>.receipt.json`).

### 2.4 Merge gate (Q5)

`Invoke-EpicMergeGateDecision` in `.claude/hooks/enforce-epic-merge-gate.ps1`. The parallel branch `Test-ParallelCheckpointAllowsMerge` admits only an explicit PR number that equals an `items[].pr_number` with `merge_status` `ci_green`; the records PR is not an item, so it declines. Parallel targets are found by `Resolve-WorktreeRunTargetByRecord -Kind parallel -RecordField pr_number`, which searches `items[].pr_number` only (`Test-WorktreeRunCheckpointRecord` in `WorktreeRunResolution.psm1`). With item, epic, and parallel targets all `NoTarget`, `Test-EpicMergeGateNoRecordingTarget` holds and `Get-DocsOnlyMergeExemption` (`hook-docs-only-diff.ps1`, M1-M9) decides: one structural `gh pr merge` of one number, `gh pr view` base and head, `refs/remotes/origin/<base>` resolves, the head commit is present locally, and the diff is all `docs/`. The Run Closing deferral LV2 already names the `origin/main`-absent case. The review guard (`enforce-epic-merge-gate-review.ps1`) is inert without `review_mode: "concurrent"` in a checkpoint it reads; the coordinator root holds no per-feature checkpoint and the parallel checkpoint has no `review_mode`, so `review_mode` is not relevant. Constraint for the fix: never record the records PR number in `items[]`, or the parallel target resolves, the docs-only branch is skipped, and the merge is denied.

### 2.5 Codex surfaces (Q6)

- `.codex/hooks/` has no `enforce-model-routing-receipt.ps1` (Codex uses `enforce-codex-model-routing.ps1`, an attestation mechanism), no `enforce-pr-author-skill*.ps1`, and no parallel-orchestrator agent under `.codex/agents/` (searched for `parallel`; only planner/orchestrator variants and epic agents mention it). Twins that exist: `enforce-orchestration-preimplementation-gate.ps1` (+ `-docs`, `-cleanup`, `-bookkeeping`, `-epic-scope` siblings), `enforce-epic-merge-gate.ps1` (+ `-review`, `-child-ci`, `-command`, `-regeneration`).
- `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` is at its cap: the Read view ends at line 500 (`}` closing the outer `try/catch`). The cap is pinned by `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1`, `It 'parse-checks each root and bundled hook and keeps every file within 500 lines'` (`(Get-Content -LiteralPath $path).Count | Should -BeLessOrEqual 500`, applied to the root and the bundle copy under `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/`); `enforce-orchestration-preimplementation-gate-trigger-scoping.Tests.ps1` also records the headroom. The exact count is to confirm by orchestrator with `@(Get-Content -LiteralPath <path>).Count`.
- No Codex change is needed, because no Codex runtime runs a parallel Run Closing. Do not edit the byte-identical `enforce-orchestration-preimplementation-gate-docs.ps1` or `hook-docs-estate-context.ps1` (four copies each, pinned by `tests/scripts/claude-hooks/hook-docs-estate-context.Parity.Tests.ps1`), since that would change the Codex copies.

### 2.6 Push-down mirrors and pack manifests (Q7)

- Claude bundle root: `extensions/drm-copilot/resources/claude-customizations/`. `pack-manifests/core.json` lists `.claude/hooks/enforce-model-routing-receipt.ps1`, `.claude/hooks/enforce-model-routing-receipt-docs.ps1`, `.claude/hooks/enforce-orchestration-preimplementation-gate-docs.ps1`, `.claude/lib/worktree-resolution/WorktreeRunResolution.psm1`, `.claude/agents/parallel-orchestrator.md`, `.claude/skills/parallel-orchestrate/SKILL.md`, and `.claude/rules/parallel-orchestration.md`.
- Every new or changed `.claude/` file needs an equal-text bundle copy and a `core.json` entry. Contract tests (`tests/scripts/dev_tools/`): `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py` (every `$PSScriptRoot` dependency of a manifested hook in core plus the owning pack). Brief copies under `.agents/` and `.github/` and their bundles: `test_push_down_codex_and_agents_resource_contracts.py`, `test_execution_environment_brief_contracts.py`. Runtime suites: `tests/scripts/claude-runtime/hook-dependency-guard-completeness.Tests.ps1` (guarded dot-source pattern), `hook-imported-modules-no-stdout.Tests.ps1`, `enforcement-hooks-no-python-invocation.Tests.ps1`, `tests/scripts/claude-runtime/parallel-orchestrate-run-closing.Tests.ps1` (repository and bundle copies of the skill and agent).
- No `.claude/settings.json` or `pretooluse-dispatch.json` change is needed when the new logic is a dot-sourced sibling of an already registered hook.

### 2.7 Documentation surfaces (Q8)

| Surface | Change | Required? |
|---|---|---|
| `.claude/skills/parallel-orchestrate/SKILL.md` `### Run Closing` substep 3 and substep 5 (LV3); `## Parallel-Level Checkpoint` | State that the coordinator records the pr-author routing receipt in the parallel checkpoint's `model_routing_receipts[]` before the delegation, the prompt shape (one `branch: parallel/<slug>-plan` line, no canonical issue line), `<N>` choice, `collect_pr_context` at the coordinator root, and `--head`/`--base main`. Declare the key in the field list. Reword LV3 as a residual deferral. | Yes: the skill forbids undeclared fields, and the procedure is otherwise not executable. |
| `.claude/agents/parallel-orchestrator.md` `### Run Closing` substep 3 and 5 | Same sentence, shortened. | Yes (procedure text the agent follows). |
| `.claude/rules/parallel-orchestration.md` | Declare `model_routing_receipts` (and, if recorded, `complexity_assessments`) as an optional, tolerated top-level key of the parallel-orchestrator checkpoint, read only by the model-routing gate; no validator change. | Yes, for the skill's no-undeclared-field rule. |
| Execution-environment brief, six copies (`.claude/`, `.agents/`, `.github/` `skills/execution-environment/SKILL.md` and the three bundle copies) | Add a "Parallel records legs (#1182)" bullet beside "Cleanup legs (#1026)" and "Docs-estate legs (#1169)" in `## Hook Execution Context`. | Strongly recommended: both precedents added a bullet; the maintenance rule in `## Purpose and Maintenance` applies to facts the brief states about gate legs. |
| `.claude/rules/orchestrator-state.md` | None. Its model-routing sections govern the per-feature checkpoint; the gate remains presence-only. | No. |
| `docs/engineering/claude-code-architecture.md` | None unless a tool name changes (`claude-architecture-doc.Tests.ps1`). | No. |

## 3. Candidate Approaches

### A. Parallel records leg in the model-routing gate, keyed by the plan-branch label, with the receipt in the parallel checkpoint (recommended)

A new Claude-only sibling dot-sourced by `enforce-model-routing-receipt.ps1`, evaluated only for `pr-author` when the per-feature checkpoint is `$null` (beside the cleanup and docs legs). The label must be `parallel/<slug>-plan`; the parallel checkpoint beneath the resolved root must have `route_id` `parallel`, `parallel_slug` equal to `<slug>`, and a pr-author `model_routing_receipts[]` entry. A matching Claude-only sibling leg in the preimplementation gate admits the receipt Write.

- Advantages: mirrors the #663 receipt location and the #1026/#1169 leg shape; keeps behavior unchanged for every other prompt; reuses `Test-ModelRoutingReceiptPresent` and the exported seams `Get-WorktreeRunCheckpointPath` and `Get-WorktreeRunCheckpointText`; no Codex or registry change.
- Limitations: one new tolerated checkpoint key (rule amendment); policy-level control, same-session forgery possible (as for the epic receipt).

### B. Branch-label-only leg without a receipt (cleanup-leg style)

Admit the delegation when the label is the plan branch and the run is closing, with no receipt. Rejected: drops the model-selection record that the gate exists to enforce, and the issue's proposed fix and the epic precedent both keep a receipt.

### C. Write a per-feature `orchestrator-state.json` at the coordinator root for the records PR

Rejected: violates the #673 checkpoint hygiene the skill pins ("never holds a per-feature checkpoint at its own root", pinned by `checkpoint-hygiene-skill-contract.Tests.ps1`), and would also make the pr-author docs-only exemption decline (E2) and run the PR-creation-readiness preflight against a synthetic checkpoint.

## 4. Recommended Design

### 4.1 Model-routing gate: parallel records leg

New file `.claude/hooks/enforce-model-routing-receipt-parallel.ps1` (Claude only), dot-sourced in `enforce-model-routing-receipt.ps1` with the guarded pattern `try { . (Join-Path $PSScriptRoot '...') } catch { Add-HookDependencyFailure -Name '...' -ErrorRecord $_ }`, plus a guarded `Import-Module` of `../lib/worktree-resolution/WorktreeRunResolution.psm1` (the hook imports `EpicScopeResolution.psm1`, whose nested import of `WorktreeRunResolution.psm1` is not visible to the hook scope). Function `Get-ModelRoutingParallelRecordsDecision -PromptText -WorktreeRoot` returns `[pscustomobject]@{ Allowed; DenySuffix }` and never throws.

Call site: in `Invoke-ModelRoutingReceiptDecision`, inside the existing `$subagent -eq 'pr-author' -and $null -eq $checkpoint` region, after the cleanup leg and before the docs leg. On `Allowed` return allow; otherwise keep its suffix and let the docs leg run; final deny text = base + parallel suffix + docs suffix.

Conditions, in order (first failure declines):

1. P1 Label: `Find-WorktreeResolutionBranchSignal -Text $PromptText` returns a value matching `^parallel/(?<slug>[A-Za-z0-9][A-Za-z0-9._-]*)-plan$` (ordinal). Not matching: decline with an empty suffix, so every non-parallel deny text is unchanged.
2. P2 Root: `$resolution.WorktreeRoot` is non-blank. The item resolver has already placed the root at the single live worktree that has the plan branch checked out; `NoTarget`/`Ambiguous` never reach the leg (they deny earlier with the resolver code, unchanged).
3. P3 Checkpoint: text from `Get-WorktreeRunCheckpointText -Path (Get-WorktreeRunCheckpointPath -Kind parallel -WorktreeRoot $root)` parses to an object (`-NoEnumerate`), `route_id` ceq `parallel`, `parallel_slug` ceq `<slug>`. Absent or unparseable: suffix `PARALLEL_RECORDS_CHECKPOINT_UNREADABLE`. Slug or route mismatch: `PARALLEL_RECORDS_SLUG_MISMATCH`.
4. P4 Closing state (recommended narrowing): `items[]` is non-empty and every item whose `state` is not `withdrawn` has `merge_status` `merged` or `worktree_removed` (the same predicate as invariant 20). Failure: `PARALLEL_RECORDS_RUN_NOT_CLOSING`.
5. P5 Receipt: `Test-ModelRoutingReceiptPresent -Checkpoint $parallel -Subagent 'pr-author'`. Failure: `PARALLEL_RECORDS_RECEIPT_MISSING`, with the remedy text "record a pr-author entry in model_routing_receipts of <checkpoint path> before delegating".

Suffix form, following #1169: `' Parallel records leg not applied: <SUB_CODE>: <detail>'`, appended only once P1 matched.

Required outcomes:

| Case | Outcome |
|---|---|
| Label equals `parallel/<slug>-plan`, checkpoint matches, closing, receipt present | allow |
| Label is `parallel/<other>-plan` (slug mismatch) | deny, base text + `PARALLEL_RECORDS_SLUG_MISMATCH` |
| Receipt missing | deny, base text + `PARALLEL_RECORDS_RECEIPT_MISSING` |
| Parallel checkpoint missing or unparseable | deny, base text + `PARALLEL_RECORDS_CHECKPOINT_UNREADABLE` |
| Plan branch checked out nowhere, or in two worktrees | deny with the existing resolver code (unchanged) |
| A per-feature `orchestrator-state.json` exists beneath the resolved root | unchanged: the per-feature receipt path decides; the leg is never reached |
| Epic integration-branch label | unchanged: epic scope decides first |
| Non-pr-author gated agent with the plan label | unchanged deny, no suffix |
| Any non-parallel label | unchanged deny text |

The author-asserted autoclose rule does not apply (no per-feature checkpoint, no issue). The records-PR prompt must carry no canonical issue line: with a branch and an issue, `Resolve-WorktreeItemTargetByBranch` checks the issue against other worktrees and can return `Ambiguous`.

Size: the hook is about 406 lines; the call site adds about 8 lines, the imports 2. The sibling stays well under 500 lines. Do not write the literal `orchestrator-state.json` in any string in `enforce-model-routing-receipt.ps1` (including `parallel-orchestrator-state.json`, which contains it): `tests/scripts/claude-runtime/enforcement-hooks-checkpoint-path-explicit.Tests.ps1`, `It 'the in-scope hook files carry the checkpoint path literal in no string expression'`, scans that file with `.Contains('orchestrator-state.json')`. Composing the path through `Get-WorktreeRunCheckpointPath -Kind parallel` avoids it.

### 4.2 Preimplementation gate: parallel records receipt-Write leg (Claude only)

New file `.claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1`, dot-sourced (guarded) by `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` only, and called in the single-feature deny tail after the docs-estate leg, its `DenySuffix` appended last. It admits only a `Write` whose path is `artifacts/pr_body_<digits>.receipt.json` beneath a root R where: R is the enclosing registered worktree of the absolute path (session root for a relative path; same resolution as the docs leg's D1, through `Get-HookTargetWorktreeEnclosingRoot`); no `orchestrator-state.json` exists beneath R; R's HEAD branch matches `parallel/<slug>-plan` (read through an existing seam such as `Get-EpicScopeWorktreeHeadBranch`); and R's parallel checkpoint has `route_id` `parallel`, `parallel_slug` `<slug>`, the closing predicate, and a pr-author receipt (same predicates as 4.1, shared in a pure helper to avoid two implementations). Edit, commands, and any other path decline with the unchanged text. The Claude gate is 487 lines; the change adds about 3 lines.

The pure predicates (label/branch → slug, checkpoint match, closing, receipt) belong in one shared file that both siblings dot-source, for example `.claude/hooks/hook-parallel-records-context.ps1`, following the `hook-cleanup-context.ps1` and `hook-docs-estate-context.ps1` pattern.

### 4.3 Skill, agent, and rule text

Run Closing substep 3 (skill and agent): before the delegation, refresh the PR context with `mcp__drm-copilot__collect_pr_context` (base `main`, workspace root the coordinator root), record a pr-author entry in `model_routing_receipts[]` of the parallel checkpoint (shape `{ agent, phase, complexity_band, fable_policy, table_model, clamped_from, model }`, model resolved from `config/orchestration-routing.json` under the run's `fable_policy`; pr-author is outside `preferred_overlay.agents`), delegate non-isolated with exactly one `branch: parallel/<slug>-plan` line and no canonical issue line, pass `model` equal to the receipt's model, and have pr-author use `gh pr create --head parallel/<slug>-plan --base main`. For `<N>`, follow the cleanup precedent in `.claude/skills/cleanup-merged-worktrees/SKILL.md` (an arbitrary run-scoped identifier chosen by pr-author when the run has no issue). Keep every backticked `git add`/`git commit` span under `docs/features/` (`parallel-orchestrate-run-closing.Tests.ps1` RC4/RA checks). LV3 becomes a residual deferral for a delegation still denied.

## 5. Behavior Semantics and Edge Cases

- Ordering: epic scope → item resolution (unchanged deny for NoTarget/Ambiguous) → per-feature receipt → cleanup leg → parallel records leg → docs leg → deny.
- A stale parallel checkpoint copy in another worktree does not matter: the leg reads only beneath the worktree that has the plan branch checked out.
- `parallel_slug` comparison is ordinal; a trailing `.` or `/` on the label is already trimmed by `Find-WorktreeResolutionBranchSignal`.
- The receipt is presence-only, as for every other path of this gate; correctness of the recorded model remains with the Python validator (which does not read the parallel checkpoint's receipts; recorded as a known limitation).
- Merge path: unchanged; relies on the #927 docs-only branch; do not add the records PR number to `items[]`.

## 6. Requirements Mapping (file changes)

| File | Change |
|---|---|
| `.claude/hooks/hook-parallel-records-context.ps1` (new) | Pure predicates: slug from branch, checkpoint match, closing, receipt presence |
| `.claude/hooks/enforce-model-routing-receipt-parallel.ps1` (new) | `Get-ModelRoutingParallelRecordsDecision` |
| `.claude/hooks/enforce-model-routing-receipt.ps1` | Guarded import of `WorktreeRunResolution.psm1`, guarded dot-source, call site, `.DESCRIPTION` sentence |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-parallel-records.ps1` (new) | Receipt-Write leg |
| `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` | Guarded dot-source and deny-tail call |
| `.claude/skills/parallel-orchestrate/SKILL.md`, `.claude/agents/parallel-orchestrator.md`, `.claude/rules/parallel-orchestration.md` | Text in 2.7 |
| Six execution-environment brief copies | One bullet |
| Bundle copies under `extensions/drm-copilot/resources/claude-customizations/` and `pack-manifests/core.json` | Mirror every new and changed `.claude/` file |

Production PowerShell files: five under `.claude/hooks/` plus their bundle copies, which count against the batch budget. This exceeds the three-file direct-mode cap (`enforce-powershell-batch-budget.ps1`), so the item must run on the orchestrated large path.

## 7. Testing Implications

- New suites under `tests/scripts/claude-hooks/`: `enforce-model-routing-receipt.ParallelRecords.Tests.ps1` (allow; slug mismatch; non-plan label; missing receipt; missing and unparseable checkpoint; run not closing; per-feature checkpoint present keeps today's decision; epic label unaffected; non-pr-author agent unaffected; deny text byte-unchanged for non-parallel labels), `enforce-orchestration-preimplementation-gate.ParallelRecords.Tests.ps1` (receipt Write allowed; Edit denied; other paths denied; per-feature checkpoint present; wrong HEAD branch), a test file for the shared context helper, and an end-to-end composition suite modeled on `docs-estate-workflow.EndToEnd.Tests.ps1` covering Agent(pr-author), receipt Write, `gh pr create`, and `gh pr merge` for one records PR.
- Seams: mock `Resolve-ModelRoutingWorktreeTarget`, `Get-ModelRoutingCheckpoint`, and `Get-WorktreeRunCheckpointText` (and the HEAD-branch seam). A direct call from hook scope to an exported module function is mocked without `-ModuleName`; a call from inside the module needs `-ModuleName WorktreeRunResolution`. Register the existing epic-state baseline mocks (`EpicStateIsolation.Baseline.Helpers.ps1`) so no suite reads the real session-root parallel checkpoint.
- Fail-before: both new suites' allow rows fail on the current tree (the model-routing allow row returns the generic deny; the receipt-Write allow row returns `PREIMPLEMENTATION_GATE_BLOCKED`).
- Gate run: one `Invoke-PoshQCParallelTest`; per-file line coverage of the new files at or above 85% from `artifacts/pester/powershell-coverage.xml`; Python contract tests through one `pytest -n auto` run.

## Numeric Derivation Evidence

No numeric count is proposed for a `spec.md` acceptance criterion. The one count this research relies on is recorded below.

- Complete Family: copies of the execution-environment brief that a brief-update task must edit.
- Exhaustive Search Scope: the item worktree, every `SKILL.md`.
- Inclusion Rules: a file whose first heading is `# Execution-Environment Brief`.
- Exclusion Rules: none.
- Primary Search Strategy or Query Expression: the enumeration in `## Purpose and Maintenance` of `.claude/skills/execution-environment/SKILL.md` ("`.claude/skills/execution-environment/SKILL.md`, `.agents/skills/execution-environment/SKILL.md`, `.github/skills/execution-environment/SKILL.md`, and their bundled copies under `extensions/drm-copilot/resources/`").
- Primary Member Set: `.claude/skills/execution-environment/SKILL.md`; `.agents/skills/execution-environment/SKILL.md`; `.github/skills/execution-environment/SKILL.md`; `extensions/drm-copilot/resources/claude-customizations/.claude/skills/execution-environment/SKILL.md`; `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/execution-environment/SKILL.md`; `extensions/drm-copilot/resources/customizations/.github/skills/execution-environment/SKILL.md`.
- Primary Count: 6.
- Cross-check Search Strategy or Query Expression: Grep `^# Execution-Environment Brief` with glob `**/SKILL.md` over the item worktree.
- Cross-check Member Set: the same six paths.
- Cross-check Count: 6.
- Member-set Comparison: identical after normalizing separators.

## Pre-Mortem

- Review checklists: a reviewer can flag the new tolerated key as an undeclared field (`## Parallel-Level Checkpoint` forbids one) or a leg without an honest-disclosure sentence. Mitigation: amend `.claude/rules/parallel-orchestration.md` in the same change and state in each new file header that the legs are policy-level controls, not security controls, and that same-session forgery is possible.
- Coverage: new hook files are Pester-only (line threshold 85%, no branch gate); never-throw `catch` blocks and seam wrappers are easy to leave uncovered. Mitigation: one row per decline sub-code plus a throwing-seam row, and per-file coverage read from `artifacts/pester/powershell-coverage.xml` of the single parallel gate run.
- Mirror parity: every new and changed `.claude/` file needs an equal-text bundle copy and a `core.json` entry, and the brief bullet must land in all six copies. Mitigation: plan tasks that edit each mirror in the same task as its source, then run `test_push_down_claude_resource_contracts.py`, `test_push_down_claude_pack_manifest_completeness.py`, `test_push_down_pack_manifest_dependency_closure.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_execution_environment_brief_contracts.py`, and `parallel-orchestrate-run-closing.Tests.ps1`; the plan's Mirror parity bullet names the brief-update task.
- File size: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` is at its 500-line cap (`legacy-codex-hook-contracts.Tests.ps1`), and `enforce-orchestration-preimplementation-gate-docs.ps1` is byte-pinned across four copies. Mitigation: no edit to either; new logic goes into new Claude-only siblings; the Claude gate (about 487 lines) and the model-routing hook (about 406 lines) grow by single-digit lines.
- Test isolation: a new real read of the parallel checkpoint that existing suites do not mock would read the developer's session-root checkpoint and pass locally but differ in CI; Pester mocks of exported module functions can be bound to the wrong module instance. Mitigation: read only through `Get-WorktreeRunCheckpointText` and the existing HEAD-branch seam, register the epic-state baseline mocks, use no temporary files, and run the leak scan; tests run only in the parallel gate.
- CI-only behavior: the Linux hook-suite job runs `tests/scripts/claude-hooks` on a case-sensitive file system, and fixtures with drive letters fail there. Mitigation: fixtures use forward-slash roots without drive letters, `Join-Path`, and exact file-name case; no test reads gitignored `artifacts/` state.
- Evidence: fail-before evidence for both legs must be captured before the fix and stay append-only with clock-read timestamps. Mitigation: plan a Phase 0 task that writes `evidence/regression-testing/fail-before.<timestamp>.md` from a task-check run of the two new allow rows against the unfixed hooks, records no absolute paths, and is never rewritten.

## Open Items for the Orchestrator

- To confirm by orchestrator: the exact `Get-Content` line count of `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` and its bundle copy.
- To confirm by orchestrator: that the main checkout currently has `parallel/harness-learnings-2026-11-09-plan` checked out and that commit c295f89d1 is pushed, so the post-merge records PR for that run resolves through the new leg.
- To confirm by orchestrator: whether `Test-ExemptOrchestrationStagingCommand` (issue #539) is what admitted the Run Closing `git add`/`git commit` at the coordinator root; the research did not trace it, and the fix does not depend on it.
- The receipt-Write denial (finding 2) is derived from code reading. Confirm it with the fail-before Pester row before implementation.

OWNER-DIRECTIVE-DECISION: OD-1 | scheduling | honored | - | Autonomous mode was applied: the research chose one recommended design and recorded open items for orchestrator confirmation instead of stopping for a decision.
