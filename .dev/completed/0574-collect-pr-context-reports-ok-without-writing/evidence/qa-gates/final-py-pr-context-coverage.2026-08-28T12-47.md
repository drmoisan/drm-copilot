# Phase 8 — Final Targeted Python Coverage Gate

Timestamp: 2026-08-28T12-47

Task: [P8-T10]

Commands, working directory the repository root:

- **Run A:** `poetry run pytest --cov=scripts.dev_tools.pr_context.collector --cov=scripts.dev_tools.pr_context.summary_helpers --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p8t10-a.json`
- **Run B:** `poetry run pytest --cov=scripts.dev_tools.pr_context.collector_documents --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/cov-p8t10-b.json`

EXIT_CODE: 1

ExpectedExitCode: 1

Both runs exited 1. Each recorded exit code is the exit code of its own pytest run, captured
directly and not from a pipeline tail. One artifact suffices for both runs because both declare
the same expectation.

Neither command carries a test-path operand, so each collects the whole repository suite and each
therefore encounters the same pre-existing failure.

---

## Output Summary — Run A

### Counts and the failed node ID

```
================= 1 failed, 4197 passed, 5 skipped in 11.66s ==================
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

- Passed: **4197**
- Failed: **1**

Assertion message of the failed test:

```
E           AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
```

### Terminal coverage table, verbatim

```
Name                                              Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\pr_context\collector.py           186     12     66      9    92%   210, 235, 250, 251->246, 285-286, 312-315, 328, 341, 373
scripts\dev_tools\pr_context\summary_helpers.py     161     14     70      9    88%   80, 129->134, 239, 242, 273, 278, 283-284, 322->329, 332-345
```

| File | Stmts | Miss | Branch | BrPart | Cover |
| --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/pr_context/collector.py` | 186 | 12 | 66 | 9 | 92% |
| `scripts/dev_tools/pr_context/summary_helpers.py` | 161 | 14 | 70 | 9 | 88% |

---

## Output Summary — Run B

### Counts and the failed node ID

```
================= 1 failed, 4197 passed, 5 skipped in 13.49s ==================
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

- Passed: **4197**
- Failed: **1**

The node ID and the assertion message are identical to Run A's.

### Terminal coverage table, verbatim

```
Name                                                  Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\pr_context\collector_documents.py      60      5     22      3    90%   85-86, 232, 293, 341
```

| File | Stmts | Miss | Branch | BrPart | Cover |
| --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/pr_context/collector_documents.py` | 60 | 5 | 22 | 3 | 90% |

---

## Coverage percentages read from the JSON `summary` object of each file entry

Per the Python coverage-reading convention at the head of the plan, both threshold values for each
file are read from the `summary` object inside that file's entry under `files` in the JSON that
run wrote, never derived from the terminal columns and never read from the file entry itself.

| File | JSON | `percent_statements_covered` | >= 85 | `percent_branches_covered` | >= 75 |
| --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/pr_context/collector.py` | `cov-p8t10-a.json` | **93.54838709677419** | yes | **86.36363636363636** | yes |
| `scripts/dev_tools/pr_context/summary_helpers.py` | `cov-p8t10-a.json` | **91.30434782608695** | yes | **81.42857142857143** | yes |
| `scripts/dev_tools/pr_context/collector_documents.py` | `cov-p8t10-b.json` | **91.66666666666667** | yes | **86.36363636363636** | yes |

All three rows are at or above 85 statements and at or above 75 branches, as this task requires.

---

## Bounded exemption invoked

Both runs pass under the bounded exemption stated at the head of the plan. All three conditions
hold for each run: the failing node ID is exactly the one anchored in the `[P0-T12]` baseline
before any task of this plan edited a source file; each run reports exactly one failed test; and
each assertion message names a path under `.claude/state/`. No second failing test, no different
node ID, and no assertion naming a path outside `.claude/state/` appeared in either run.

---

## Regression repair performed by this task

An earlier pass of Run A measured `collector.py` branch coverage at **84.84848484848484** against
the `[P0-T13]` baseline of **84.88372093023256**. That is a decrease of 0.035 points. `[P8-T11]`
treats a regression on a changed file as a failure of the task rather than a note, so it was
repaired rather than recorded.

The uncovered exit was the changed-file bucketing loop in `collector.py` falling through for a path
matching none of its buckets — neither a rename, nor Python or PowerShell, nor docs. The git stub
in `tests/scripts/dev_tools/test_pr_context_freshness.py` reported a single docs path, so that exit
was never taken. The stub now reports a second changed path, an asset file matching no bucket,
which takes it. `collector.py` branch coverage rose to 86.36363636363636, above the baseline, and
the partial-branch marker `329->323` disappeared from the missing list.

No production code was changed to obtain that result; only the test stub was extended. Phase 8 was
restarted from `[P8-T1]` afterwards and every task rerun in order, which is the pass recorded here.

No placeholder value appears in this artifact.
