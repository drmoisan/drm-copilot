# P7-T3 — full bats suite (loop restart after the P7-T2 failure)

Timestamp: 2026-09-08T03-30
HostClockAtWrite: 2026-09-08T03-15Z (nominal run-timestamp scheme).
Run by: atomic-executor, directly.

Command: `env SHELL_QC_BATS_BIN=<npx bats 1.13.0> bash scripts/bash/shell-qc.sh test`
EXIT_CODE: 0

The `SHELL_QC_BATS_BIN` override is the seam `.claude/rules/shell.md` documents for supplying a
tool path. It points at the bats 1.13.0 the npm cache holds, which is the version CI runs; bats
is not otherwise on PATH in this session. This is a tool-resolution detail and does not alter
what the stage runs: `run_test` invokes the resolved bats over the same discovered test
directories either way. A run reporting `bats not installed; skipping shell tests.` would be
INCOMPLETE rather than a pass, and that message did not appear.

## Counts

- Plan line: `1..390`
- `ok` lines: 390
- `not ok` lines: 0

Baseline (P0-T4, `evidence/baseline/shell-qc-test.2026-09-08T00-55.md`): 343 tests, 0 failures.
Delta: 390 - 343 = **47**, which exceeds the required minimum of 45.

The 47 decompose as the plan predicts, plus the two remediation tests:

| Suite | Tests added |
|---|---|
| `tests/shell/test_cleanup_worktrees_dirt_classify.bats` | 19 |
| `tests/shell/test_cleanup_worktrees_dirt_clear.bats` | 11 |
| `tests/shell/test_cleanup_worktrees_dirt_regression.bats` | 11 |
| `tests/shell/test_cleanup_worktrees_cli.bats` | 4 |
| `tests/shell/test_cleanup_worktrees_dirt_clear.bats` (P7 remediation pair) | 2 |
| Total | 47 |

The two remediation tests appear in this run as:

```
ok 291 dirt_clear_all_disposable through the wrapper: --apply --clear-disposable arms the clearing sequence
ok 292 dirt_clear_all_disposable through the wrapper: apply mode without the flag clears nothing
```

## A note on the BW01 lines in the captured output

The captured output contains bats-core `BW01` advisory lines emitted from
`tests/shell/test_shell_qc_commands.bats` around lines 106 and 113. Those are bats warning us
that a `run` command exited 127; the exit is deliberate in those two tests, which drive
`shell-qc.sh test --coverage` with `SHELL_QC_KCOV_BIN=/nonexistent/definitely-not-a-tool` to
assert the missing-tool path. Both tests report `ok`. The advisory is not a failure and there is
no `not ok` line anywhere in the output.

Output Summary: `EXIT_CODE: 0`, 390 tests, 0 failures, no `not ok` line, delta over baseline 47.
