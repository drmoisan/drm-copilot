# Final QC: Push-Down Contract Suite (Issue #710)

Timestamp: 2026-09-27T02-26
Command: git status --porcelain --ignored -- .claude/state; poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
EXIT_CODE: 1
Output Summary: Pass 1. 1 failed, 13 passed. The only failed node is tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts. It passed in [P0-T10] (14 passed), so the KNOWN_ISSUE_510 acceptance branch does not apply and [P5-T7] acceptance is NOT MET. Cause: a gitignored hook-state file under .claude/state, written by the enforce-powershell-batch-budget PreToolUse hook when [P2-T1] edited the canonical helper file, after the [P0-T10] baseline ran. Outcome: BLOCKED (plan Phase 5: the cause cannot be fixed within the section 2 write set).

Pass: 1
Outcome: BLOCKED

## Status Output (`git status --porcelain --ignored -- .claude/state`)

```text
!! .claude/state/
```

At [P0-T10] the same command printed nothing.

## Summary Line

```text
1 failed, 13 passed in 0.16s
```

## Failed Node IDs

- `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`

Assertion text (host path segments replaced):

```text
AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-<worktree-id>-3f02e695.json
```

## Cause Analysis

- The ignored directory `.claude/state/` holds one file, `powershell-batch-budget.worktree-agent-<worktree-id>-3f02e695.json`, last written 2026-09-27 02:11 local time.
- Its content records `prodFiles` = [the canonical `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1`, as an absolute path under `<WORKSPACE_ROOT>`] and `testFiles` = [], with `prodCap` 3 and `testCap` 3. This matches the state kept by `.claude/hooks/enforce-powershell-batch-budget.ps1`, and the write time matches the [P2-T1] Edit.
- [P0-T10] ran at 2026-09-27T02-09, before the file existed, and recorded 14 passed with an empty status output. The failure therefore appeared after the baseline and was not caused by the #710 code change. It is the #510 failure mode (a gitignored `.claude/state` file is enumerated as a repository runtime contract that the bundle lacks).
- [P5-T7] acceptance allows this failure only when it also failed in [P0-T10]. It did not, so the step fails.

## Why This Is BLOCKED

Phase 5 states: "A cause that cannot be fixed within the section 2 write set stops execution as BLOCKED." The only change that would clear the failure is removing or relocating the gitignored hook-state file under `.claude/state/`. That path is not in the section 2 write set, and the file is enforcement-hook state; changing it would alter the behavior of the batch-budget hook for this worktree. The executor did not delete or modify it.

## Plan-Revision Inputs

One of the following is needed to resume from [P5-T1] pass 2:

1. Operator or orchestrator approval to delete `.claude/state/powershell-batch-budget.worktree-agent-<worktree-id>-3f02e695.json` before pass 2 (the local cleanup that issue #510 documents; it is not a durable fix), or
2. A plan delta to [P5-T7] acceptance that also accepts `KNOWN_ISSUE_510` when the failed node is the #510 test and its assertion names only a path under `.claude/state/` that did not exist at [P0-T10], with the path recorded in the artifact.
