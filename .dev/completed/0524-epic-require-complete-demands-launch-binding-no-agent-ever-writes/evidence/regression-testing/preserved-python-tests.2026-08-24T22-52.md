# Preserved Python Launch-Binding Tests [P4-T5]

Timestamp: 2026-08-24T22-52

Task: [P4-T5]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad5151536d95b2586` (repository root of the worktree)

Command: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py -p no:cacheprovider --no-header -v`

EXIT_CODE: 0

Output Summary:

- Result line, verbatim: `50 passed in 0.17s`.
- Passed: **50**. Failed: **0**. Errors: **0**. Skipped: **0**.
- Exit code captured directly from the pytest process. The command was not piped into a pager before the exit status
  was read; output was redirected to a file and the status taken from the redirected invocation.

## Each preserved test named by [P4-T5], with its observed result

| Preserved test | Result |
| --- | --- |
| `test_model_routing_gate_accepts_complete_launch_binding` | PASSED |
| `test_topology_gate_activates_launch_binding_validation` | PASSED |
| `test_unlaunched_feature_does_not_require_binding_under_routing_gate` | PASSED |
| `test_launch_binding_is_dormant_without_an_enforcement_gate` | PASSED |
| `test_require_complete_accepts_complete_persisted_binding` | PASSED |
| `test_require_complete_rejects_unmerged_feature` | PASSED |
| `test_require_complete_rejects_missing_merge_commit_sha` | PASSED |
| `test_require_complete_remains_disabled_by_default` | PASSED |

### Every parametrised case supplying `require_codex_model_routing=True`

All seventeen cases in the four parametrised groups that pass `require_codex_model_routing=True`, plus the two
non-parametrised tests in the same gate class, passed:

| Parametrised test | Cases | Result |
| --- | --- | --- |
| `test_rejects_invalid_branch_worktree_or_artifact_path` | 5 (`branch_name`, `worktree_path` x2, `launch_receipt_path`, `launch_status_path`) | all PASSED |
| `test_rejects_delegation_binding_mismatch` | 3 (`feature_folder`, `issue_num`, `agent_name`) | all PASSED |
| `test_rejects_model_receipt_binding_mismatch` | 3 (`delegation_id`, `deployment_agent`, `execution_context`) | all PASSED |
| `test_cross_checks_max_parallel_features` | 3 (`0`, `9`, `True`) | all PASSED |
| `test_requires_singular_delegation_and_model_receipts` | 1 | PASSED |
| `test_requires_unique_branch_and_delegation_id` | 1 | PASSED |
| `test_accepts_canonical_windows_worktree_and_absolute_artifacts` | 1 | PASSED |

These are the cases that exercise the Codex-gate activation path, under which [P3-T3] leaves
`require_launch_paths` false and the gate stays unconditional. Their passing is the evidence that behaviour under
either Codex flag is byte-for-byte unchanged.

## No preserved test body was edited — verified, not asserted

The claim was verified mechanically rather than from recollection. A script parsed both the `HEAD` revision of
`tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py` (obtained with
`git show HEAD:<path>`) and the working-tree revision with `ast`, extracted each top-level function's exact source
segment with `ast.get_source_segment`, and compared the segments string-for-string.

Result: **every one of the fifteen preserved functions is byte-identical to its `HEAD` source segment.**

```
UNCHANGED: test_model_routing_gate_accepts_complete_launch_binding
UNCHANGED: test_topology_gate_activates_launch_binding_validation
UNCHANGED: test_unlaunched_feature_does_not_require_binding_under_routing_gate
UNCHANGED: test_launch_binding_is_dormant_without_an_enforcement_gate
UNCHANGED: test_require_complete_accepts_complete_persisted_binding
UNCHANGED: test_require_complete_rejects_unmerged_feature
UNCHANGED: test_require_complete_rejects_missing_merge_commit_sha
UNCHANGED: test_require_complete_remains_disabled_by_default
UNCHANGED: test_rejects_invalid_branch_worktree_or_artifact_path
UNCHANGED: test_rejects_delegation_binding_mismatch
UNCHANGED: test_rejects_model_receipt_binding_mismatch
UNCHANGED: test_requires_singular_delegation_and_model_receipts
UNCHANGED: test_requires_unique_branch_and_delegation_id
UNCHANGED: test_cross_checks_max_parallel_features
UNCHANGED: test_accepts_canonical_windows_worktree_and_absolute_artifacts
ADDED: test_require_complete_skips_feature_without_launch_paths
ADDED: test_require_complete_rejects_partial_launch_binding
REMOVED: test_require_complete_requires_binding_for_every_feature

HEAD function count    : 19
WORKING function count : 20
Only in working tree   : ['test_require_complete_rejects_partial_launch_binding', 'test_require_complete_skips_feature_without_launch_paths']
Only at HEAD           : ['test_require_complete_requires_binding_for_every_feature']

RESULT: every preserved test body is byte-identical to HEAD
```

The set difference confirms the file's function inventory changed by exactly three names: the two tests added by
[P2-T1] and [P4-T2], and the one test removed by [P4-T1]. The three shared helpers `_feature`, `_state`, and
`_launch_errors` appear in neither difference set and are therefore unchanged.

`git diff` corroborates this independently: the file carries a single hunk starting at line 133, bounded above by
the closing assertion of `test_launch_binding_is_dormant_without_an_enforcement_gate` as context and below by the
docstring of `test_require_complete_accepts_complete_persisted_binding` as context. No preserved function appears on
a `+` or `-` line.

`tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py` and
`tests/scripts/dev_tools/test_validate_epic_planner_state_launch_binding.py` are not modified by this feature at all;
neither appears in `git status --porcelain`.
