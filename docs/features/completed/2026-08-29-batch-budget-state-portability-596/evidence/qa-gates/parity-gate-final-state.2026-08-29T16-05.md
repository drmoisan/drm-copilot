# [P7-T13] Parity-gate final state — `.claude/state/` absence re-verification

Timestamp: 2026-08-29T22-55

Command: `pwsh -NoProfile -Command "Test-Path -LiteralPath '.claude/state'"`

Absolute prefix actually used:
`cd /c/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-add102e7ba6e997d5 && pwsh -NoProfile -Command "Test-Path -LiteralPath '.claude/state'"`

EXIT_CODE: 0

Output Summary: The command printed **`False`**, so `.claude/state/` is absent at the end of Phase 7.
The [P6-T5] parity-gate result therefore still describes the tree as it stands at the end of this
phase, and the conditional re-run branch was **not** taken. The directory was never recreated during
Phase 7 because the restart loop demanded no `.ps1` or `.py` repair edit: the only repair the loop
required was performed by Prettier on a `.ts` file, from inside a spawned process rather than through
a `Write` or `Edit` tool call.

## Output, verbatim

```
False
```

## Why the [P6-T5] result still holds

[P6-T5] removed `.claude/state/` and then ran
`poetry run pytest "tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts"`,
which passed with `1 passed` while the directory was absent. That gate's result is conditional on the
directory staying absent, because `list_scoped_files` in that test enumerates with `rglob("*")`
against the filesystem rather than the git index and applies no ignore filter, so a git-ignored
runtime state file would be enumerated as a repository runtime file and fail the parity assertion.
That behaviour is open issue #510 and is out of scope; no task in this plan edits that test file.

Since the directory is absent now, the tree state the [P6-T5] gate observed is the tree state that
persists at the end of Phase 7. **No re-run of the removal or of the pytest node was required.**

## Why the directory was not recreated

The batch-budget PreToolUse hooks are registered only under the `Write|Edit` matcher
(`.claude/settings.json:128`, with the two hook commands on lines 136 and 144), so they fire on the
executor's own `Write` and `Edit` tool calls and on nothing else. Two consequences, both confirmed by
observation during this phase rather than assumed:

- **No `.ps1` or `.py` file was written or edited during Phase 7.** Every `Write` and `Edit` tool
  call this phase made targeted a `.md` evidence artifact under this feature's `evidence/` tree.
  The [P7-T11] restart loop demanded exactly one repair, and Prettier performed it on
  `extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts`, a `.ts` file.
- **Neither write-mode command in this phase can recreate the directory.**
  `mcp__drm-copilot__run_poshqc_format` in [P7-T2] rewrites files from inside a spawned `pwsh`
  process, which the `Write|Edit` matcher never reaches. `npx prettier --write` in [P7-T6] touches
  only `.ts`, `.json`, and `.cjs` paths, and likewise runs in a spawned process. Neither is recorded
  here as a reason this task exists.

This was verified empirically at the head of each loop iteration: the [P7-T1] reset at the head of
iteration 2 ran `Test-Path -LiteralPath '.claude/state'` and it already printed `False`, after
iteration 1 had run both write-mode commands. Neither had recreated the directory.

## Note on the [P7-T1] reset command's exit code

Recorded here because it is the same underlying condition. The [P7-T1] reset command
`Get-ChildItem -Path '.claude/state' -Filter '*-batch-budget.*.json' -ErrorAction SilentlyContinue | Remove-Item -Force`
returned process exit code **1**, not 0, in both iterations. The cause is the absent directory, not a
failure of the reset: `Get-ChildItem` on a non-existent path sets `$?` to false even when
`-ErrorAction SilentlyContinue` suppresses the error from display, and `pwsh -Command` maps a
trailing false `$?` onto exit code 1.

This was isolated rather than assumed. The identical command run against an **existing** directory
(`.claude`) exits **0**, and appending `; exit 0` to the original command also yields 0. The
substantive acceptance of [P7-T1] — that zero `*-batch-budget.*.json` files remain — held in both
iterations, with the follow-up count command printing `0` each time. The condition that produced the
exit code is the same condition this task exists to confirm: `.claude/state/` is absent.

## Task verdict

**MET.** The command printed `False`, the conditional re-run branch was not taken, and the [P6-T5]
parity-gate result is confirmed to describe the end-of-phase tree.
