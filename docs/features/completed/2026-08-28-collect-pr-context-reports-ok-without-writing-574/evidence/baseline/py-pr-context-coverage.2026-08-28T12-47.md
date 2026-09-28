# Phase 0 — Targeted Python Coverage Baseline for the Two pr-context Modules

Timestamp: 2026-08-28T12-47

Task: [P0-T13]

Command: `poetry run pytest --cov=scripts.dev_tools.pr_context.collector --cov=scripts.dev_tools.pr_context.summary_helpers --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p0t13.json` (working directory: repository root)

EXIT_CODE: 1

ExpectedExitCode: 1

The recorded exit code is the exit code of the pytest run itself, captured directly from the
command and not from a pipeline tail. The command carries no test-path operand, so it collects
the whole repository suite and encounters the same pre-existing failure `[P0-T12]` anchored.

## Output Summary

### Test counts and the failed node ID

```
================= 1 failed, 4194 passed, 5 skipped in 13.80s ==================
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

- Passed: **4194**
- Failed: **1**
- Skipped: 5

Exactly one test failed, and its node ID is identical to the one anchored in `[P0-T12]`. All
three conditions of the bounded exemption stated at the head of the plan are satisfied by this
run as well, so `ExpectedExitCode: 1` is declared above.

### Terminal coverage table, the two named rows recorded verbatim

```
Name                                              Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\pr_context\collector.py           225     17     86     13    90%   143-144, 264, 289, 304, 305->300, 339-340, 366-369, 382, 383->377, 395, 441, 474, 535, 557
scripts\dev_tools\pr_context\summary_helpers.py     154     14     70      9    88%   80, 129->134, 239, 242, 273, 278, 283-284, 322->329, 332-345
TOTAL                                               379     31    156     22    89%
```

| File | Stmts | Miss | Branch | BrPart | Cover |
| --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/pr_context/collector.py` | 225 | 17 | 86 | 13 | 90% |
| `scripts/dev_tools/pr_context/summary_helpers.py` | 154 | 14 | 70 | 9 | 88% |

### Coverage percentages read from the JSON `summary` object of each file entry

Per the Python coverage-reading convention at the head of the plan, both threshold values are
read from the `summary` object inside each file's entry under `files` in
`artifacts/python/cov-p0t13.json`, never derived from the terminal columns and never read from
the file entry itself.

| File | `percent_statements_covered` | `percent_branches_covered` |
| --- | --- | --- |
| `scripts/dev_tools/pr_context/collector.py` | **92.44444444444444** | **84.88372093023256** |
| `scripts/dev_tools/pr_context/summary_helpers.py` | **90.9090909090909** | **81.42857142857143** |

Both files are above the 85 line and 75 branch thresholds at baseline. These are the values
`[P8-T11]` compares the post-change figures against for the no-regression check.

The discarded terminal derivation for `summary_helpers.py`, `(Branch - BrPart) / Branch =
(70 - 9) / 70 = 87.1` percent, overstates the true branch coverage of 81.43 by 5.7 points, which
is the reason the convention forbids it.

No placeholder value appears in this artifact.
