# Fail-before exception dossier for the shell QC bats tests (P1-T8, rule 18)

Timestamp: 2026-10-16T23-44
Command: sh SCRATCH/tools/run-cr.sh cr-shell-static
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: After S4 (P1-T7) and before S1 to S3, the bats suite declares all eight new tests (SHELL-NEW-TESTS-MISSING: 0) and both updated nounset assertions (SHELL-NOUNSET-ASSERTIONS-UPDATED: 2), while scripts/bash/shell_qc_lib.sh still has two non-recursive bats invocations (SHELL-RECURSIVE-INVOCATIONS: 0, SHELL-NONRECURSIVE-INVOCATIONS: 2) and no check_coverage_threshold function or wiring (SHELL-THRESHOLD-FUNCTION: 0, SHELL-THRESHOLD-WIRING: 0). EXIT_CODE_COMPUTED: 1 as expected.

WhyFailingRunImpossible: The worktree isolation guard refuses Bash command text containing the tokens bash, wsl, or bats, so the bats suite cannot be executed in this worktree. CI runs the suite in the `shell-coverage / Shell Coverage (Bats + kcov)` job, where the post-change run is observed (P7-T4).

## Alternative proof

Each of the ten S4 assertions fails against the unchanged `scripts/bash` files, for the reason stated:

1. `test fails when a bats child sources a nounset library inside bash -c` (changed assertion `nounset-stub ran: --recursive tests/shell`): the stub echoes its argv; the unchanged `run_test` invocation `"$bats_bin" "$test_dir"` passes no `--recursive`, so the argv is `tests/shell` and the pattern does not match.
2. `test passes when a bats child resets nounset after sourcing` (changed assertion `nounset-reset-stub ran: --recursive tests/shell`): same cause as item 1.
3. `test passes --recursive to bats for each test directory`: the bats stub prints `bats tests/shell`, not `bats --recursive tests/shell`, because the unchanged invocation passes no flag (SHELL-NONRECURSIVE-INVOCATIONS: 2).
4. `test --coverage passes --recursive to bats under kcov`: the kcov stub prints `... stub-bin/bats tests/shell`, not `stub-bin/bats --recursive tests/shell`, for the same reason in `run_test_coverage`.
5. `check_coverage_threshold fails below the default 85 percent minimum`: `check_coverage_threshold` is not defined in the library (SHELL-THRESHOLD-FUNCTION: 0), so bash reports `command not found` and returns status 127, not 1, and the expected message is not printed.
6. `check_coverage_threshold passes when coverage equals the minimum`: status 127 instead of 0 (undefined function).
7. `check_coverage_threshold passes when coverage is above the minimum`: status 127 instead of 0 (undefined function).
8. `check_coverage_threshold rejects a minimum that is not an integer`: status 127 instead of 2 (undefined function).
9. `check_coverage_threshold rejects a minimum above 100`: status 127 instead of 2 (undefined function).
10. `check_coverage_threshold prints nothing and passes when cov.xml is missing`: status 127 and a `command not found` line instead of status 0 with empty output (undefined function).

## CR output

```
RUN-CR: cr-shell-static
SHELL-LINES: scripts/bash/shell_qc_lib.sh | 394
SHELL-LINES: scripts/bash/shell-qc.sh | 103
SHELL-LINES: tests/shell/test_shell_qc_commands.bats | 265
SHELL-RECURSIVE-INVOCATIONS: 0
SHELL-NONRECURSIVE-INVOCATIONS: 2
SHELL-THRESHOLD-FUNCTION: 0
SHELL-THRESHOLD-WIRING: 0
SHELL-THRESHOLD-DEFAULT-85: 0
SHELL-USAGE-THRESHOLD-LINE: 0
SHELL-NOUNSET-ASSERTIONS-UPDATED: 2
SHELL-NEW-TESTS-MISSING: 0
SHELL-NESTED-FILE: helpers/codex_web_setup_common.bash
SHELL-NESTED-BATS-FILES: 0
SHELL-TESTS-BASH-DIR-EXISTS: False
SHELL-LINES-OVER-500: 0
SHELL-CRLF-FILES: 0
SHELLCHECK-EXIT: 0
SHFMT-EXIT: 0
SHELL-LOCAL-LINT: ran=2 | failing=0 | informational=False
EXIT_CODE_COMPUTED: 1
```
