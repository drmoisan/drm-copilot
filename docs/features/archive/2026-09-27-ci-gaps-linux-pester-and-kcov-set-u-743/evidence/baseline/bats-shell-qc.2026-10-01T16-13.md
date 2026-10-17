# Baseline Local bats Run (P0-T18)

Timestamp: 2026-10-01T16-13
Command: npx --yes bats tests/shell/test_shell_qc_commands.bats tests/shell/test_shell_qc_discovery.bats
EXIT_CODE: 0
Output Summary: `1..32`; 32 ok, 0 not ok. Bats 1.13.0 emitted four BW01 warnings (run return code 127 in tests at lines 36, 47, 106, 113 of test_shell_qc_commands.bats); warnings only, not failures.

TAP output:

```
1..32
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
ok 20 extract_shebang_command reads extensionless env bash shebang
ok 21 extract_shebang_command handles env -S flags form
ok 22 extract_shebang_command lowercases an uppercase shebang
ok 23 extract_shebang_command handles a plain sh shebang
ok 24 is_shell_script accepts a .sh suffix
ok 25 is_shell_script rejects a non-shell text file
ok 26 is_shell_script rejects a pwsh shebang
ok 27 discover_shell_scripts finds .sh suffix and every bash/sh shebang form
ok 28 discover_shell_scripts finds a .sh file under the .claude/lib/bash root
ok 29 discover_shell_scripts finds a .sh file under the .claude/skills root
ok 30 discover_shell_scripts prunes the excluded node_modules directory
ok 31 discover_shell_scripts ignores non-shell files (txt and ps1)
ok 32 discover_shell_scripts output is sorted and de-duplicated
```

Local bats baseline failure set: none
