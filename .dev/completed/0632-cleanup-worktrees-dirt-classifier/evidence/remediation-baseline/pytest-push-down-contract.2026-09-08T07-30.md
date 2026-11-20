# Phase 0 baseline — push-down claude-resource contract pytest

Timestamp: 2026-09-08T07-30
Task: [P0-T10]
WorkingDirectory: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d

Command: poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
EXIT_CODE: 1

Output Summary: **1 failed, 10 passed in 0.29s.** The acceptance condition for [P0-T10] is
`EXIT_CODE: 0` with `11 passed`, and it is **not met**. The task is therefore left
unchecked in the plan. The single failure is a pre-existing environmental condition of the
local working tree that this cycle did not cause and has not yet touched: at the time of
this run the branch carries no source or test change at all, only the Phase 0 evidence
artifacts and the plan check-offs.

## The failure

```
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

```
E           AssertionError: Repo file missing from bundle: .claude\state\current-session-id
E           assert WindowsPath('.claude/state/current-session-id') in [ ... ]
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:125: AssertionError
```

## Cause, verified rather than assumed

The test's repo-side enumeration `list_scoped_files(REPO_ROOT)` walks the **filesystem**
rather than the git index, and its exclusion set covers only `.claude/settings.local.json`
and the `.claude/agent-memory/**` subtree. It does not exclude `.claude/state/**`. That
directory is gitignored and its contents are written by the local Claude runtime, so they
exist in a working tree and do not exist in a fresh CI checkout.

Verified in this task:

```
$ git check-ignore -v .claude/state/current-session-id
.gitignore:68:.claude/state/	.claude/state/current-session-id
```

Exit 0 from `git check-ignore` confirms the path is ignored by `.gitignore:68`. The file is
untracked, is not part of the branch diff, and is not a repository runtime contract.

This is tracked as **open issue #510**, "claude-resource-parity-enumerates-gitignored-state".
It is a known local-only failure that is green in CI. No new issue is filed, because #510
already covers it.

## What was not done, and why

The state file was **not** deleted to force a pass. Deleting it clears the failure only
until the next agent file edit regenerates it, so an evidence artifact claiming a
reproducible local pass would be recording an environment-conditional exit code as though
it were a property of the tree. No assumed or inferred result is recorded here.

## The ten passing tests

The other ten tests in the file passed. The property this cycle actually depends on — that
any `.claude/**` file edited in this cycle is mirrored byte-identically into
`extensions/drm-copilot/resources/claude-customizations/.claude/**` — is not exercised
adversely by this failure: the failing assertion reports an **extra** untracked file
present in the repo tree and absent from the bundle, not a mismatch between a tracked
`.claude/` file and its mirror. As of this run, Phases 0 and 1 of this plan modify no
`.claude/**` file.

## Task status

[P0-T10] is **not** checked off. Its acceptance requires `EXIT_CODE: 0` and `11 passed`;
the observed result is exit 1 with `1 failed, 10 passed`.
