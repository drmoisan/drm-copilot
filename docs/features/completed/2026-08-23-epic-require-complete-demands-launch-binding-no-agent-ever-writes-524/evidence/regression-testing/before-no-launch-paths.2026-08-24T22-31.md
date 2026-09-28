# Pre-Change Regression Evidence — No-Launch-Paths Fixture [P1-T3] [expect-fail]

Timestamp: 2026-08-24T22-31

Task: [P1-T3]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad5151536d95b2586` (repository root of the worktree)
Fixture: `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/fixture-four-features-no-launch-paths.json`

Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts epic-orchestrator-state docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/fixture-four-features-no-launch-paths.json --require-complete`

EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:

- Total error count: **20**.
- Error lines whose text contains the phrase `launch binding`: **20**.
- Error lines that are NOT launch-binding errors: **0**.
- The launch-binding count is exactly 20, which is five errors per feature across four features, matching the destination reproduction recorded in `issue.md`.

The five errors per feature, confirmed identical for `child-a` through `child-d`:

| # | Error suffix | Cause |
| --- | --- | --- |
| 1 | `launch binding.worktree_path must be a non-empty canonical absolute path.` | `_is_canonical_worktree_path` rejects the drive-qualified forward-slash form `C:/repo/worktrees/child-X` |
| 2 | `launch binding.launch_receipt_path must be under artifacts/orchestration/epic-child-launches/.` | key absent |
| 3 | `launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.` | key absent |
| 4 | `launch binding.delegation_receipt must be an object.` | key absent; short-circuits three sub-checks |
| 5 | `launch binding.model_routing_receipt must be an object.` | key absent; short-circuits three sub-checks |

No completion error appears, because every feature in this fixture carries `merge_status: "merged"` and the checkpoint carries a non-empty `epic_merge_pr.merge_commit_sha`. The 20 errors are therefore entirely attributable to the launch-binding gate under `require_complete` alone, which is the defect this work corrects.

Fixture verification recorded alongside this run: the file parses as JSON, its `features` array has exactly 4 entries, and 0 of them carry either `launch_receipt_path` or `launch_status_path`.

Full output, verbatim (20 lines):

```
Epic checkpoint feature 'child-a' launch binding.worktree_path must be a non-empty canonical absolute path.
Epic checkpoint feature 'child-a' launch binding.launch_receipt_path must be under artifacts/orchestration/epic-child-launches/.
Epic checkpoint feature 'child-a' launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.
Epic checkpoint feature 'child-a' launch binding.delegation_receipt must be an object.
Epic checkpoint feature 'child-a' launch binding.model_routing_receipt must be an object.
Epic checkpoint feature 'child-b' launch binding.worktree_path must be a non-empty canonical absolute path.
Epic checkpoint feature 'child-b' launch binding.launch_receipt_path must be under artifacts/orchestration/epic-child-launches/.
Epic checkpoint feature 'child-b' launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.
Epic checkpoint feature 'child-b' launch binding.delegation_receipt must be an object.
Epic checkpoint feature 'child-b' launch binding.model_routing_receipt must be an object.
Epic checkpoint feature 'child-c' launch binding.worktree_path must be a non-empty canonical absolute path.
Epic checkpoint feature 'child-c' launch binding.launch_receipt_path must be under artifacts/orchestration/epic-child-launches/.
Epic checkpoint feature 'child-c' launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.
Epic checkpoint feature 'child-c' launch binding.delegation_receipt must be an object.
Epic checkpoint feature 'child-c' launch binding.model_routing_receipt must be an object.
Epic checkpoint feature 'child-d' launch binding.worktree_path must be a non-empty canonical absolute path.
Epic checkpoint feature 'child-d' launch binding.launch_receipt_path must be under artifacts/orchestration/epic-child-launches/.
Epic checkpoint feature 'child-d' launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.
Epic checkpoint feature 'child-d' launch binding.delegation_receipt must be an object.
Epic checkpoint feature 'child-d' launch binding.model_routing_receipt must be an object.
```

Expect-fail rationale: a non-zero exit is the correct and required outcome for this task. The run records the defect before the Phase 3 production change; the matching post-change run is [P5-T1], which must exit 0 with 0 errors.
