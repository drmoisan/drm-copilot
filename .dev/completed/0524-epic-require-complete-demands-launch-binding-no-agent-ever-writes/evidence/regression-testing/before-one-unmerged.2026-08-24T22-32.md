# Pre-Change Regression Evidence — One-Unmerged Fixture [P1-T4] [expect-fail]

Timestamp: 2026-08-24T22-32

Task: [P1-T4]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad5151536d95b2586` (repository root of the worktree)
Fixture: `docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/fixture-four-features-one-unmerged.json`

Command: `poetry run python -m scripts.dev_tools.validate_orchestration_artifacts epic-orchestrator-state docs/features/active/2026-08-23-epic-require-complete-demands-launch-binding-no-agent-ever-writes-524/evidence/regression-testing/fixture-four-features-one-unmerged.json --require-complete`

EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:

- Total error count: **21**.
- Launch-binding errors (lines containing `launch binding`): **20**.
- Errors containing the phrase `merge_status is not merged/worktree_removed`: **exactly 1**.
- 20 + 1 = 21, accounting for every error line with no remainder.

The single completion error, verbatim:

```
Epic checkpoint completion validation failed: feature 'child-d' merge_status is not merged/worktree_removed.
```

The total of 21 is the destination reproduction recorded in `issue.md`: 21 errors on the `quickfiler-suite-determinism-foundation` epic, of which exactly one is a genuine finding and 20 are five per feature across four features.

This fixture is byte-identical to the [P1-T1] fixture except that `child-d` carries `merge_status: "worktree_created"` rather than `"merged"`. That single difference is what produces the one genuine completion error, and it is the discrimination guarantee: after the Phase 3 change the 20 launch-binding errors must disappear while this one completion error must remain. The matching post-change run is [P5-T2].

Full output, verbatim (21 lines):

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
Epic checkpoint completion validation failed: feature 'child-d' merge_status is not merged/worktree_removed.
```

Expect-fail rationale: a non-zero exit is the correct and required outcome for this task, and remains the correct outcome after the Phase 3 change — the fixture is genuinely incomplete. What must change is the composition of the error list, from 20 launch-binding plus 1 completion, to 0 launch-binding plus 1 completion.
