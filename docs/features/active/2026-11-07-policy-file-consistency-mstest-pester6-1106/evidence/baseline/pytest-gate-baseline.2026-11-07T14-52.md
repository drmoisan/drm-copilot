# Pytest Gate Baseline — Issue #1106

Timestamp: 2026-11-07T14-52
Command: PY -m pytest -n auto --cov=scripts.dev_tools.atomic_executor.qc_runner --cov=scripts.dev_tools.atomic_executor.qc_toolchain --cov=scripts.dev_tools.atomic_executor.cli_preflight --cov=scripts.dev_tools.atomic_executor.prompt_builder --cov=scripts.dev_tools.fix_all_branches_extra --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1106-pytest-baseline.json --junitxml=SCRATCH/issue-1106-pytest-baseline.xml (via SCRATCH/issue-1106-pytest.sh baseline; cwd worktree root, VIRTUAL_ENV unset, PYTHONPATH worktree root and packages/discovery-runtime/src)
EXIT_CODE: 0
Output Summary: 16179 passed, 6 skipped in 151.46s. JUnit: tests=16185 failures=0 errors=0 skipped=6. No failing tests. Run before any change in this branch (owner instruction).

## JUnit counts (SCRATCH/issue-1106-pytest-baseline.xml)

- tests: 16185
- failures: 0
- errors: 0
- skipped: 6
- Failing tests: none

## Per-module coverage (SCRATCH/issue-1106-pytest-baseline.json)

| Module | percent_covered | covered_branches | num_branches | missing_lines |
|---|---|---|---|---|
| scripts.dev_tools.atomic_executor.qc_runner | 90.91 | 14 | 18 | 152, 195, 300, 301, 478, 510, 565 |
| scripts.dev_tools.atomic_executor.qc_toolchain | 100.00 | 0 | 0 | none |
| scripts.dev_tools.atomic_executor.cli_preflight | 58.44 | 36 | 78 | 61, 70, 71, 77, 93-97, 102-106, 155, 190-192, 212, 251, 254, 270, 290-294, 300-302, 309, 310, 312-314, 317-319, 322, 324, 326, 327, 330-332, 335, 337, 339-342, 346, 353, 392 |
| scripts.dev_tools.atomic_executor.prompt_builder | 70.24 | 26 | 44 | 81, 89, 205, 212, 244, 246, 256, 257, 275, 328, 379, 383, 388-390, 411, 412, 415-418, 420-422, 424, 425, 427-429, 431, 432, 434 |
| scripts.dev_tools.fix_all_branches_extra | 100.00 | 24 | 24 | none |

Line figures (covered_lines / num_statements): qc_runner 96/103, qc_toolchain 15/15, cli_preflight 99/153, prompt_builder 92/124, fix_all_branches_extra 85/85.

Note: `cli_preflight` and `prompt_builder` are below the 85% line and 75% branch thresholds before any change. P5-T5 states the remedy (tests for uncovered behavior in their existing test files).

`SCRATCH/issue-1106-pytest-baseline.json` is retained for the P5-T5 comparison.
