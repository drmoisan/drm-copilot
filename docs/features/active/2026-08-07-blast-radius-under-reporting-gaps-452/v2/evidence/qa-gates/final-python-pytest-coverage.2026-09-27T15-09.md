# Final QA — Pytest Repository-Wide Coverage (P6-T5) — FAILED ACCEPTANCE, STOP FOR PLANNER REVISION

Timestamp: 2026-09-27T15-09

Iteration: 1

Task start: 2026-09-27T15:08:48 (local)

Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json

EXIT_CODE: 1

Command: poetry run python `<scratchpad>`/coverage_totals.py

EXIT_CODE: 0

Pytest summary and failure:

```
TOTAL                                                               15841   1114   5760    573    91%
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
================= 1 failed, 5173 passed, 6 skipped in 17.51s ==================
```

Failure detail (verbatim):

```
>           assert (
                relative_path in bundled_files
            ), f"Repo file missing from bundle: {relative_path}"
E           AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-a88b6eee8cee55db1-fc5879e9.json
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:137: AssertionError
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
GENERATED_AT=2026-09-27T15:09:01.479272
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

Acceptance evaluation:

| Criterion | Required | Observed | Result |
| --- | --- | --- | --- |
| Collected count | P0-T23 5154 + 26 = 5180 | 5173 + 1 + 6 = 5180 | pass |
| Failed node-ID set | subset of the P0-T23 failed set (empty) | {test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts} | FAIL |
| Skipped count | P0-T23 5 + 1 = 6 | 6 | pass |
| TOTAL_LINE | >= 85.00 and >= 92.97 | 92.97 | pass |
| TOTAL_BRANCH | >= 75.00 and >= 85.68 | 85.68 | pass |
| GENERATED_AT | later than task start 15:08:48 | 15:09:01 | pass |

Diagnosis:

- The failing test enumerates the working-tree `.claude/` directory with the filesystem, not the git index, and does not exclude `.claude/state/`. The file it names, `.claude/state/powershell-batch-budget.worktree-agent-a88b6eee8cee55db1-fc5879e9.json`, is a gitignored runtime state file (`git check-ignore -v` reports `.gitignore:68:.claude/state/`). The PreToolUse PowerShell batch-budget hook wrote it at 15:03 when the Pester consumer was created in P4-T1. A second state file, `.claude/state/python-batch-budget.worktree-agent-a88b6eee8cee55db1-fc5879e9.json`, was written at 14:58 by the Python batch-budget hook. Both files postdate the P0-T23 baseline run (14:38), which is why the baseline failed set is empty.
- This is the known local-only condition tracked by open issue #510 (claude-resource-parity-enumerates-gitignored-state). A CI checkout does not run the budget hooks, so `.claude/state/` does not exist there. No file this plan writes is involved, and the test's content-identity property for `.claude/` versus the bundle is unaffected by this cycle, which changes no file under `.claude/`.
- No recovery fix is available under Loop Re-entry and Recovery item 2. The failure cannot be remedied by editing either consumer. The only local remedy is deleting hook enforcement state outside the write set, which regenerates on the next agent edit and is the workaround #510 warns against. Item 2 therefore requires leaving P6-T5 unchecked, making no edit, and stopping for a planner revision.

Output Summary: EXIT_CODE 1. Every numeric criterion passes (collected 5180, skipped 6, line 92.97%, branch 85.68%, generated after task start). The failed-set criterion fails on one local-only failure caused by gitignored hook state created during execution (issue #510). P6-T5 is left unchecked; STOP for planner revision. Suggested revision scope: admit this issue-#510 test to the P6-T5 and P8 baseline-relative failed-set comparison when its assertion names only a `.claude/state/` path, or add a pre-gate step that records the `.claude/state/` listing and a `git hash-object` byte-identity check as the durable substitute.
