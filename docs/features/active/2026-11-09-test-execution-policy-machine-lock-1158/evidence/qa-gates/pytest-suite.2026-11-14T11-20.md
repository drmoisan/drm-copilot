# Final QC: pytest Suite (P7-T5, loop restart after the #1162 merge)

Timestamp: 2026-11-14T11-20
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --cov=scripts.dev_tools.fix_all_runtime --cov=scripts.dev_tools.fix_all_branches --cov=scripts.dev_tools.fix_all_branches_extra --cov=scripts.dev_tools.atomic_executor.qc_runner --cov=scripts.dev_tools.atomic_executor.qc_runner_expectations --cov=scripts.dev_tools.atomic_executor.cli_preflight --cov=scripts.dev_tools.atomic_executor.cli_task_runtime --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1158-pytest-final.json (through SCRATCH/issue-1158-gate-pytest.sh). Collection proof: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest --collect-only -q
EXIT_CODE: 0
Output Summary: the launcher exited 0, with no queue timeout and no refusal line. The run used 24 xdist workers over 16933 items: `16927 passed, 6 skipped in 134.53s`, with 0 failed and 0 errors. The session printed no marker error or warning under the `--strict-markers --strict-config` of the project `addopts`. Each of the seven modules meets the 85% line threshold and the 75% branch threshold. No missed line of the term-missing table falls inside a line range that this branch changed against the merge base of `origin/main` and `HEAD`.

## Lane Exclusion (spec D27 live proof)

- The collect-only run through the same launcher collected 16933 tests, the same count as the gate session.
- It listed 0 node ids from `tests/scripts/dev_tools/test_pr_context_integration.py` or `tests/scripts/dev_tools/atomic_executor/test_unicode_integration.py`.
- The term-missing table lists all seven `--cov` modules.

## Coverage (JSON report)

| Module | Line | Branch | Missed lines (term-missing) |
|---|---|---|---|
| `scripts/dev_tools/fix_all_runtime.py` | 98.80% | 95.45% | 101 (unchanged line) |
| `scripts/dev_tools/fix_all_branches.py` | 100.00% | 100.00% | none |
| `scripts/dev_tools/fix_all_branches_extra.py` | 100.00% | 100.00% | none |
| `scripts/dev_tools/atomic_executor/qc_runner.py` | 93.58% | 81.82% | 157, 200, 305-306, 493, 525, 580 (unchanged lines) |
| `scripts/dev_tools/atomic_executor/qc_runner_expectations.py` | 100.00% | 97.14% | none |
| `scripts/dev_tools/atomic_executor/cli_preflight.py` | 100.00% | 98.78% | none |
| `scripts/dev_tools/atomic_executor/cli_task_runtime.py` | 98.84% | 94.23% | 211-212 (unchanged lines) |
| Total (seven modules) | 98.83% | 96.41% | |
