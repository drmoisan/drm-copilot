# Baseline — Python tests and coverage (issue #643, task [P0-T7])

- Timestamp: 2026-09-07T15:15Z
- Command: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json` (run from the worktree root)
- EXIT_CODE: 1

## Output Summary

### pytest summary line (verbatim)

```text
1 failed, 4244 passed, 5 skipped in 28.36s
```

Passed count for later comparison (plan task [P8-T5] requires at least this value plus 25): 4244.

### TOTAL row (verbatim)

```text
TOTAL                                                               15210   1109   5578    566    91%
```

### Numeric coverage percentages computed from `artifacts/python/coverage.json` `totals`

Extraction command:
`poetry run python -c "import json; t=json.load(open('artifacts/python/coverage.json'))['totals']; print(t['covered_lines'], t['num_statements'], t['covered_branches'], t['num_branches'])"`

- Statement coverage: `covered_lines / num_statements * 100` = `14101 / 15210 * 100` = **92.71%**
  (source integers: `covered_lines` = 14101, `num_statements` = 15210).
- Branch coverage: `covered_branches / num_branches * 100` = `4758 / 5578 * 100` = **85.30%**
  (source integers: `covered_branches` = 4758, `num_branches` = 5578).

Both values are above the uniform thresholds of `.claude/rules/quality-tiers.md` (statement/line
>= 85%, branch >= 75%). The `91%` shown in the terminal `TOTAL` row is the single combined `Cover`
column pytest-cov prints; the two separate percentages above are the values the plan requires and
are derived from the JSON report.

### Failing node list — the constraint C4 anchor

Exactly one test failed. This is the pre-existing local-only failure recorded in plan constraint C4
(issue #510), which is green in CI.

Failing node ID set (exactly one member):

```text
tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

Assertion message (verbatim):

```text
E           AssertionError: Repo file missing from bundle: .claude\state\current-session-id
E           assert WindowsPath('.claude/state/current-session-id') in [WindowsPath('.claude/agent-memory/epic-orchestrator/feedback_commit_push_memory_before_pr.md'), WindowsPath('.claude/..._unmerged_pr_deps.md'), WindowsPath('.claude/agent-memory/orchestrator/feedback_commit_push_memory_before_pr.md'), ...]
```

The message names a path under `.claude/state/`, so all three C4 conditions hold on this tree: the
failing node ID set is the single node above, the run reports exactly one failure, and the sole
assertion message names a path under `.claude/state/`.

### Skipped tests (5)

```text
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_empty_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_missing_opening_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_non_mapping_frontmatter declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_unterminated_fence declares no accessor expectation.
SKIPPED [1] tests\scripts\dev_tools\test_parallel_manifest_bash_parity.py:231: manifest_m1_yaml_parse_failure declares no accessor expectation.
```
