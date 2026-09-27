# Final QA — Pytest Repository-Wide Coverage (P6-T5)

Timestamp: 2026-09-27T15-40

Iteration: 1 (resumed at the revision 9 resume point; supersedes qa-gates/final-python-pytest-coverage.2026-09-27T15-09.md under Loop Re-entry and Recovery item 5)

Task start: 2026-09-27T15:39:40 (local)

## Write-set check (first P6-T5 run after revision 9)

Command: git diff --exit-code 858fa12c HEAD -- tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json tests/scripts/dev_tools/test_blast_radius_regression_452.py tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1

EXIT_CODE: 0

Output: (empty)

Command: git status --porcelain -- tests/fixtures/blast_radius/regression-452/under-reporting-corpus.json tests/scripts/dev_tools/test_blast_radius_regression_452.py tests/scripts/claude-lib/blast-radius/BlastRadius.Regression452.Tests.ps1

EXIT_CODE: 0

Output: (empty capture)

Result (check run at 2026-09-27T15:38:08, before the test run below): the three code write targets are unchanged since the stop commit 858fa12c; P6-T1 through P6-T4 still describe them.

## Test run

Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json

EXIT_CODE: 1

The failed node-ID set is read from the short test summary line beginning FAILED (the repository addopts value supplies -ra).

Command: poetry run python `<scratchpad>`/coverage_totals.py

EXIT_CODE: 0

Pytest summary:

```
TOTAL                                                               15841   1114   5760    573    91%
================= 1 failed, 5173 passed, 6 skipped in 17.80s ==================
```

Failed node-ID set (short test summary):

```
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

Skipped (short test summary):

```
SKIPPED [1] tests\scripts\dev_tools\test_blast_radius_regression_452.py:483: Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_empty_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_missing_opening_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_non_mapping_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_unterminated_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_yaml_parse_failure declares no accessor expectation.
```

Helper output:

```
GENERATED_AT=2026-09-27T15:39:53.839302
TOTAL_LINE=14727/15841=92.97
TOTAL_BRANCH=4935/5760=85.68
FILE _blast_radius_conflicts.py line=100.00 branch=100.00
FILE _blast_radius_extraction.py line=100.00 branch=100.00
FILE _blast_radius_glob.py line=98.28 branch=96.43
FILE _blast_radius_guards.py line=100.00 branch=100.00
FILE _blast_radius_mergeable.py line=96.43 branch=92.86
FILE _blast_radius_normalization.py line=100.00 branch=100.00
FILE _blast_radius_thresholds.py line=100.00 branch=100.00
FILE _blast_radius_token_shapes.py line=100.00 branch=100.00
FILE _blast_radius_validation.py line=100.00 branch=100.00
FILE compute_blast_radius.py line=100.00 branch=100.00
```

## Issue #510 allowance

- Excused node ID: tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
- Condition (a): the node ID equals the node ID named in Execution Conventions, character for character (the FAILED line already uses forward slashes). Holds.
- Condition (b): exactly one line of the captured output matches `^E\s+AssertionError: Repo file missing from bundle: (\S+)\s*$` (count 1). Matched line verbatim:

```
E           AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-a88b6eee8cee55db1-fc5879e9.json
```

- Condition (c): normalized path `.claude/state/powershell-batch-budget.worktree-agent-a88b6eee8cee55db1-fc5879e9.json` begins with `.claude/state/`, has further characters, and contains no `..` segment. Holds.
- Condition (d): command `git check-ignore -v -- .claude/state/powershell-batch-budget.worktree-agent-a88b6eee8cee55db1-fc5879e9.json`

EXIT_CODE: 0

Full output (one line; source, line 68, pattern, tab, path):

```
.gitignore:68:.claude/state/	.claude/state/powershell-batch-budget.worktree-agent-a88b6eee8cee55db1-fc5879e9.json
```

Excused under issue #510: local-only gitignored hook state; not evidence of CI behaviour.

## Acceptance evaluation

| Criterion | Required | Observed | Result |
| --- | --- | --- | --- |
| Collected count | P0-T23 5154 + 26 = 5180 | 5173 + 1 + 6 = 5180 | pass |
| Failed node-ID set after #510 excusal | subset of the P0-T23 failed set (empty) | empty | pass |
| Pytest EXIT_CODE 1 | acceptable only when the excused test is the sole failure | sole failure is the excused test | pass |
| Skipped count | P0-T23 5 + 1 (branch NOT FOUND) = 6 | 6 | pass |
| TOTAL_LINE | >= 85.00 and >= 92.97 | 92.97 | pass |
| TOTAL_BRANCH | >= 75.00 and >= 85.68 | 85.68 | pass |
| GENERATED_AT | later than task start 15:39:40 | 15:39:53 | pass |

Output Summary: PASS (iteration 1). Write-set check clean (diff EXIT_CODE 0, empty porcelain). Collected 5180, passed 5173, failed 1 (excused under the issue #510 allowance, all four conditions met), skipped 6. Python repository-wide line coverage 92.97% (14727/15841); branch coverage 85.68% (4935/5760); both equal the P0-T23 baseline and exceed the 85%/75% thresholds.
