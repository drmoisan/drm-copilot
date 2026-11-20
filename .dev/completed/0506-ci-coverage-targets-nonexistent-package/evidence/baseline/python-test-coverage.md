# Phase 0 — Python Test and Coverage Baseline (P0-T6)

Timestamp: 2026-08-25T21-59

Task: [P0-T6]
Class: command task
Working directory: the resolved repository root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ad22fbcf94d2d5359` (resolved by P0-T2)

## Command

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing`
EXIT_CODE: 0

Output Summary:

- **Passed:** 4121
- **Skipped:** 5
- **Failed:** 0
- **Duration:** 17.72s
- **Summary line, verbatim:** `====================== 4121 passed, 5 skipped in 17.72s =======================`

**Verbatim `TOTAL` row:**

```text
TOTAL                                                               14953   1102   5492    558    91%
```

Its five numeric cells, read against the terminal reporter's branch-mode column order:

| Column | Value |
| --- | --- |
| Stmts (statements) | 14953 |
| Miss (missed statements) | 1102 |
| Branch (branches) | 5492 |
| BrPart (partial branches) | 558 |
| Cover | 91% |

**The `Cover` value of 91% is the combined statements-plus-branches ratio**, not the line
coverage percentage and not the branch coverage percentage. The terminal reporter under
`--cov-branch` computes its cover cell over statements and branches together, and its
`BrPart` cell is the partial-branch count rather than the missing-branch count. Neither of
the two policy metrics — line coverage against the 85% floor and branch coverage against the
75% floor — can be read from this row. **Those two baseline policy metrics are recorded by
P0-T8 from the JSON report** (`docs/features/active/2026-08-22-ci-coverage-targets-nonexistent-package-506/evidence/baseline/corrected-coverage-command-repro.md`).

No placeholder value is recorded anywhere in this artifact.

The five skips are pre-existing and unrelated to this work item; all five come from
`tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231` and are declared skips
for manifest fixtures that state no accessor expectation.

The exit code was captured directly from the command, not through a pipe consumer.

## Acceptance

| Condition | Result |
| --- | --- |
| `Output Summary:` records the passed count | PASS — 4121 |
| `Output Summary:` records the skipped count | PASS — 5 |
| `Output Summary:` records the verbatim `TOTAL` row | PASS |
| `TOTAL` row's statement, miss, branch, partial-branch, and cover values recorded | PASS |
| Cover value labelled as the combined statements-plus-branches ratio | PASS |
| No placeholder value accepted | PASS |

Verdict: PASS. The pre-change test suite is green.
