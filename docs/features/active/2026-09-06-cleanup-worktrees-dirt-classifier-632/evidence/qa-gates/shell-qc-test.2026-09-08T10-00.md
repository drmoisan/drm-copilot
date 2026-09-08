# Final QA loop — shell-qc test, full local stage (P5-T3)

Timestamp: 2026-09-08T10-00
WorkingDirectory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-ac72d35e7980bc69d`

Command: `env SHELL_QC_BATS_BIN=/c/Users/DanMoisan/AppData/Local/npm-cache/_npx/cd2c4d46c11457b7/node_modules/.bin/bats bash scripts/bash/shell-qc.sh test`
EXIT_CODE: 0

The bats binary is supplied through the documented `SHELL_QC_BATS_BIN` seam, resolved to the same
path P0-T5 recorded. No bare `wsl` invocation was used.

## TAP figures

TapPlanLine: `1..411`
OkCount: 411
NotOkCount: 0

BaselineLocalTestTotal: 404 (from `evidence/remediation-baseline/shell-qc-test.2026-09-08T07-30.md`)
PostChangeLocalTestTotal: 411
Delta: +7

404 + 7 = 411, which is the arithmetic the task's acceptance requires. This plan adds exactly seven
tests and removes none.

## Output Summary

411 ok, 0 not ok, plan line `1..411`, exit code 0. The stage passed.

## The seven added tests, enumerated

The delta is attributable rather than merely arithmetic. Each of the seven appears in this run's TAP
stream at the line number shown, taken from the captured output:

| Plan task | TAP line | `@test` title |
|---|---|---|
| P1-T3 | `ok 306` | `dirt_tracked_staged_only_blob: an AD entry whose content is only a staged blob is UNIQUE` |
| P1-T4 | `ok 307` | `dirt_tracked_staged_only_blob: a tracked entry whose content is on main is still CONTENT_ON_MAIN` |
| P3-T5 | `ok 308` | `dirt_tracked_probe_error_in_history: a rung-4 hard read failure is UNIQUE even when the blob is in history` |
| P3-T5 | `ok 309` | `dirt_build_artifact_empty_diff: a csproj whose diff pair is empty is UNIQUE not a build artifact` |
| P2-T5 | `ok 310` | `every guard-shaped line in the dirt library is marked and every registry row names a marked id` |
| P2-T6 | `ok 311` | `every registered guard is observable under its own neutralization` |
| P2-T7 | `ok 312` | `the eighteen pinned guard rows carry the registry kinds this plan fixes` |

Two from P1-T3 and P1-T4, three from P2-T5 through P2-T7, and two from P3-T5, which is the
composition the task states.

## Note on the `--coverage` diagnostic in the captured stream

The captured output contains a `BW01` bats advisory naming a `test --coverage` invocation that
exited 127. That text belongs to `tests/shell/test_shell_qc_commands.bats:113`, which deliberately
drives `shell-qc.sh test --coverage` with `SHELL_QC_KCOV_BIN=/nonexistent/definitely-not-a-tool` to
pin the missing-kcov path. It is an advisory attached to a **passing** test, not a failure: the run
reports 0 lines beginning `not ok`. It is unrelated to the absence of a local kcov route, which is
recorded separately in `evidence/remediation-baseline/shell-coverage.2026-09-08T07-30.md`.

Acceptance met: `EXIT_CODE:` is `0`, the `not ok` count is `0`, and
`PostChangeLocalTestTotal:` (411) equals `BaselineLocalTestTotal:` (404) plus exactly 7.
