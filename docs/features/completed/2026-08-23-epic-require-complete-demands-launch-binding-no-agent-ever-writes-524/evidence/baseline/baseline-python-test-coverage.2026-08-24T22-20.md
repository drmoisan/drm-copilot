# Baseline — Python Tests and Coverage [P0-T6]

Timestamp: 2026-08-24T22-20

Task: [P0-T6]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ad5151536d95b2586` (repository root of the worktree)

Command: `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing`

EXIT_CODE: 0

Output Summary:

- Total line coverage: **92.61 percent** (14946 statements, 1105 missed; 13841 / 14946).
- Total branch coverage: **89.82 percent** (5490 branches, 559 partial; 4931 / 5490).
- Passed test count: **4116**.
- Failed test count: **0**.
- Skipped test count: 5 (all in `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py`, each declaring no accessor expectation; pre-existing and unrelated to this work).
- Wall time: 26.23 s.
- Reported combined `Cover` column for `TOTAL`: 91 percent. Under `--cov-branch`, `coverage.py` prints a single combined statement-plus-branch figure in the `Cover` column, so the separate line and branch percentages above are derived from the exact integer columns of the same table.

Per-file row for the target module, copied verbatim from the `term-missing` table:

```
Name                                                                Stmts   Miss Branch BrPart  Cover   Missing
scripts\dev_tools\_epic_orchestrator_state_launch_binding.py          115      3     54      3    96%   185, 217, 277
```

Derived per-file percentages for `scripts/dev_tools/_epic_orchestrator_state_launch_binding.py`:

- Line coverage: **97.39 percent** (115 statements, 3 missed; 112 / 115).
- Branch coverage: **94.44 percent** (54 branches, 3 partial; 51 / 54).
- Reported combined `Cover` column: 96 percent.
- Uncovered lines at baseline: 185, 217, 277.

Threshold check at baseline (uniform gate of `.claude/rules/quality-tiers.md`: line at or above 85 percent, branch at or above 75 percent):

| Scope | Line | Branch | Line gate | Branch gate |
| --- | --- | --- | --- | --- |
| Whole `scripts.dev_tools` package | 92.61% | 89.82% | PASS | PASS |
| `_epic_orchestrator_state_launch_binding.py` | 97.39% | 94.44% | PASS | PASS |

Test summary line, verbatim:

```
====================== 4116 passed, 5 skipped in 26.23s =======================
```

Note: the pytest configuration additionally writes `artifacts/python/lcov.info`. That is a tool-generated coverage output produced by the repository's own pytest configuration, not an evidence artifact authored by this task; no evidence is written under `artifacts/`.
