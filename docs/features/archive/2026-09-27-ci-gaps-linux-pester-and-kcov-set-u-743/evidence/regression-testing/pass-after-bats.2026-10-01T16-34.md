# Pass-After bats Run (P2-T6)

Timestamp: 2026-10-01T16-34
Command: npx --yes bats --print-output-on-failure tests/shell/test_shell_qc_commands.bats
EXIT_CODE: 0
Output Summary: `1..22`; 22 ok, 0 not ok. The three R5 tests (`ok 20`, `ok 21`, `ok 22`) and every P0-T18 baseline test in this file pass.

TRACE-FD-NOT-INHERITED: not observed
R7b: NOT APPLIED (P2-T7)

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
ok 20 test fails when a bats child sources a nounset library inside bash -c
ok 21 test passes when a bats child resets nounset after sourcing
ok 22 kcov_trace_env.sh sets the kcov PS4 format
```
