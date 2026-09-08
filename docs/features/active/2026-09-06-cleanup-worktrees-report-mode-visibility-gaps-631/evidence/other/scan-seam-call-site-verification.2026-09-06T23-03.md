# Scan-Seam Call-Site Verification (P7-T6)

Timestamp: 2026-09-07T14-12
Command: `grep -rn "run_report\|run_apply" tests/shell/`
EXIT_CODE: 0
Output Summary: 33 matching lines across four bats files. Every one falls into one of
the permitted categories below; none is an unseamed direct call site. Three lines invoke
a driver directly inside a `bash -c` string, and all three are the seamed helper
templates. A fourth and fifth seam were required beyond the three files the plan named
(see "Plan drift" below), and both were applied.

## Match categories (33 lines)

| Category | Count | Seamed by |
| --- | --- | --- |
| Comment or file-header prose naming a driver | 8 | n/a (not a call site) |
| `@test` title line naming a driver | 3 | n/a (not a call site) |
| `runin <scenario> "run_report"` / `"run_apply"` call-site lines | 19 | the enclosing seamed `runin()` template |
| Direct driver invocation inside a `bash -c` string | 3 | the helper template itself |

## The three direct invocation sites (all seamed)

- `tests/shell/test_cleanup_worktrees_classification.bats:48` — the `report()` template.
- `tests/shell/test_cleanup_worktrees_deletion.bats:32` — the `apply()` template.
- `tests/shell/test_cleanup_worktrees_detached.bats:40` — the `report()` template.

Each carries `CLEANUP_WT_SCAN_BIN="${SCAN}"` in its `env` prefix and
`source '${RLIB}'` in its `bash -c` string.

## Seam coverage by file (`grep -c "CLEANUP_WT_SCAN_BIN" tests/shell/*.bats`)

- `test_cleanup_worktrees_classification.bats`: 1 (`report()`)
- `test_cleanup_worktrees_deletion.bats`: 1 (`apply()`)
- `test_cleanup_worktrees_hard_failures.bats`: 1 (`runin()`)
- `test_cleanup_worktrees_detached.bats`: 2 (`report()` and `runin()`)
- `test_cleanup_worktrees_cli.bats`: 2 (the two end-to-end wrapper driver runs)
- `test_cleanup_worktrees_report_records.bats`: 1 (`rr()`)
- `test_cleanup_worktrees_scan_seam.bats`: 3 (the seam's own override/fallback tests)
- `test_cleanup_worktrees_scan_helper.bats`: 1 (`CLEANUP_WT_SCAN_GITFILE_NAME`)

No other `tests/shell/*.bats` file references a driver or the scan seam.

## Plan drift recorded

P7-T1 names three files. The tree carries five call-site files, because
`test_cleanup_worktrees_detached.bats` and the two end-to-end wrapper runs in
`test_cleanup_worktrees_cli.bats` were added by issue #630 after the plan was authored.
Both were seamed identically, because P7-T1's stated outcome is that no test falls
through to a real filesystem scan and that `classify_all_branches` is defined in every
subshell that invokes a driver. `test_cleanup_worktrees_cli.bats` runs the wrapper as a
process rather than sourcing libraries, so it needs only the `CLEANUP_WT_SCAN_BIN`
environment seam, not an `RLIB` source; the wrapper itself sources the library (P8-T1).

## Outcome-preservation cross-check (AC5)

Two sweeps compared the pre-change baseline (`git archive HEAD` of `scripts/bash` and
`tests/fixtures/cleanup_worktrees/stub-bin`) against the current tree, for every
pre-existing scenario directory under `tests/fixtures/cleanup_worktrees/scenarios/` and
`tests/fixtures/cleanup_worktrees/deletion/`, comparing both stdout and exit code:

- `run_report`: `NO_DIFF [run_report]`, exit 0.
- `run_apply`: `NO_DIFF [run_apply]`, exit 0.

Report-mode and apply-mode output are byte-identical to the pre-change baseline across
every pre-existing scenario. The four new record types and the CHILD_OF short-circuit
therefore add records without altering any existing verdict or action.
