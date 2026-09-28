# Full Python Suite with Coverage After Phase 9 (P9-T12)

Timestamp: 2026-09-27T17-08
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/coverage-722-p9.json
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: pytest reported 1 failed, 5260 passed, 5 skipped. The terminal-table TOTAL line is 91% (16109 statements, 1115 missed, 5842 branches, 574 partial). The only FAILED node is tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts, and its failure satisfies KL-510 case (b). The P0-T18 baseline failure set is empty, so no other failure exists and the stop condition is not reached. The exit code 1 is caused solely by the KL-510 node.

KL-510: STATE-ONLY

## KL-510 evidence

The assertion message, quoted verbatim:

```text
AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-a7614a4e8c3c79cff-ef7479b3.json
```

The path's first two components are .claude and state (printed as .claude\state\ on Windows). The
count of output lines containing the literal "Bundle content differs from repo for:" is 0. The state
file is the gitignored PowerShell batch-budget state written by the batch-budget hook during
execution; CI has no such file.

## Summary lines

```text
TOTAL                                                               16109   1115   5842    574    91%
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
================= 1 failed, 5260 passed, 5 skipped in 51.57s ==================
```

## Per-file coverage of the Part B Python production files (A7, informational)

Command: poetry run python SCRATCH/py-cov-files.py SCRATCH/coverage-722-p9.json scripts/dev_tools/_blast_radius_write_intent.py scripts/dev_tools/compute_blast_radius.py scripts/dev_tools/_blast_radius_validation.py

```text
COVERAGE file=scripts/dev_tools/_blast_radius_write_intent.py LinePercent=97.98 BranchPercent=95.24
COVERAGE file=scripts/dev_tools/compute_blast_radius.py LinePercent=100.00 BranchPercent=100.00
COVERAGE file=scripts/dev_tools/_blast_radius_validation.py LinePercent=100.00 BranchPercent=100.00
```

SCRATCH denotes the executor session scratchpad directory (outside the repository).
