# Python Pytest Coverage Baseline — [P0-T6]

Timestamp: 2026-09-07T11-05
Task: [P0-T6]

Command: `git status --porcelain=v1 --untracked-files=all -- .claude`; then `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing`; then `git status --porcelain=v1 --untracked-files=all -- .claude` again
EXIT_CODE: 0

The `ExpectedExitCode` field is omitted because the observed pytest exit code is 0.

## Porcelain observations bracketing the run

Both observations printed no rows (0 bytes each) and were compared with `cmp`, which reported them byte-identical:

```
(before) <empty>
(after)  <empty>
```

## Gitignore proof for runtime state

```
git check-ignore -v -- .claude/state/orchestrator-session.json
.gitignore:68:.claude/state/	.claude/state/orchestrator-session.json
```

Exit code 0, meaning the path is ignored. Runtime state written under `.claude/state/` is therefore invisible to the porcelain observation above, which is why the two observations can be byte-identical even if the run touched that directory.

## Pytest terminal summary (verbatim)

```
====================== 4390 passed, 5 skipped in 29.41s =======================
```

```
TOTAL                                                               15772   1121   5740    578    91%
```

- passed: 4390
- failed: 0
- skipped: 5
- TOTAL statements 15772, missed 1121, branches 5740, partial branches 578, coverage 91%

The 5 skips are the `manifest_m1_*` cases in `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py` line 231, each skipped because the named manifest fixture declares no accessor expectation.

Output Summary: The pytest run exited 0 with 4390 passed, 0 failed, and 5 skipped. The `term-missing` `TOTAL` line reports 15772 statements, 1121 missed, 5740 branches, 578 partial branches, and 91% coverage. The two `git status --porcelain=v1 --untracked-files=all -- .claude` observations bracketing the run are byte-identical and both empty, establishing that the run left the tracked `.claude` tree untouched. These are the floors and the comparison basis for [P2-T10]: exit code 0, failed count 0 with an empty failing-node set, and the `TOTAL` percentage 91%.
