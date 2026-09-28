# Final QA — full local shell test stage

Timestamp: 2026-09-09T02-30
Task: [P5-T3]
Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`

## Why the path is resolved in this task

`resolve_tool` (`scripts/bash/shell_qc_lib.sh:134-141`) returns 1 when `SHELL_QC_BATS_BIN`
names anything that is not an executable, and `run_test` (`:240-243`) then prints
`bats not installed; skipping shell tests.` and **returns 0**. A stage that skipped every
test is indistinguishable from a clean pass on exit code alone, so the three-step
resolution is repeated here against the tree as it stands now rather than cited from
P0-T4's recorded value.

## Resolution

Command: `npx --yes bats --version`
ResolvedBatsVersion: `Bats 1.13.0`

Command: `npm exec --yes --package=bats -- bash -c 'command -v bats'`
ResolvedBatsPath: `/c/Users/DanMoisan/AppData/Local/npm-cache/_npx/cd2c4d46c11457b7/node_modules/.bin/bats`

Command: `test -x /c/Users/DanMoisan/AppData/Local/npm-cache/_npx/cd2c4d46c11457b7/node_modules/.bin/bats`
ResolvedBatsExecutable: 0

Command: `/c/Users/DanMoisan/AppData/Local/npm-cache/_npx/cd2c4d46c11457b7/node_modules/.bin/bats --version`
ResolvedBatsPathVersion: `Bats 1.13.0`

`ResolvedBatsPath:` is a single absolute path, `ResolvedBatsExecutable:` is `0`, and
`ResolvedBatsPathVersion:` equals `ResolvedBatsVersion:`.

## Stage

Command: `env SHELL_QC_BATS_BIN=/c/Users/DanMoisan/AppData/Local/npm-cache/_npx/cd2c4d46c11457b7/node_modules/.bin/bats bash scripts/bash/shell-qc.sh test`

EXIT_CODE: 0

TapPlanLine: `1..417`

`ok` count: 417
`not ok` count: 0

The captured combined output does **not** contain the literal
`bats not installed; skipping shell tests.` — a `grep -cF` for it over the captured stream
reports `0`, so the stage executed tests rather than taking the skip path.

A single plan line is expected because `find_bats_test_dirs`
(`scripts/bash/shell_qc_lib.sh:104-120`) resolves only `tests/shell` in this tree;
`tests/bash` does not exist, so bats is invoked once rather than once per directory.

PostChangeLocalTestTotal: 417

## Delta attribution

BaselineLocalTestTotal (P0-T4): 411
PostChangeLocalTestTotal: 417
Delta: +6

This cycle adds exactly six tests and removes none. The six added `@test` titles, each
observed passing in this run:

| TAP no. | Title | Added by |
|---:|---|---|
| 299 | `every disposable verdict is backed by a git read of every location holding that entry's content` | P1-T5 |
| 300 | `every classifier-relevant status-code class is covered by a checked-in dirt scenario` | P1-T5 |
| 312 | `dirt_index_and_worktree_delta: an MM entry whose working-tree content is on main is UNIQUE` | P1-T4 |
| 313 | `dirt_index_and_worktree_delta: an MM entry whose working-tree blob is in history is UNIQUE` | P1-T4 |
| 314 | `dirt_index_and_worktree_delta: a UU entry whose working-tree content is on main is UNIQUE` | P1-T4 |
| 315 | `dirt_index_and_worktree_delta: the M-space control entry in the same fixture is still CONTENT_ON_MAIN` | P1-T4 |

One existing test was renamed by P3-T3, which changes no count:

| TAP no. | Title after rename | Title before |
|---:|---|---|
| 318 | `every marker id is pinned by kind and the two dual-row lines are pinned by pair` | `the eighteen pinned guard rows carry the registry kinds this plan fixes` |

411 + 6 = 417, which is the number after `1..` in `TapPlanLine:`, so the delta is
attributable rather than merely arithmetic.

## Output Summary

Stage passed: exit 0, plan line `1..417`, 417 `ok`, 0 `not ok`, skip literal absent, path
resolution verified independently at `Bats 1.13.0`. Test total moved from 411 to 417,
accounted for by the six tests this cycle adds.
