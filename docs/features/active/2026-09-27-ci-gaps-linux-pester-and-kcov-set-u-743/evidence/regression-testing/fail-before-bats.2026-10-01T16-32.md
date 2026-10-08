# Fail-Before bats Run (P1-T8) [expect-fail]

Timestamp: 2026-10-01T16-32
Command: npx --yes bats --print-output-on-failure tests/shell/test_shell_qc_commands.bats
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: `1..22`; 20 ok, 2 not ok. The two failures are `test fails when a bats child sources a nounset library inside bash -c` (assertion `[ "$status" -ne 0 ]` failed; output `nounset-stub ran: tests/shell`) and `kcov_trace_env.sh sets the kcov PS4 format` (the trace-env file does not exist yet). `test passes when a bats child resets nounset after sourcing` and every P0-T18 baseline test in this file are `ok`.

State at run time: `scripts/bash/shell_qc_lib.sh` unmodified; `scripts/bash/kcov_trace_env.sh` absent.

P1-T7 verification (same pass):

Command: git diff --numstat 41217012d31d35c2ee33a50be50684affd2f5f43 -- tests/shell/test_shell_qc_commands.bats
EXIT_CODE: 0
Output Summary: `34	0	tests/shell/test_shell_qc_commands.bats` (deleted-line column 0). The first 169 lines are byte-identical to MERGE_BASE (`cmp` exit 0).

Command: grep -n -F '@test "' tests/shell/test_shell_qc_commands.bats
EXIT_CODE: 0
Output Summary: the last three `@test` lines are line 171 `test fails when a bats child sources a nounset library inside bash -c`, line 183 `test passes when a bats child resets nounset after sourcing`, line 193 `kcov_trace_env.sh sets the kcov PS4 format`.

TAP output (BW01 warning block omitted; host prefix replaced by `<REPO_ROOT>`):

```
1..22
ok 1 check prints the no-scripts skip message and exits 0
ok 2 check exits 127 with the five-line block when shfmt is missing
ok 3 check exits 127 with the block when shellcheck is missing
ok 4 check returns the shfmt exit code when only shfmt fails
ok 5 check returns the shellcheck exit code when only shellcheck fails
ok 6 check returns the maximum exit code when both tools fail
ok 7 check invokes shfmt once over the full list and shellcheck once per file
ok 8 format passes -w to shfmt
ok 9 test prints the exact no-test-directory skip marker and exits 0
ok 10 test prints the exact bats-missing skip marker and exits 0
ok 11 test --coverage exits 127 with the coverage message when bats is missing
ok 12 test --coverage exits 127 with message and block when kcov is missing
ok 13 test --coverage builds the kcov argv and merges the runs
ok 14 extract_cobertura_line_rate reads the fixture line-rate
ok 15 print_coverage_summary formats the fixture line-rate to one decimal percent
ok 16 --help prints usage and exits 0
ok 17 help subcommand prints usage and exits 0
ok 18 an unknown subcommand prints usage and exits 2
ok 19 an unknown test flag exits 2
not ok 20 test fails when a bats child sources a nounset library inside bash -c
# (in test file tests/shell/test_shell_qc_commands.bats, line 178)
#   `[ "$status" -ne 0 ]' failed
# Last output:
# nounset-stub ran: tests/shell
ok 21 test passes when a bats child resets nounset after sourcing
not ok 22 kcov_trace_env.sh sets the kcov PS4 format
# (in test file tests/shell/test_shell_qc_commands.bats, line 199)
#   `[ "$status" -eq 0 ]' failed
# Last output:
# bash: <REPO_ROOT>/scripts/bash/kcov_trace_env.sh: No such file or directory
```
