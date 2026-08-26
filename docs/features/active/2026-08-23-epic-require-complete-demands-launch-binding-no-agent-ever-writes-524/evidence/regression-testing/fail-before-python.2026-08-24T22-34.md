# Fail-Before — Python Regression Test [P2-T2] [expect-fail]

Timestamp: 2026-08-24T22-34

Task: [P2-T2]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad5151536d95b2586` (repository root of the worktree)
Test added in [P2-T1]: `test_require_complete_skips_feature_without_launch_paths` in `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py` (line 136)

Command: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py -k test_require_complete_skips_feature_without_launch_paths`

EXIT_CODE: 1
ExpectedExitCode: 1

Output Summary:

- **1 failed, 0 passed**, 26 deselected. Collected 27 items, 1 selected.
- Failing test: `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py::test_require_complete_skips_feature_without_launch_paths`.
- Failure mode: `AssertionError` at line 158, `assert errors == []`.
- The unfixed validator returned **4 launch-binding errors** where the test asserts an empty list. All four are launch-binding errors and none is a completion error, which confirms the failure is caused solely by the gate under correction.
- Python 3.13.12, pytest 9.0.2, plugins anyio-4.12.1 and cov-7.0.0.

The four launch-binding errors the unfixed validator returned, listed in order:

1. `Epic checkpoint feature 'child-a' launch binding.launch_receipt_path must be under artifacts/orchestration/epic-child-launches/.`
2. `Epic checkpoint feature 'child-a' launch binding.launch_status_path must be under artifacts/orchestration/epic-child-launches/.`
3. `Epic checkpoint feature 'child-a' launch binding.delegation_receipt must be an object.`
4. `Epic checkpoint feature 'child-a' launch binding.model_routing_receipt must be an object.`

This is four rather than five because the `_feature` helper supplies the POSIX worktree path `/repo/worktrees/child-a`, which `_is_canonical_worktree_path` accepts. The fifth error present in the [P1-T3] fixture run is the `worktree_path` error produced by the drive-qualified forward-slash form used there to reproduce the destination shape. Neither count depends on the other; the test asserts an empty list, so any non-zero count fails it.

Assertion diff, verbatim from the run:

```
>       assert errors == []
E       assert ['Epic checkp...e an object.'] == []
E
E         Left contains 4 more items, first extra item: "Epic checkpoint feature 'child-a' launch binding.launch_receipt_path must be under artifacts/orchestration/epic-child-launches/."
E         Use -v to get more diff

tests\scripts\dev_tools\test_validate_epic_orchestrator_state_launch_binding.py:158: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py::test_require_complete_skips_feature_without_launch_paths
====================== 1 failed, 26 deselected in 0.10s =======================
```

Supplementary run recorded to expand the truncated diff. The command differs from the acceptance command only by the added `-vv` verbosity flag; it exits 1 identically and asserts nothing new.

Supplementary command: `poetry run pytest tests/scripts/dev_tools/test_validate_epic_orchestrator_state_launch_binding.py -k test_require_complete_skips_feature_without_launch_paths -vv`
Supplementary EXIT_CODE: 1

```
E         Full diff:
E         - []
E         + [
E         +     "Epic checkpoint feature 'child-a' launch binding.launch_receipt_path must "
E         +     'be under artifacts/orchestration/epic-child-launches/.',
E         +     "Epic checkpoint feature 'child-a' launch binding.launch_status_path must "
E         +     'be under artifacts/orchestration/epic-child-launches/.',
E         +     "Epic checkpoint feature 'child-a' launch binding.delegation_receipt must "
E         +     'be an object.',
E         +     "Epic checkpoint feature 'child-a' launch binding.model_routing_receipt "
E         +     'must be an object.',
E         + ]
```

Expect-fail rationale: a failing test is the correct and required outcome for this task. It establishes fail-before evidence for the Phase 3 production change. The matching pass-after run is the acceptance condition of [P3-T3].
