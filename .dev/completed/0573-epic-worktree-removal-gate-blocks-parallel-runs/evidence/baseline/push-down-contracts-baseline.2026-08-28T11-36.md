# Bundle-Parity Contract Baseline (P0-T5)

Timestamp: 2026-08-28T11-36

Task: [P0-T5]
Issue: #573
Branch: `bug/epic-worktree-removal-gate-blocks-parallel-runs-573-r2`

Command: `poetry run pytest tests/scripts/dev_tools/ -k test_bundled_claude_payload_contains_all_repo_runtime_contracts -q`

EXIT_CODE: 1

Selected-test count: exactly 1 (`1 failed, 4111 deselected`). The `-k` selector resolved to the single named test in `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`.

## As-found result — RED, attributed to issue #510

The baseline run failed. Verbatim assertion text:

```
E           AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.default.json
E           assert WindowsPath('.claude/state/powershell-batch-budget.default.json') in [WindowsPath('.claude/agent-memory/epic-orchestrator/feedback_commit_push_memory_before_pr.md'), ...]

tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:120: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
1 failed, 4111 deselected in 4.13s
```

The named path is **not** one of the seven in-scope paths. It is `.claude/state/powershell-batch-budget.default.json`, a gitignored, untracked, regenerable file written by the PowerShell change-budget `PreToolUse` hook. `git check-ignore -v` reports it matched by `.gitignore:68:.claude/state/`, and `git ls-files --error-unmatch` reports `did not match any file(s) known to git`. This is exactly the issue #510 failure class: the contract test enumerates the repo `.claude` tree without consulting `.gitignore`, so any local state file under `.claude/state/` fails the bundle-membership assertion while CI, which has no such state, is green.

## Attribution demonstration (three readings)

To prove the red is caused only by gitignored local state and by no in-scope path, the test was run three times with the `.claude/state/` contents varied. Nothing else was changed between runs.

| Run | `.claude/state/` contents | Exit | Result |
| --- | --- | --- | --- |
| 1 (as found) | `powershell-batch-budget.default.json`, `python-batch-budget.default.json` | 1 | `1 failed` naming `.claude\state\powershell-batch-budget.default.json` |
| 2 | `python-batch-budget.default.json` only | 1 | `1 failed` naming `.claude\state\python-batch-budget.default.json` |
| 3 | empty | 0 | `1 passed, 4111 deselected in 0.85s` |

Run 3 is decisive: with the gitignored budget-state files absent and **no other change**, the contract test passes. The failure is therefore fully attributable to gitignored local state (issue #510) and names no in-scope path. `.claude/state/python-batch-budget.default.json` carried a modification time of 11:32, which predates this session's first edit, so at least one of the two state files was present before any work began.

## Procedure carried forward to [P3-T2] and [P5-T6]

The PowerShell change-budget hook re-creates `.claude/state/powershell-batch-budget.default.json` whenever a `.ps1` file is written, and the Python equivalent does the same for `.py` writes. Both later parity runs therefore record two readings: the as-found reading, and a reading with `.claude/state/` emptied. Only a failure naming an in-scope path is treated as caused by this change; a failure naming a `.claude/state/**` path is attributed to this baseline.

Output Summary: RED baseline, attributed to issue #510 and **not** to this change. Exactly 1 test was selected (`1 failed, 4111 deselected`). The failure names `.claude\state\powershell-batch-budget.default.json`, a gitignored untracked local-state file, which is not one of the seven in-scope paths. A controlled third run with `.claude/state/` emptied and nothing else changed reported `1 passed, 4111 deselected in 0.85s`, proving the red is caused solely by gitignored local state. This artifact is the issue #510 attribution baseline that [P3-T2] and [P5-T6] compare against.
