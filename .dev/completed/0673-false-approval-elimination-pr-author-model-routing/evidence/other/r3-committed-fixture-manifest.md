# Committed Fixture Manifest and Sanity Check (issue #673)

Timestamp: 2026-09-19T18-14

Command: `pwsh -NoProfile -File <SCRATCHPAD>/r3-make-fixtures.ps1` to create the roots, then `pwsh -NoProfile -File <SCRATCHPAD>/r3-fixture-sanity.ps1` (route `a`), which imports `.claude/lib/orchestrator-state/OrchestratorState.psm1` and `.claude/lib/worktree-resolution/WorktreeItemResolution.psm1`, runs `Invoke-OrchestratorStatePreflight -CheckpointPath <absolute path composed at run time>` against seven paths, runs `Get-WorktreeItemCheckpointIssue` against every root of the fixture map, and recomputes both body hashes and their carriage-return counts.

EXIT_CODE: 0

## Files created (18)

All paths are relative to `tests/fixtures/worktree-resolution/`. Every file is committed with LF endings.

| Path | Bytes |
| --- | --- |
| `README.md` | (documentation) |
| `pr-author/session-root/artifacts/orchestration/orchestrator-state.json` | 1395 |
| `pr-author/session-root/artifacts/pr_context.summary.txt` | 62 |
| `pr-author/session-root/artifacts/pr_body_1.md` | 34 |
| `pr-author/session-root/artifacts/pr_body_1.receipt.json` | 130 |
| `pr-author/item-own-ready/artifacts/orchestration/orchestrator-state.json` | 1344 |
| `pr-author/item-own-ready/artifacts/pr_context.summary.txt` | 62 |
| `pr-author/item-own-ready/artifacts/pr_body_1.md` | 34 |
| `pr-author/item-own-ready/artifacts/pr_body_1.receipt.json` | 130 |
| `pr-author/item-own-not-ready/artifacts/orchestration/orchestrator-state.json` | 1393 |
| `pr-author/item-own-epic-mode/artifacts/orchestration/orchestrator-state.json` | 1491 |
| `model-routing/session-root/artifacts/orchestration/orchestrator-state.json` | 74 |
| `model-routing/item-own-receipt/artifacts/orchestration/orchestrator-state.json` | 74 |
| `model-routing/item-own-no-receipt/artifacts/orchestration/orchestrator-state.json` | 74 |
| `model-routing/item-stale-receipt/artifacts/orchestration/orchestrator-state.json` | 74 |
| `shared/item-own-invalid-json/artifacts/orchestration/orchestrator-state.json` | 25 |
| `shared/item-own-empty/artifacts/orchestration/orchestrator-state.json` | 0 |
| `shared/item-no-checkpoint/artifacts/pr_context.summary.txt` | 62 |

`git status --porcelain --untracked-files=all -- tests/fixtures/worktree-resolution` lists all 18, so no file is caught by the root-anchored `/artifacts` ignore rule and every one will be committed.

## Checkpoint content

### The base checkpoint

The four `pr-author/` roots derive from one base checkpoint, copied verbatim from `evidence/baseline/repro-fixture-manifest.md`, which that artifact records as having passed `Invoke-OrchestratorStatePreflight`. Its fields are: `objective` `Sibling item A: unrelated single-feature run left at the session root.`; `change_budget_estimate` with `production_files` 1, `test_files` 1, and `rationale` `Sibling item A fixture.`; `path_selected` and `route_id` `small`; `promotion-type` `bug`; `short-name` and `long-name` `sibling-item-a`; `relativeFile` `docs/features/potential/promoted/sibling-item-a.md`; `issue-num` `838`; `feature-folder` `docs/features/active/sibling-item-a-838`; `work-mode` `full-bug`; `plan-path` `docs/features/active/sibling-item-a-838/plan.md`; `completed_steps` `S1_scope`, `S2_research`, `S3_promotion`, `S4_atomic_planning`, `S5_atomic_execution`; `next_step` `S8_create_pr`; `last_updated` `2026-09-17T12:00:00Z`; `step5_status` through `step7_status` `completed`, `step8_status` `in_progress`, `step9_status` and `step10_status` `not_started`; empty `delegation_receipts`, `local_execution_overrides`, and `delegation_bypasses`; one `model_routing_receipts` entry for `atomic-planner` at phase `S4_atomic_planning`, band `C3`, `fable_policy` `disabled`, `table_model` `opus`, `clamped_from` null, `model` `opus`; and `blocked_reason` `none`.

### Per-root content, as a delta from the base

| Root | Checkpoint content |
| --- | --- |
| `pr-author/session-root` | the base checkpoint, unmodified |
| `pr-author/item-own-ready` | base, with `issue-num` `901` and `objective` `Own item B fixture.` |
| `pr-author/item-own-not-ready` | base, with `issue-num` `901` and `step5_status` `pending` |
| `pr-author/item-own-epic-mode` | base, with `issue-num` `901`, plus `"epic_mode": true` and `"epic_context": { "integration_branch": "epic/f5-fixture-integration" }` inserted before `blocked_reason` |
| `model-routing/session-root` | `{"issue-num":"838","model_routing_receipts":[{"agent":"atomic-planner"}]}` |
| `model-routing/item-own-receipt` | `{"issue-num":"901","model_routing_receipts":[{"agent":"atomic-planner"}]}` |
| `model-routing/item-own-no-receipt` | `{"issue-num":"901","model_routing_receipts":[{"agent":"feature-review"}]}` |
| `model-routing/item-stale-receipt` | `{"issue-num":"901","model_routing_receipts":[{"agent":"atomic-planner"}]}` |
| `shared/item-own-invalid-json` | `{ this is not valid json` |
| `shared/item-own-empty` | zero bytes |
| `shared/item-no-checkpoint` | no checkpoint file exists beneath this root |

The three artifact files, where present: `artifacts/pr_context.summary.txt` holds the single line `PR context summary for the worktree-resolution fixture roots.`; `artifacts/pr_body_1.md` holds exactly `Sibling item A pull request body.` followed by one LF; `artifacts/pr_body_1.receipt.json` holds `{"number": 1, "sha256": "8ec387387dff3f847368741d1e8ea393c1e8b70b7f8d7e8e00bcffc2dc1432bb", "created_at": "2099-01-01T00:00:00Z"}`.

## Rows consuming each root

| Root | Rows (by the §7 name's row label) |
| --- | --- |
| `pr-author/session-root` | pr-author R1 (both rows, as working directory), R2, R4 preflight (as a live root), R4 epic (as working directory); and the default working directory for pr-author rows R8, R9, R10, the family-separation row, the unresolved-status row, and the path-capture row |
| `pr-author/item-own-ready` | pr-author R1 (both rows, as resolved target) and R6 (as both working directory and target) |
| `pr-author/item-own-not-ready` | pr-author R3 not-ready and R4 preflight |
| `pr-author/item-own-epic-mode` | pr-author R4 epic base-branch (as resolved target only; it carries no artifact files by design) |
| `model-routing/session-root` | model-routing R1 (as working directory and a live root), R2 sibling-only, R4 own-by-issue, R9 issue-and-branch-differ; and the default working directory for model-routing rows R2 relative-path, R5, R8, R10, the family-separation row, the unresolved-status row, and the path-capture row |
| `model-routing/item-own-receipt` | model-routing R1 and R6 |
| `model-routing/item-own-no-receipt` | model-routing R3 no-receipt, R4 own-by-issue, R4 stale-attempt, R9 two-live-roots |
| `model-routing/item-stale-receipt` | model-routing R4 stale-attempt and R9 two-live-roots |
| `shared/item-own-invalid-json` | pr-author R7 unparseable and model-routing R7 unparseable |
| `shared/item-own-empty` | pr-author R7 empty and model-routing R7 empty |
| `shared/item-no-checkpoint` | pr-author R3 absent-at-target, pr-author R5 (as working directory), model-routing R3 absent-at-target |

## Preflight results

Error text is recorded with the checkpoint's absolute path replaced by `<WORKSPACE_ROOT>/tests/fixtures/worktree-resolution/<root>/artifacts/orchestration/orchestrator-state.json`, per the host-data rule; no host path is reproduced.

| Root | `HasErrors` | Error text |
| --- | --- | --- |
| `pr-author/session-root` | False | (none) |
| `pr-author/item-own-ready` | False | (none) |
| `pr-author/item-own-epic-mode` | False | (none) |
| `pr-author/item-own-not-ready` | True | `Checkpoint PR-creation readiness validation failed: step5_status is pending.` |
| `shared/item-own-invalid-json` | True | `Checkpoint file '<redacted path>' is not valid JSON: Conversion from JSON failed with error: Invalid character after parsing property name. Expected ':' but got: i. Path '', line 1, position 7.` |
| `shared/item-own-empty` | True | `Checkpoint file '<redacted path>' is empty.` |
| `shared/item-no-checkpoint` | True | `Checkpoint file '<redacted path>' does not exist.` |

`pr-author/item-own-epic-mode` reported no errors on its first run, so the contingency in this task's text — add exactly the fields its error text names and re-run — was not triggered and only one run exists to record.

## Recorded issue numbers

| Root | `Get-WorktreeItemCheckpointIssue` | Fixture-map column | Match |
| --- | --- | --- | --- |
| `pr-author/session-root` | `838` | `838` | yes |
| `pr-author/item-own-ready` | `901` | `901` | yes |
| `pr-author/item-own-not-ready` | `901` | `901` | yes |
| `pr-author/item-own-epic-mode` | `901` | `901` | yes |
| `model-routing/session-root` | `838` | `838` | yes |
| `model-routing/item-own-receipt` | `901` | `901` | yes |
| `model-routing/item-own-no-receipt` | `901` | `901` | yes |
| `model-routing/item-stale-receipt` | `901` | `901` | yes |
| `shared/item-own-invalid-json` | (empty) | unknown | yes |
| `shared/item-own-empty` | (empty) | unknown | yes |
| `shared/item-no-checkpoint` | (empty) | none | yes |

The three roots whose map column reads `unknown` or `none` return an empty value, which is how `$null` is recorded here. That is the behaviour RS-6 relies on: an unreadable checkpoint cannot be matched to its issue, so a call carrying issue-only identity denies with the no-target code rather than selecting that root.

## Body hashes and line endings

| Root | Recomputed SHA-256 | Receipt `sha256` | Equal | CR bytes |
| --- | --- | --- | --- | --- |
| `pr-author/session-root` | `8ec387387dff3f847368741d1e8ea393c1e8b70b7f8d7e8e00bcffc2dc1432bb` | `8ec387387dff3f847368741d1e8ea393c1e8b70b7f8d7e8e00bcffc2dc1432bb` | yes | 0 |
| `pr-author/item-own-ready` | `8ec387387dff3f847368741d1e8ea393c1e8b70b7f8d7e8e00bcffc2dc1432bb` | `8ec387387dff3f847368741d1e8ea393c1e8b70b7f8d7e8e00bcffc2dc1432bb` | yes | 0 |

Both bodies hold identical bytes, so both hashes are the same value; that is expected, since the map gives both roots the same body text.

Output Summary: Every acceptance condition holds. `HasErrors` is False for `pr-author/session-root`, `pr-author/item-own-ready`, and `pr-author/item-own-epic-mode`, and True for the other four preflight targets, each for the distinct reason its row requires. Every recorded issue number equals the fixture map's column, with the three unreadable-checkpoint roots returning an empty value. Both recomputed body hashes equal their receipts' `sha256`, and both carriage-return counts are 0, so the recorded hashes hold under the repository's LF normalisation. The epic-mode checkpoint needed no field additions.
