# Phase 0 — Repository-Wide Python Test and Coverage Baseline

Timestamp: 2026-08-28T12-47

Task: [P0-T12]

Command: `poetry run pytest --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p0t12.json --cov` (working directory: repository root)

EXIT_CODE: 1

ExpectedExitCode: 1

The recorded exit code is the exit code of the pytest run itself, captured directly from the
command and not from a pipeline tail.

## Output Summary

### Test counts

pytest summary line, verbatim:

```
================= 1 failed, 4194 passed, 5 skipped in 28.07s ==================
```

- Passed: **4194**
- Failed: **1**
- Skipped: 5

### Node ID of every failed test

Exactly one test failed. Its node ID is:

```
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

### Assertion message of the failed test, verbatim

```
E           AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
E           assert WindowsPath('.claude/state/python-batch-budget.default.json') in [WindowsPath('.claude/agent-memory/epic-orchestrator/feedback_commit_push_memory_before_pr.md'), ...]
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:120: AssertionError
```

### Bounded-exemption anchoring

This baseline anchors the bounded exemption stated at the head of the plan. All three of its
conditions are satisfied, each verified against the run above **before any task of this plan
edited a source file**:

1. The failing node ID is exactly
   `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`.
2. The run reports exactly one failed test.
3. The assertion message names a path under `.claude/state/`, in the backslash rendering
   (`.claude\state\python-batch-budget.default.json`) on the message line and in the
   forward-slash rendering on the `assert` line.

The measured counts `1 failed, 4194 passed, 5 skipped` match the counts the plan records as
measured on this branch. `[P6-T2]`, `[P8-T9]`, and `[P8-T10]` may therefore invoke the exemption
with `ExpectedExitCode: 1`, provided each of their own runs re-satisfies all three conditions. A
second failing test, a different node ID, or an assertion message naming a path outside
`.claude/state/` is a real failure and the exemption does not apply.

### Coverage, `TOTAL` row of the terminal table, verbatim

```
TOTAL                                                               15180   1109   5576    567    91%
```

| Column | Value |
| --- | --- |
| `Stmts` | 15180 |
| `Miss` | 1109 |
| `Branch` | 5576 |
| `BrPart` | 567 |
| `Cover` | 91% |

### Coverage percentages read from the JSON `totals` object

Per the Python coverage-reading convention at the head of the plan, the two threshold values are
read from `artifacts/python/cov-p0t12.json`, never derived from the terminal columns.

Command: `poetry run python -c "import json;d=json.load(open('artifacts/python/cov-p0t12.json'))['totals'];print(...)"`

- `percent_statements_covered`: **92.69433465085639**
- `percent_branches_covered`: **85.27618364418939**

The combined `percent_covered` key of the same object reads 90.70148390826749. It is neither of
the two threshold values and is recorded here only to make explicit that it was not used.

For reference, the discarded derivation `(Stmts - Miss) / Stmts` over the printed columns yields
`(15180 - 1109) / 15180 = 92.7` percent, which agrees with `percent_statements_covered` to one
decimal place as the convention states. The discarded branch derivation
`(Branch - BrPart) / Branch` yields `(5576 - 567) / 5576 = 89.8` percent, which overstates the
true `percent_branches_covered` of 85.28 by 4.5 points — the exact overstatement the convention
warns of. Only the JSON values are used for any threshold.

No placeholder value appears in this artifact.
