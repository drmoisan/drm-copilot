# Baseline — shell test stage, with the bats executable resolved before use

Timestamp: 2026-09-09T00-00

Task: [P0-T4]

## Why the path is resolved before the stage runs

`resolve_tool` (`scripts/bash/shell_qc_lib.sh:134-141`) returns 1 when `SHELL_QC_BATS_BIN`
names anything that is not an executable. `run_test` (`:240-243`) then prints
`bats not installed; skipping shell tests.` and returns 0, exactly as its contract comment
at `:230-231` states. A skipped stage and a clean stage are therefore indistinguishable on
exit code alone, and a version string placed in that variable is not a path, so the stage
would exit 0 having executed no test. The three resolution steps below run first, and the
captured stream is additionally checked for the absence of the skip literal and for a TAP
plan line naming at least one test.

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
`ResolvedBatsPathVersion:` equals `ResolvedBatsVersion:`. All three resolution acceptance
conditions hold, so the stage was run.

## The stage

Command: `env SHELL_QC_BATS_BIN=/c/Users/DanMoisan/AppData/Local/npm-cache/_npx/cd2c4d46c11457b7/node_modules/.bin/bats bash scripts/bash/shell-qc.sh test`

Run from the worktree root
`C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d`, with
stdout and stderr captured together.

EXIT_CODE: 0

TapPlanLine: `1..411`

SkipLiteralPresent: no. `grep -cF 'bats not installed; skipping shell tests.'` over the
captured stream reports `0`, so the stage did not take the skip branch.

Lines beginning `ok`: 411
Lines beginning `not ok`: 0

BaselineLocalTestTotal: 411

`BaselineLocalTestTotal:` equals the number after `1..` in `TapPlanLine:`, and
`TapPlanLine:` matches the extended regular expression `^1\.\.[1-9][0-9]*$`. This is the
value P5-T3 compares against.

A single plan line is expected because `find_bats_test_dirs`
(`scripts/bash/shell_qc_lib.sh:104-120`) resolves only `tests/shell` in this tree —
`tests/bash` does not exist — so bats is invoked once rather than once per directory. The
captured stream carries exactly one line matching `^1\.\.`, which is consistent with that.

## Output Summary

411 tests planned, 411 `ok`, 0 `not ok`, stage exit code 0. The captured stream is 426
lines: the plan line, 411 result lines, one blank line, and thirteen lines of bats `BW01`
warnings emitted after the plan. Those warnings report that four `run` invocations inside
`tests/shell/test_shell_qc_commands.bats` exited 127 by design, because those tests point
`SHELL_QC_<TOOL>_BIN` at `/nonexistent/definitely-not-a-tool` to exercise the missing-tool
branch. They are advisory bats diagnostics, not test failures: every one of the four tests
that produced them reports `ok`, and the stage exit code is 0.
