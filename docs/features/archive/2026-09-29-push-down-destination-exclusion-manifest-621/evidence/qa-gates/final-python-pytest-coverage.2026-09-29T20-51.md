# Final Python tests with coverage — [P10-T4], Phase 10 iteration 1

Timestamp: 2026-09-29T20-51
Command: poetry run pytest --cov=scripts.dev_tools --cov=src --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
EXIT_CODE: 0
Output Summary:
- Final summary line: `5661 passed, 6 skipped in 80.21s (0:01:20)`. Failed 0, errors 0.
- Passed-count delta against [P0-T9] (`5526 passed`): +135, above the required minimum of +38.
- Failing or erroring nodes: none. The [P0-T9] baseline also had none.
- `TOTAL` row (Stmts, Miss, Branch, BrPart, Cover): `TOTAL 16936 1126 6106 584 91%`.
- `artifacts/python/coverage.json` totals: covered_lines 15810 / num_statements 16936; covered_branches 5270 / num_branches 6106; percent_covered 91.49.
- Term-missing rows for the three plan modules:
  - `scripts\dev_tools\push_down_exclusion_manifest.py 104 0 34 0 100%`
  - `scripts\dev_tools\push_down_claude_exclusion_filter.py 100 1 16 1 98% 330`
  - `scripts\dev_tools\push_down_claude_customizations.py 84 5 16 0 93% 130-139`

## Issue #510 local-only condition (plan rule 13, run note 3)

The gitignored hook state file `.claude/state/python-batch-budget.<session_id>.json` exists in this worktree (created by the batch-budget hook during Phases 3 to 4; it did not exist at [P0-T9]). While it is present, `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` fails:

Timestamp: 2026-09-29T20-50
Command: poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts" -q --no-cov
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `1 failed`. Assertion message: `AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.<session_id>.json` (raised at `tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:137`). The failure is caused by the untracked, gitignored hook state file and not by any file this plan creates or edits (issue #510).

Handling: the state file was moved to the session scratchpad (not deleted) immediately before the gated run above, and moved back immediately after it. SHA-256 before the move and after the restore: `06255d30b70a27019b63ae05a37978376ac7418f78f8d6b4197d670a8bdc926f` (identical). No hook state file was deleted.

Result: PASS.
