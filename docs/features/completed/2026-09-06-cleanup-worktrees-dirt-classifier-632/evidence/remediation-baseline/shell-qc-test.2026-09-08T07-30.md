# Phase 0 baseline — bats test stage (full local suite)

Timestamp: 2026-09-08T07-30
Task: [P0-T5]
WorkingDirectory: C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-ac72d35e7980bc69d

## Binary resolution

Command: npx --yes bats --version
EXIT_CODE: 0
ResolvedBatsVersion: Bats 1.13.0
ResolvedBatsBin: /c/Users/DanMoisan/AppData/Local/npm-cache/_npx/cd2c4d46c11457b7/node_modules/.bin/bats

The resolved path was located under the npx cache and re-verified directly
(`<path> --version` printed `Bats 1.13.0` at exit 0) before being passed through the
documented `SHELL_QC_BATS_BIN` seam. No bare `wsl` invocation was used.

## Test stage

Command: env SHELL_QC_BATS_BIN=/c/Users/DanMoisan/AppData/Local/npm-cache/_npx/cd2c4d46c11457b7/node_modules/.bin/bats bash scripts/bash/shell-qc.sh test
EXIT_CODE: 0

TAP plan line: 1..404   (line 1 of the captured stream; a single plan line, because
`find_bats_test_dirs` resolved only `tests/shell` — `tests/bash` does not exist, so bats
ran once rather than once per directory)

OkCount: 404
NotOkCount: 0
BaselineLocalTestTotal: 404

Output Summary: 404 passed, 0 failed, exit 0. The local figure agrees exactly with the
CI figure recorded in the gate-ownership section of the remediation plan (run
`34194469882`: 404 tests, 0 failures), so the local route and CI are measuring the same
suite at this commit.

## Non-failing diagnostic output

The captured stream is 419 lines: the TAP plan line, 404 `ok` lines, one blank line, and
13 lines of bats `BW01` warnings. The warnings are emitted by bats for four `run`
invocations in `tests/shell/test_shell_qc_commands.bats` (lines 36, 47, 106, 113) whose
commands exit 127 deliberately — those tests drive `SHELL_QC_<TOOL>_BIN` at
`/nonexistent/definitely-not-a-tool` to exercise the missing-tool paths. `BW01` is a bats
style advisory about using `run -127`, not a failure: all four tests are among the 404
`ok` lines and the stage exit code is 0. The warnings are pre-existing and are not
introduced by this cycle.
