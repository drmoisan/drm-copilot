# [P6-T5] Bundled-payload parity gate after runtime-state removal

Timestamp: 2026-08-29T22-15

Command: two commands, run in this order:

1. `pwsh -NoProfile -Command "Remove-Item -LiteralPath '.claude/state' -Recurse -Force -ErrorAction SilentlyContinue"`
2. `poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"`

EXIT_CODE: 0

Output Summary: The parity gate passes with `1 passed` after `.claude/state/` is removed, and
`.claude/state/` was verified absent at the moment of the run. Unlike the Phase 0 capture, this pass
is **genuine, not vacuous**: `.claude/state/` existed and held one file immediately before the
removal, and the same pytest node was observed failing against that file before the removal was
performed. This satisfies the acceptance criterion at `spec.md:753`.

## Absolute-path prefix actually used

The plan states the commands in worktree-relative form. Each was executed with the working directory
set to the absolute worktree root:

```
cd C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5 && <plan command text>
```

## State of `.claude/state/` immediately BEFORE the removal

This section is the observation that distinguishes a genuine pass from the vacuous one recorded at
Phase 0. It was captured immediately before the `Remove-Item` command ran.

`Test-Path -LiteralPath '.claude/state'` returned:

```
True
```

Recursive listing, one entry found:

```
.claude\state\powershell-batch-budget.worktree-agent-add102e7ba6e997d5-10dccfd6.json  [370 bytes]
```

Verbatim content of that file:

```json
{
  "prodCap": 3,
  "testCap": 3,
  "prodFiles": [
    "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5/.claude/hooks/enforce-python-batch-budget.ps1"
  ],
  "testFiles": [
    "C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5/tests/scripts/claude-hooks/enforce-python-batch-budget.Tests.ps1"
  ]
}
```

**Which of the two conditions was observed: the directory was PRESENT and NON-EMPTY.** The plan
recorded risk R-B against Phase 0, where [P0-T17] passed only because `.claude/state/` did not exist
in the freshly created worktree and `list_scoped_files` cannot enumerate an absent directory, making
that pass vacuous. That condition does **not** apply here. The implementation phases ran the
batch-budget hook, which recreated the directory, so the removal performed by this task is
load-bearing rather than a no-op against an already-absent path.

Two incidental observations about the state file, recorded because they corroborate this feature's
own fix:

- The composed file name is `powershell-batch-budget.worktree-agent-add102e7ba6e997d5-10dccfd6.json`,
  not `powershell-batch-budget.default.json`. The session-scoping repair delivered in Phase 2 is
  therefore active in the running hook.
- The `prodFiles` and `testFiles` entries are absolute paths rooted at this worktree, confirming the
  state is scoped to this worktree rather than shared.

## Fail-before witness: the gate observed failing against that state

Recording the directory's contents establishes that the removal changed something, but it does not by
itself establish that the enumerated file was what the gate objected to. The pytest node was
therefore run once **before** the removal, so the pass recorded below is demonstrably a consequence
of the removal rather than an assertion about it.

Pre-removal run, exit code 1:

```
E           AssertionError: Repo file missing from bundle: .claude\state\powershell-batch-budget.worktree-agent-add102e7ba6e997d5-10dccfd6.json
E           assert WindowsPath('.claude/state/powershell-batch-budget.worktree-agent-add102e7ba6e997d5-10dccfd6.json') in [WindowsPath('.claude/agent-memory/epic-orchestrator/feedback_commit_push_memory_before_pr.md'), ...]

tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:125: AssertionError
=========================== short test summary info ===========================
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
============================== 1 failed in 0.21s ==============================
```

The failure names the exact state file enumerated above. This is the known issue #510 signature:
`list_scoped_files` enumerates with `rglob("*")` against the filesystem rather than the git index and
applies no ignore filter, so a git-ignored runtime state file is enumerated as a repository runtime
file. That behaviour is out of scope and **no task in this plan edits that test file**.

This pre-removal run is a diagnostic observation supporting the acceptance requirement that
`.claude/state/` was absent at the moment of the passing run. It is not an additional plan task and
produced no change to the tree.

## 1. Removal

Process exit code: 0. `Test-Path -LiteralPath '.claude/state'` immediately after the removal
returned:

```
False
```

## 2. Parity gate

Process exit code: 0.

Verbatim output:

```
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.3, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.1.0
collected 1 item

tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py .    [100%]

============================== 1 passed in 0.15s ==============================
```

The required result line, quoted verbatim:

```
1 passed in 0.15s
```

`.claude/state/` was confirmed absent both immediately before the pytest invocation and again
immediately after it returned, so the directory did not reappear during the run and the recorded
pass corresponds to the absent-state condition the acceptance requires.

## Effect of the merged-in changes to this test file

Since the plan was authored, this branch merged `origin/epic/claude-runtime-portability-integration`
as merge commit `3081e614`, and that merge modified
`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` — the very file this task runs.

The gate passes, so there is no failure to attribute. For completeness: the pre-removal failure and
the post-removal pass both arise from this feature's own runtime state file under `.claude/state/`,
which is the issue #510 mechanism, and neither is attributable to the merged-in changes. No
unrelated suite was repaired by this task.

## Re-run obligation

The plan requires this task to be re-run if any subsequent task edits a `.ps1` or `.py` file, because
such an edit causes the batch-budget PreToolUse hook to recreate `.claude/state/`. That obligation
carries into Phase 7, which is outside the scope of this phase's execution.
