# Final QA — Pytest Targeted Coverage of the Blast-Radius Modules (P6-T6)

Timestamp: 2026-09-27T15-40

Iteration: 1

Task start: 2026-09-27T15:40:42 (local)

Command: poetry run pytest tests --cov=scripts.dev_tools._blast_radius_conflicts --cov=scripts.dev_tools._blast_radius_glob --cov=scripts.dev_tools._blast_radius_extraction --cov=scripts.dev_tools._blast_radius_validation --cov=scripts.dev_tools.compute_blast_radius --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json

EXIT_CODE: 1

Command: poetry run python `<scratchpad>`/coverage_totals.py

EXIT_CODE: 0

Pytest summary:

```
TOTAL                                             394      1    138      1    99%
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
================= 1 failed, 5173 passed, 6 skipped in 11.84s ==================
```

Helper output:

```
GENERATED_AT=2026-09-27T15:40:55.160312
TOTAL_LINE=393/394=99.75
TOTAL_BRANCH=137/138=99.28
FILE _blast_radius_conflicts.py line=100.00 branch=100.00
FILE _blast_radius_extraction.py line=100.00 branch=100.00
FILE _blast_radius_glob.py line=98.28 branch=96.43
FILE _blast_radius_validation.py line=100.00 branch=100.00
FILE compute_blast_radius.py line=100.00 branch=100.00
```

## Issue #510 allowance

- Excused node ID: tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
- Condition (a): the FAILED line node ID equals the node ID named in Execution Conventions, character for character. Holds.
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
| Targeted TOTAL_LINE | >= 85.00 | 99.75 (P0-T24 99.75) | pass |
| Targeted TOTAL_BRANCH | >= 75.00 | 99.28 (P0-T24 99.28) | pass |
| _blast_radius_conflicts line/branch | not lower than 100.00/100.00 | 100.00/100.00 | pass |
| _blast_radius_extraction line/branch | not lower than 100.00/100.00 | 100.00/100.00 | pass |
| _blast_radius_glob line/branch | not lower than 98.28/96.43 | 98.28/96.43 | pass |
| _blast_radius_validation line/branch | not lower than 100.00/100.00 | 100.00/100.00 | pass |
| compute_blast_radius line/branch | not lower than 100.00/100.00 | 100.00/100.00 | pass |
| Failed node-ID set after #510 excusal | subset of the P0-T24 failed set (empty) | empty | pass |
| Pytest EXIT_CODE 1 | acceptable only when the excused test is the sole failure | sole failure is the excused test | pass |

Output Summary: PASS (iteration 1). Targeted line coverage 99.75% (393/394), branch coverage 99.28% (137/138); every per-module value equals its P0-T24 baseline. 5173 passed, 6 skipped, 1 failed (excused under the issue #510 allowance, all four conditions met).
