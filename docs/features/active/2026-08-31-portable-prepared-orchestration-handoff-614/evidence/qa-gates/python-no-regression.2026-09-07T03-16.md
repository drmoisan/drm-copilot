# Python No-Regression Gate — [P2-T10]

Timestamp: 2026-09-07T12-12
Task: [P2-T10]

Command: `git status --porcelain=v1 --untracked-files=all -- .claude` (before); `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing`; the same `git status` command (after)
EXIT_CODE: 0

## Porcelain observations bracketing the run

Both observations printed no rows (0 bytes each) and were compared with `cmp`, which reported them byte-identical. This is the precondition that gitignored runtime files written under `.claude/state/`, ignored by `.gitignore` line 68 as [P0-T6] proved with `git check-ignore -v`, leave the tracked tree untouched.

## Pytest result (verbatim)

```
TOTAL                                                               15772   1121   5740    578    91%
====================== 4390 passed, 5 skipped in 26.87s =======================
```

A search for `^FAILED ` in the output returned no line, so the set of failing node identifiers is empty.

## Comparison against the [P0-T6] baseline

| Metric | [P0-T6] baseline | This run | Verdict |
| --- | --- | --- | --- |
| exit code | 0 | 0 | equal to baseline |
| passed | 4390 | 4390 | unchanged |
| failed | 0 | 0 | at most baseline |
| skipped | 5 | 5 | unchanged |
| failing node identifiers | empty set | empty set | unchanged |
| TOTAL statements / missed | 15772 / 1121 | 15772 / 1121 | unchanged |
| TOTAL branches / partial | 5740 / 578 | 5740 / 578 | unchanged |
| TOTAL coverage | 91% | 91% | at least baseline |
| porcelain observations byte-identical | yes | yes | meets requirement |

Output Summary: The pytest exit code is 0, equal to the value recorded by [P0-T6]. The failed count is 0, at most the baseline failed count, and the set of failing node identifiers is unchanged from the baseline empty set. The `TOTAL` line percentage is 91%, equal to the baseline. Both porcelain observations bracketing the run are byte-identical and empty. This plan changes no Python file, so the identical result across every metric is the expected outcome and confirms no cross-language regression.
