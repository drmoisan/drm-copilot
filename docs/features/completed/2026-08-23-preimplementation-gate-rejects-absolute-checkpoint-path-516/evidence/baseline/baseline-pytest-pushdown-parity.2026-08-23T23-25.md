# Baseline — Push-Down Claude Resource Parity (issue #516)

Timestamp: 2026-08-24T15-29
Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`
EXIT_CODE: 0

## Result

```text
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a96d0b5541701860e
configfile: pyproject.toml
collected 10 items
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py ..........  [100%]
============================= 10 passed in 0.14s ==============================
```

**Passed: 10. Failed: 0. EXIT_CODE 0.**

This command matches an implementation-command pattern in the very gate this item repairs, so it required the ready `artifacts/orchestration/orchestrator-state.json` to be present at execution time. That checkpoint was present and the command was allowed.

## First Attempt Failed — cause, remedy, and why the remedy is in scope

The first invocation of this command exited 1 with one failure:

```text
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.default.json
```

Diagnosis:

- The file `.claude/state/powershell-batch-budget.default.json` was created at 15:27, during this Phase 0 run, by the PowerShell batch-budget enforcement hook. Its contents were `{"prodCap":3,"testCap":3,"prodFiles":["...scratchpad/Read-Coverage.ps1"],"testFiles":[]}` — it had recorded a single throwaway coverage-reading script written to the session scratchpad directory, which lies entirely outside this worktree.
- The path is gitignored: `git check-ignore -v` reports `.gitignore:68:.claude/state/`.
- `test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerates **every** file on disk under `.claude/` (excluding only `settings.local.json` and the `agent-memory/**` subtree) and requires a bundled counterpart. A gitignored runtime state file therefore breaks it purely by existing, with no source change involved.

Remedy applied: the transient state file and its directory were removed with `Remove-Item`, after which the command was re-run and passed 10/10.

Why the removal is in scope and is not a plan deviation:

- It is the identical operation the plan already schedules at [P3-T1], whose acceptance condition is that `.claude/state/` either does not exist or contains no file whose name begins with `powershell-batch-budget.`.
- The plan's [P3-T1] text states that `.claude/state/` "does not exist in this worktree today". The removal restores exactly the state the plan assumes at Phase 0; it does not create a state the plan did not anticipate.
- The path is gitignored, so no tracked file changed and the removal cannot appear in the [P5-T1] changed-path union.
- The deleted counter had consumed one production slot for a scratchpad file outside the worktree. Removing it corrects a miscount that would otherwise have constrained Phase 2 incorrectly.

Operational consequence recorded for later phases: because the hook recreates this state file on the next governed PowerShell write, and because the parity test fails whenever the file is present, the file must be absent at the moment [P2-T5] and [P4-T5] run. Both later legs remove it immediately before invoking pytest and record that they did so.

Output Summary: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` passes 10 of 10 with EXIT_CODE 0, confirming Claude root-to-bundle content equality at baseline. The single first-attempt failure was caused by the gitignored transient file `.claude/state/powershell-batch-budget.default.json`, created during this session by the batch-budget hook and unrelated to any source change; removing it — the same operation [P3-T1] performs — restored a clean baseline.
