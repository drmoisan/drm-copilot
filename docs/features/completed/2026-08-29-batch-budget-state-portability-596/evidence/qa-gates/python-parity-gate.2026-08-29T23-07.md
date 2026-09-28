# Bundled Claude payload parity gate, with pre-removal state capture

Timestamp: 2026-08-30T01-31

Task: [P4-T4]
Plan: `docs/features/active/2026-08-29-batch-budget-state-portability-596/remediation/2026-08-29T23-07/remediation-plan.md`

Every command was executed with the working directory set to the absolute worktree path
`C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5`. The plan's
command text is worktree-relative and is reproduced verbatim below; the absolute prefix was
supplied by `cd` into that path before each invocation.

## Step 1 — pre-removal capture (the anti-vacuity record)

Command: `pwsh -NoProfile -Command "Get-ChildItem -Path '.claude/state' -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }"`

EXIT_CODE: 0

Output, verbatim:

```
none
```

The command produced no output. `none` is written above as the plan's literal for an empty
list.

A second, wider walk was taken in the same step so the record covers directories as well as
files, because a file-only walk cannot distinguish an empty directory from an absent one:

Command: `pwsh -NoProfile -Command "Get-ChildItem -Path '.claude/state' -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }"`

EXIT_CODE: 0. Output: no output.

A direct existence probe was also taken:

Command: `pwsh -NoProfile -Command "Test-Path -LiteralPath '.claude/state'"`

Output: `False`.

**What was actually present before removal: nothing. The `.claude/state` directory did not
exist in this worktree at all.**

This capture is taken by a filesystem walk rather than from `git status --porcelain`, because
`.claude/state/` is gitignored and porcelain status cannot see it. Recording the walk is what
keeps this gate from passing vacuously: without it, an empty `.claude/state/` and a populated
one would produce identical downstream evidence.

### Cross-reference against the [P0-T17] pre-remediation inventory

`docs/features/active/2026-08-29-batch-budget-state-portability-596/evidence/remediation-baseline/claude-state-inventory.2026-08-29T23-07.md`
recorded `Test-Path` as `False` and the file list as `none` before any edit in this plan.

| Path present before removal | Also in the [P0-T17] inventory | Disposition |
| --- | --- | --- |
| *(none)* | n/a | The pre-removal list is empty, so there is no path to match against the inventory. |

The two captures agree: the directory was absent at [P0-T17] and still absent at [P4-T4]. No
state file was created by this remediation in this worktree, and none predated it here.

### Why the directory was never created in this worktree

The plan's [P0-T17] prediction was that the Phase 0 `.md` evidence writes would not create the
directory, because the batch-budget hook returns at its extension scope filter before the state
path is composed. That prediction held, and a second mechanism reinforced it: the batch-budget
counter that governed the `.ps1` edits in Phases 1 and 2 is not stored in this worktree. An
inspection of the session repository found the live counter at

```
C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-29T15-07\.claude\state\powershell-batch-budget.default.json
```

which is outside this worktree, shared with other concurrent worktrees, and out of scope for
this remediation. It was inspected read-only and **was not removed or modified**. Only the
gitignored runtime state under the target worktree is within this task's remit, and there was
none.

**Consequence stated plainly: the removal in Step 2 removed nothing in this worktree.** The
falsifiable content of this task is therefore carried by the pytest node in Step 4, not by the
removal. Had a state file been present, the removal would have been load-bearing; the capture
above is the evidence that it was not.

## Step 2 — removal

Command: `pwsh -NoProfile -Command "Remove-Item -LiteralPath '.claude/state' -Recurse -Force -ErrorAction SilentlyContinue"`

EXIT_CODE: 1
ExpectedExitCode: 1

Output: no output. The process exit code is not asserted, for the reason recorded in [P1-T1]:
a `-ErrorAction SilentlyContinue` cmdlet against an absent path writes no error record yet
still leaves `pwsh` with a non-zero exit code, so an exit-0 assertion would be unsatisfiable in
exactly the already-clean state this task exists to reach. The exit code of 1 is consistent
with the Step 1 finding that the target did not exist.

## Step 3 — removal confirmation

Command: `pwsh -NoProfile -Command "Test-Path -LiteralPath '.claude/state'"`

EXIT_CODE: 0

Output, verbatim:

```
False
```

The confirmation prints `False`, which is the stated acceptance condition.

## Step 4 — the parity gate

Command: `poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"`

EXIT_CODE: 0

Output, verbatim:

```
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.3, pluggy-1.6.0
rootdir: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-add102e7ba6e997d5
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.1.0
collected 1 item

tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py .    [100%]

============================== 1 passed in 0.13s ==============================
```

Asserted result line, verbatim: `1 passed in 0.13s`.

This node asserts presence and identical content for every repository `.claude/**` file in the
bundled payload, except `settings.local.json` and `.claude/agent-memory/**`. It is what makes
the mirror edits of [P1-T5] and [P2-T5] mandatory rather than optional, and its pass confirms
both mirrors carry the B-1 fix.

No coverage flag was passed. This node is a payload-parity gate, not a coverage gate, and the
acceptance is the pass count.

## Why the removal is part of this task at all

The test's file enumeration walks the filesystem rather than the git index and applies no
ignore filter, so a gitignored runtime state file under `.claude/state/` would be enumerated as
a repository runtime file and would fail the parity assertion against the bundled payload,
which carries no such file. That behaviour is open issue #510, is out of scope here, and no
task in this plan edits that test file. In this worktree the condition did not arise, because
no state file existed.

## Output Summary

`.claude/state` did not exist in this worktree before removal: `Test-Path` printed `False` and
both the file-only and the force-recursive walks produced no output, so the pre-removal list is
`none` and matches the empty [P0-T17] inventory exactly. The removal command exited 1 against
an absent target and removed nothing. The confirmation command printed `False`. The parity
pytest node exited 0 with `1 passed`. The live batch-budget counter governing this session was
located in the session repository at
`C:\Users\DanMoisan\repos\drm-copilot-wt\2026-08-29T15-07\.claude\state\powershell-batch-budget.default.json`,
outside this worktree; it was inspected read-only and left untouched. All three stated
acceptance conditions are met, and the pre-removal capture records that the removal itself was
a no-op here rather than leaving that unstated.
