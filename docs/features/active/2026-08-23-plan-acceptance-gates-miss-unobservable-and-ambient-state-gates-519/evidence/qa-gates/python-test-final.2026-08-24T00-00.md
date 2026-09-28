# Final QC — Python test suite with coverage — [P8-T4]

Timestamp: 2026-08-26T10-31
Task: [P8-T4]
Command: `poetry run pytest --cov-branch --cov-report=term-missing --cov`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65`
EXIT_CODE: 0

Output Summary: **0 failed**, **4195 passed**, 5 skipped, in 25.14s. **TOTAL coverage: 91%**, read from the `TOTAL` row of the printed `term-missing` table over 15180 statements and 5576 branches. The five skips are the declared-no-expectation parametrized cases in the parallel-manifest bash parity suite and are the same five recorded at baseline.

The exit code was captured directly with `echo "EXIT=$?"` immediately after the redirect. No pipe stands between the command and the capture.

The explicit terminal reporter is passed because the project `addopts` value supplies only an LCOV reporter (`--cov-report=lcov:artifacts/python/lcov.info`) and would otherwise print no table at all, leaving the coverage percentage this task must record unobservable.

This is the second pass of Phase 8; the restart and its cause are recorded in `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/python-format-final.2026-08-24T00-00.md`.

## The `TOTAL` row, verbatim

```text
Name                                                                Stmts   Miss Branch BrPart  Cover   Missing
---------------------------------------------------------------------------------------------------------------
TOTAL                                                               15180   1109   5576    567    91%
```

## Rows for the modules this change touches

```text
scripts\dev_tools\plan_gate_commands.py                                99      1     36      2    98%   325->327, 332
scripts\dev_tools\plan_gate_coverage.py                                48      0     22      0   100%
scripts\dev_tools\plan_gate_discrimination.py                         131      3     52      7    95%   83->exit, 85->exit, 87->exit, 89->exit, 209, 248, 277
scripts\dev_tools\plan_gate_observability.py                          139      4     62      5    96%   250, 397->395, 399, 414, 422
```

## Summary line, verbatim

```text
====================== 4195 passed, 5 skipped in 25.14s =======================
```

## The issue-#510 local failure, and why this run does not carry it

An earlier invocation of this exact command during the first Phase 8 pass exited 1 with `1 failed, 4194 passed, 5 skipped`. The single failure was `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`, and its assertion named exactly one missing path:

```text
E           AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
```

That path begins with the prefix `.claude/state/`, which is the issue-#510 signature: the test enumerates every file under the repository runtime tree and requires a bundled counterpart, and `.claude/state/python-batch-budget.default.json` is a gitignored, machine-local counter that regenerates whenever a Python authoring hook fires. Line 68 of `.gitignore` is the entry `.claude/state/`, which is why the file is untracked and why CI, whose checkout never contains it, is unaffected.

**No other missing path was reported by that test, and no other test failed.** Every path it named carried the `.claude/state/` prefix, so no genuine bundle-parity shortfall was masked. The counter file was removed before this run; `.claude/state/` was verified empty immediately before the command was issued. Only a gitignored, untracked, machine-local file was removed. No tracked file was touched and no source file was edited.

## Verdict

**PASS.** Exit code 0, `0 failed`, 4195 passed, TOTAL coverage 91%. Phase 8 proceeds to [P8-T5].
