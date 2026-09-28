# Final QC — full bats stage

Timestamp: 2026-09-08T07-48

Task: [P8-T3] of `remediation-plan.2026-09-08T05-00.md`

Command, with the bats path recorded in [P0-T5] resolved:

```
env SHELL_QC_BATS_BIN=C:/Users/DanMoisan/AppData/Local/npm-cache/_npx/cd2c4d46c11457b7/node_modules/bats/bin/bats bash scripts/bash/shell-qc.sh test
```

EXIT_CODE: 0

## TAP figures

TAP plan line: `1..404`
Lines beginning `ok`: 404
Lines beginning `not ok`: 0

The `ok` count equals the plan line's upper bound.

## Delta against the recorded baseline

BaselineLocalTestTotal: 390

That line is reproduced verbatim from
`evidence/remediation-baseline/shell-qc-test.2026-09-08T05-30.md`, written by [P0-T5].

Delta: 404 − 390 = **14**

The delta is taken against the observed local baseline that [P0-T5] recorded, not against
the CI figure, so a local-versus-CI difference in suite enumeration could not make this
condition unsatisfiable. In this cycle the two figures happen to agree at 390.

## The 14 tests this plan adds

| Task | Count | Suite |
|---|---:|---|
| [P2-T2] | 2 | `test_cleanup_worktrees_dirt_failclosed.bats` (new) |
| [P3-T2] | 2 | `test_cleanup_worktrees_dirt_classify.bats` |
| [P4-T3] | 2 | `test_cleanup_worktrees_dirt_classify.bats` |
| [P5-T4] | 3 | `test_cleanup_worktrees_dirt_failclosed.bats` |
| [P6-T4] | 2 | `test_cleanup_worktrees_dirt_failclosed.bats` |
| [P6-T5] | 1 | `test_cleanup_worktrees_dirt_clear.bats` |
| [P7-T4] | 1 | `test_cleanup_worktrees_dirt_regression.bats` |
| [P7-T5] | 1 | `test_cleanup_worktrees_dirt_classify.bats` |
| **Total** | **14** | |

[P6-T6] modified an existing test rather than adding one, so it contributes 0 to the delta.

## Skip check

The artifact does not record the message `bats not installed; skipping shell tests.` — that
string does not appear in the run output. This is a real run rather than the skip path.

The run emitted four `BW01` bats warnings from `tests/shell/test_shell_qc_commands.bats`,
each reporting that a deliberately-nonexistent tool path under a `SHELL_QC_<TOOL>_BIN`
override exited 127. These are the intended inputs of the missing-tool tests; they are
advisory warnings, not failures, and every affected test reports `ok`. The same four appeared
in the [P0-T5] baseline.

Output Summary: The full local bats stage passes with exit code 0, plan line `1..404`, 404
`ok` lines and 0 `not ok` lines. The delta against the [P0-T5] baseline is exactly 14, the
number of tests this plan adds, so no pre-existing test was removed or renamed and no added
test failed to register.
