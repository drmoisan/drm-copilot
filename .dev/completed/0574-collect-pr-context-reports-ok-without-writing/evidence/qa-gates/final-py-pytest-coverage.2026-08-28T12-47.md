# Phase 8 — Final Repository-Wide Python Test and Coverage Gate

Timestamp: 2026-08-28T12-47

Task: [P8-T9]

Command: `poetry run pytest --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p8t9.json --cov` (working directory: repository root)

EXIT_CODE: 1

ExpectedExitCode: 1

The recorded exit code is the exit code of the pytest run itself, captured directly and not from a
pipeline tail.

## Output Summary

### Test counts

```
================= 1 failed, 4197 passed, 5 skipped in 17.89s ==================
```

- Passed: **4197**
- Failed: **1**
- Skipped: 5

### Node ID and assertion message of every failed test

Exactly one test failed.

```
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

```
E           AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:120: AssertionError
```

### Bounded exemption invoked

The task passes under the bounded exemption stated at the head of the plan. All three conditions
hold:

1. The failing node ID is exactly the one anchored in the `[P0-T12]` baseline, which was captured
   before any task of this plan edited a source file.
2. The run reports exactly one failed test.
3. The assertion message names a path under `.claude/state/`, in the backslash rendering.

No second failing test appeared, no different node ID appeared, and no assertion message named a
path outside `.claude/state/`. The exemption therefore applies and this run does not trigger a
phase restart.

The plan records the measured counts on this branch as `1 failed, 4194 passed, 5 skipped`. This run
reports `1 failed, 4197 passed, 5 skipped`: **3 more passing tests and the identical single
failure**. The 3 added tests are the three in
`tests/scripts/dev_tools/test_pr_context_freshness.py` created by `[P4-T4]` and `[P4-T5]`.

### Coverage, `TOTAL` row of the terminal table, verbatim

```
TOTAL                                                               15208   1109   5578    566    91%
```

| Column | Value |
| --- | --- |
| `Stmts` | 15208 |
| `Miss` | 1109 |
| `Branch` | 5578 |
| `BrPart` | 566 |
| `Cover` | 91% |

### Coverage percentages read from the JSON `totals` object

Per the Python coverage-reading convention at the head of the plan, both threshold values are read
from the `totals` object of `artifacts/python/cov-p8t9.json`, never derived from the terminal
columns.

- `percent_statements_covered`: **92.70778537611783**
- `percent_branches_covered`: **85.29939046253138**

Against the `[P0-T12]` baseline of 92.69433465085639 statements and 85.27618364418939 branches,
both run-level values **rose**: statements by 0.0134 points and branches by 0.0232 points. Neither
regressed.

### Note on the aborted pass

An earlier pass of this task recorded `BrPart` 567 and `percent_branches_covered`
85.28146288992471. Both improved to 566 and 85.29939046253138 after `[P8-T10]`'s regression repair
covered one additional branch exit in `scripts/dev_tools/pr_context/collector.py`. The counts, the
node ID, and the assertion message were identical across both passes.

No placeholder value appears in this artifact.
