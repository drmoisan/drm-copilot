# Final QC - Full Suite with Coverage (P5-T5)

Timestamp: 2026-09-27T09-20
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing --cov-report=json:artifacts/python/coverage.json
EXIT_CODE: 1
Output Summary:
- TOTAL row (columns `Stmts Miss Branch BrPart Cover`):
  `TOTAL                                                               15841   1114   5760    573    91%`
- PostChangeTotalCover: 91%
- Pytest result line: `================= 1 failed, 5148 passed, 5 skipped in 17.75s ==================`
- FinalFailingNodes:
  - `FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
- Failure message (recorded, not compared): `AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.worktree-agent-aeab66e09fb7ca876-451b367f.json`
- Test count reconciliation: 5148 passed + 1 failed = 5149 = 5132 baseline passes + 17 new guard tests. No test that passed at baseline regressed because of a code change.

## Comparison with BaselineFailingNodes

Baseline artifact: `docs/features/active/unused-npm-token-secret-712/evidence/baseline/baseline-pytest-coverage.2026-09-27T09-14.md` (`BaselineFailingNodes: none`).

The failing node does NOT appear in `BaselineFailingNodes:`. The P5-T5 acceptance condition "every entry of FinalFailingNodes also appears in BaselineFailingNodes" is therefore not met, and no `ExpectedExitCode:` is recorded.

No entry begins with `tests/scripts/dev_tools/test_workflow_npm_token_guard.py`.

## Classification: pre-existing, local-only (issue #510)

PreExistingCondition: yes (local-only, issue #510; classified per the caller's execution directive, not per the plan's baseline-membership rule)

- The missing file `.claude/state/python-batch-budget.worktree-agent-aeab66e09fb7ca876-451b367f.json` is written by the PreToolUse batch-budget hook. The file was created at 09:15, when the new `.py` guard module was written, after the 09:14 baseline run. That timing explains why the baseline passed.
- `git check-ignore -v` on that path printed `.gitignore:68:.claude/state/` (EXIT_CODE 0): the file is gitignored.
- `git ls-files -- .claude/state` printed no output: no file under `.claude/state/` is tracked.
- The test enumerates the filesystem rather than the git index and does not exclude `.claude/state/**`. That defect is tracked as open issue #510. A fresh CI checkout has no `.claude/state/` directory, so the condition is local-only.
- This change modifies no file under `.claude/` or `extensions/`.
- The hook state file was not deleted. Deleting it is not a durable remedy, because the hook recreates it on the next Python file edit.
