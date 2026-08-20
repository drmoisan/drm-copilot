# Combined Gate-Logic Coverage After the Split (Issue #486)

Timestamp: 2026-08-20T21-39
Task: [P3-T4]
Working directory: worktree root `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-af11eae4f37cb0d9d`

Command: `poetry run pytest -q --cov=scripts.dev_tools.plan_gate_discrimination --cov=scripts.dev_tools.plan_gate_coverage --cov-branch --cov-report=term-missing tests/scripts/dev_tools`

EXIT_CODE: 0

Coverage table as reported:

```
Name                                            Stmts   Miss Branch BrPart  Cover   Missing
-------------------------------------------------------------------------------------------
scripts\dev_tools\plan_gate_coverage.py            48      0     22      0   100%
scripts\dev_tools\plan_gate_discrimination.py     129      3     52      7    94%   82->exit, 84->exit, 86->exit, 88->exit, 208, 247, 276
-------------------------------------------------------------------------------------------
TOTAL                                             177      3     74      7    96%
```

## Numeric per-file and combined percentages

| Scope | Stmts | Miss | Line % | Branch | BrPart | Branch % |
| --- | --- | --- | --- | --- | --- | --- |
| `scripts/dev_tools/plan_gate_coverage.py` | 48 | 0 | **100.00%** | 22 | 0 | **100.00%** |
| `scripts/dev_tools/plan_gate_discrimination.py` | 129 | 3 | **97.67%** | 52 | 7 | **86.54%** |
| **Combined total** | 177 | 3 | **98.31%** | 74 | 7 | **90.54%** |

## Floor comparison

| Metric | [P0-T3] baseline floor | Post-split combined | Delta | Verdict |
| --- | --- | --- | --- | --- |
| Line | 98.28% | **98.31%** | **+0.03 pp** | PASS |
| Branch | 90.54% | **90.54%** | **0.00 pp** | PASS |

## Changed-line regression check

The absolute miss counts are unchanged across the split: **3 missed statements and 7 partial
branches before, 3 missed statements and 7 partial branches after.** The 7 partial branches are the
same four `->exit` Protocol-stub arrows plus the same three graceful-degradation `return` paths that
the baseline reported; only their line numbers moved with the file. The statement denominator rose
from 174 to 177 because the new module adds its own import and constant statements, all of which are
covered, which is why the combined line percentage rose slightly. No line moved from covered to
uncovered, so there is no changed-line regression.

Output Summary: **3971 passed, 5 skipped, 0 failed.** Combined gate-logic coverage is **98.31% line
/ 90.54% branch**, at or above the 98.28% / 90.54% floor recorded at [P0-T3]. The newly extracted
`scripts/dev_tools/plan_gate_coverage.py` is fully covered at 100.00% line and 100.00% branch. Both
figures also clear the uniform repository thresholds of >= 85% line and >= 75% branch.
