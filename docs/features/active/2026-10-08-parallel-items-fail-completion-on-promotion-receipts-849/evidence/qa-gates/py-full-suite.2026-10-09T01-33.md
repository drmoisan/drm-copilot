# Final QA Python Full Suite (Issue #849)

Timestamp: 2026-10-10T10-38
Task: P6-T5
Command: poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-report=json:docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-full-coverage.2026-10-09T01-33.json
EXIT_CODE: 0

## Summary line (verbatim)

```text
================= 6870 passed, 6 skipped in 69.19s (0:01:09) ==================
```

- Collected: 6876 items
- Passed: 6870; skipped: 6; failed: 0
- Failed-node-ID set: {} (equals RB_PY_FULL_FAILED = {}). Met.

## Merge adjustment

After Phase 5 the orchestrator merged origin/main into the branch (merge commit baf63356b, first parent c4e1c6797). This is expected under the run's concurrency instruction.

Command: git diff --name-status c4e1c6797 baf63356b -- tests extensions/drm-copilot/test extensions/drm-copilot/src scripts .claude/lib

```text
M	.claude/lib/ci-gate/Invoke-CiGateParser.ps1
A	tests/fixtures/cleanup_worktrees/scenarios/scan_roots_backslash/worktree-list.out
A	tests/fixtures/cleanup_worktrees/scenarios/scan_roots_drive_relative/worktree-list.out
M	tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1
A	tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py
M	tests/shell/test_cleanup_worktrees_scan_roots.bats
```

The only path in the Python full suite is `tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py` (added). No `scripts/` source path changed.

Command: poetry run pytest --collect-only -q tests/scripts/dev_tools/test_ci_gate_epic_child_contracts.py
EXIT_CODE: 0
Output summary line (verbatim):

```text
26 tests collected in 0.06s
```

- MERGE_ADDED_PY: 26

## Passed-count acceptance (merge-adjusted)

- Expected passed = RB_PY_FULL_PASSED + 23 + MERGE_ADDED_PY = 6821 + 23 + 26 = 6870
  (23 = 7 waivers + 5 parity + 11 skill-contract cases)
- Observed passed: 6870. Met.
- Cross-check on collection: baseline collected 6827; 6827 + 23 + 26 = 6876 = observed collected.

## TOTAL row (verbatim)

```text
TOTAL                                                                 17633   1101   6364    509    92%
```

Module row for reference (verbatim):

```text
scripts\dev_tools\_orchestrator_state_issue_adoption.py                 116      0     48      0   100%
```

## JSON totals

JSON file: `docs/features/active/2026-10-08-parallel-items-fail-completion-on-promotion-receipts-849/evidence/qa-gates/py-full-coverage.2026-10-09T01-33.json` (0 absolute host path matches in the file).

```json
{"covered_lines": 16532, "num_statements": 17633, "percent_covered": 92.24069675376089, "percent_covered_display": "92", "missing_lines": 1101, "excluded_lines": 590, "percent_statements_covered": 93.75602563375489, "percent_statements_covered_display": "94", "num_branches": 6364, "num_partial_branches": 509, "covered_branches": 5603, "missing_branches": 761, "percent_branches_covered": 88.04211187932118, "percent_branches_covered_display": "88"}
```

- Line: covered_lines / num_statements = 16532 / 17633 = 93.756% (P0-T9: 16529 / 17630 = 93.755%). Not below baseline. Met.
- Branch: covered_branches / num_branches = 5603 / 6364 = 88.042% (P0-T9: 5601 / 6362 = 88.038%). Not below baseline. Met.

Output Summary: Exit 0; 6870 passed, 6 skipped, 0 failed; failed set {} equals RB_PY_FULL_FAILED. Passed count equals 6821 + 23 + MERGE_ADDED_PY (26) = 6870. scripts.dev_tools totals: line 93.756% (16532/17633), branch 88.042% (5603/6364); neither below P0-T9 (93.755%, 88.038%).
