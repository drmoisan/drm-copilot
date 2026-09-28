# Skip-Branch Stand-In Relocation — Behavior Preserved

- **Task:** [P2-T4]
- **Issue:** #505
- **Verifies:** the [P2-T2] transcription and the [P2-T3] deletion-plus-aliased-import did not change
  the behavior of `test_runtime_reports_missing_result_when_branch_absent`.

Timestamp: 2026-08-25T09-37

Command: `poetry run pytest tests/scripts/dev_tools/test_fix_all_failure_paths.py::test_runtime_reports_missing_result_when_branch_absent`

EXIT_CODE: 0

## Raw Result

```
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a75166ce0ad92cc5f
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collected 1 item

tests\scripts\dev_tools\test_fix_all_failure_paths.py .                  [100%]

============================== 1 passed in 0.10s ==============================
```

## Byte-Identity Verification for [P2-T3]

The [P2-T3] acceptance criterion is that the **body** of
`test_runtime_reports_missing_result_when_branch_absent` is byte-identical to its pre-change form.
Verified with `git diff -U0 -- tests/scripts/dev_tools/test_fix_all_failure_paths.py`, which
produced exactly three hunks:

| Hunk | Location | Change |
| --- | --- | --- |
| `@@ -17,0 +18,3 @@` | import block | added the aliased import of `SkipBranchThread` |
| `@@ -20 +23 @@` | `TYPE_CHECKING` block | removed the now-unused `Callable` name |
| `@@ -425,39 +427,0 @@` | former class site | deleted the `_SkipBranchThread` definition |

No hunk falls inside the test function, which begins after the deleted class. The function body,
including its `monkeypatch.setattr(runtime.threading, "Thread", _SkipBranchThread)` call and its
`assert exit_code == 0` assertion, is unchanged. Because the import is aliased back to the original
private name, the call site did not have to be rewritten at all.

The `Callable` removal is the micro-action [P2-T3] authorizes explicitly. Its only two uses in the
module were at former lines 442-443, inside the deleted class; `Iterable`, `Mapping`, and `Sequence`
remain in use at lines 34, 40, 53, and 54, and `MonkeyPatch` at lines 398 and 465, so only
`Callable` was removed. Leaving it in place would have introduced a new Ruff finding against the
zero-finding baseline recorded at [P0-T8].

## Supporting Checks on the New Module

| Check | Command | Result |
| --- | --- | --- |
| Type check | `poetry run pyright tests/scripts/dev_tools/fix_all_thread_stubs.py` | 0 errors, 0 warnings ([P2-T1] acceptance) |
| Lint | `poetry run ruff check tests/scripts/dev_tools/fix_all_thread_stubs.py` | All checks passed |
| Format | `poetry run black tests/scripts/dev_tools/fix_all_thread_stubs.py` | 1 file left unchanged |

File sizes after Phase 2, both within the 500-line limit:

| File | Lines |
| --- | --- |
| `tests/scripts/dev_tools/fix_all_thread_stubs.py` | 176 |
| `tests/scripts/dev_tools/test_fix_all_failure_paths.py` | 456 (was 492) |

The stub module is 176 lines against the plan's 160-line working budget. The budget was a planning
estimate; the binding constraint is the 500-line limit in `.claude/rules/general-code-change.md`,
which is satisfied with wide margin. The overage is attributable to the module and class docstrings
explaining why the stand-ins exist. `test_fix_all_failure_paths.py` dropped from 492 to 456 lines,
increasing its headroom against the limit from 8 lines to 44.

Output Summary: `1 passed`, exit code 0.
`test_runtime_reports_missing_result_when_branch_absent` behaves identically after
`_SkipBranchThread` was moved to `tests/scripts/dev_tools/fix_all_thread_stubs.py` as the
module-public `SkipBranchThread` and re-imported under its original private name.
`git diff -U0` confirms the three change hunks are confined to the import block, the
`TYPE_CHECKING` block, and the deleted class definition, leaving the test function body
byte-identical. The new module passes Pyright with 0 errors, passes Ruff, and is Black-clean.
