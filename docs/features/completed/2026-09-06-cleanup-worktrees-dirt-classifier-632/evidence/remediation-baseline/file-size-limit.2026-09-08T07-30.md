# Phase 0 baseline — file size limit and stub digest

Timestamp: 2026-09-08T07-30
Task: [P0-T8]
WorkingDirectory: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d
Limit: 500 lines. No production, test, or reusable shell file may reach it
(`.claude/rules/shell.md`; `.github/instructions/general-code-change.instructions.md` 4.1).

Command: wc -l scripts/bash/cleanup_worktrees_dirt_lib.sh scripts/bash/cleanup_worktrees_lib.sh scripts/bash/cleanup_worktrees_actions_lib.sh scripts/bash/cleanup-worktrees.sh tests/shell/test_cleanup_worktrees_dirt_classify.bats tests/shell/test_cleanup_worktrees_dirt_failclosed.bats
EXIT_CODE: 0

```
   463 scripts/bash/cleanup_worktrees_dirt_lib.sh
   496 scripts/bash/cleanup_worktrees_lib.sh
   437 scripts/bash/cleanup_worktrees_actions_lib.sh
   187 scripts/bash/cleanup-worktrees.sh
   377 tests/shell/test_cleanup_worktrees_dirt_classify.bats
   158 tests/shell/test_cleanup_worktrees_dirt_failclosed.bats
  2118 total
```

## Headroom to 500

| File | Lines | Headroom to 500 |
|---|---:|---:|
| `scripts/bash/cleanup_worktrees_dirt_lib.sh` | 463 | 37 |
| `scripts/bash/cleanup_worktrees_lib.sh` | 496 | 4 |
| `scripts/bash/cleanup_worktrees_actions_lib.sh` | 437 | 63 |
| `scripts/bash/cleanup-worktrees.sh` | 187 | 313 |
| `tests/shell/test_cleanup_worktrees_dirt_classify.bats` | 377 | 123 |
| `tests/shell/test_cleanup_worktrees_dirt_failclosed.bats` | 158 | 342 |

`scripts/bash/cleanup_worktrees_dirt_lib.sh` is **463**, as the plan's constraints section
states. `scripts/bash/cleanup_worktrees_lib.sh` is **496**, four lines from the cap; it is
excluded from modification by this cycle, and that 4-line headroom is the constraint the
deferred findings F7 and F9 are blocked on.

## Stub digest

Command: md5sum tests/fixtures/cleanup_worktrees/stub-bin/git
EXIT_CODE: 0
StubDigest: a701f6cec32dc230b60d362f6266612b

[P5-T5] compares against this value to show the cycle added no stub arm. The plan's
constraints forbid introducing any new subcommand that writes the index or the object
database, and forbid adding one to this stub.

Output Summary: All six measured files are under the 500-line cap. The classifier library
is at 463 with 37 lines of headroom; `cleanup_worktrees_lib.sh` is at 496 with 4 and is out
of scope. StubDigest recorded as a701f6cec32dc230b60d362f6266612b.
