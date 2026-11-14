Timestamp: 2026-11-05T04-20
Started: 2026-11-05T04:15:28.9400166Z
Command: docker exec -u vscode 1a90d86c1591 bash SCRATCH/issue-1082-shell-final.sh test
EXIT_CODE: 1
Output Summary:

```text
ok 754 virtual environment cleanup failures propagate
ok 755 check prints the no-scripts skip message and exits 0
ok 756 check exits 127 with the five-line block when shfmt is missing
ok 757 check exits 127 with the block when shellcheck is missing
ok 758 check returns the shfmt exit code when only shfmt fails
ok 759 check returns the shellcheck exit code when only shellcheck fails
ok 760 check returns the maximum exit code when both tools fail
ok 761 check invokes shfmt once over the full list and shellcheck once per file
ok 762 format passes -w to shfmt
ok 763 test prints the exact no-test-directory skip marker and exits 0
ok 764 test prints the exact bats-missing skip marker and exits 0
ok 765 test --coverage exits 127 with the coverage message when bats is missing
ok 766 test --coverage exits 127 with message and block when kcov is missing
ok 767 test --coverage builds the kcov argv and merges the runs
ok 768 extract_cobertura_line_rate reads the fixture line-rate
ok 769 print_coverage_summary formats the fixture line-rate to one decimal percent
ok 770 --help prints usage and exits 0
ok 771 help subcommand prints usage and exits 0
ok 772 an unknown subcommand prints usage and exits 2
ok 773 an unknown test flag exits 2
ok 774 test fails when a bats child sources a nounset library inside bash -c
ok 775 test passes when a bats child resets nounset after sourcing
ok 776 kcov_trace_env.sh sets the kcov PS4 format
ok 777 test passes --recursive to bats for each test directory
ok 778 test --coverage passes --recursive to bats under kcov
ok 779 check_coverage_threshold fails below the default 85 percent minimum
ok 780 check_coverage_threshold passes when coverage equals the minimum
ok 781 check_coverage_threshold passes when coverage is above the minimum
ok 782 check_coverage_threshold rejects a minimum that is not an integer
ok 783 check_coverage_threshold rejects a minimum above 100
ok 784 check_coverage_threshold prints nothing and passes when cov.xml is missing
ok 785 extract_shebang_command reads extensionless env bash shebang
ok 786 extract_shebang_command handles env -S flags form
ok 787 extract_shebang_command lowercases an uppercase shebang
ok 788 extract_shebang_command handles a plain sh shebang
ok 789 is_shell_script accepts a .sh suffix
ok 790 is_shell_script rejects a non-shell text file
ok 791 is_shell_script rejects a pwsh shebang
ok 792 discover_shell_scripts finds .sh suffix and every bash/sh shebang form
ok 793 discover_shell_scripts finds a .sh file under the .claude/lib/bash root
ok 794 discover_shell_scripts finds a .sh file under the .claude/skills root
ok 795 discover_shell_scripts finds a .sh file under the .codex root
ok 796 discover_shell_scripts prunes the excluded node_modules directory
ok 797 discover_shell_scripts ignores non-shell files (txt and ps1)
ok 798 discover_shell_scripts output is sorted and de-duplicated
```

Raw output: SCRATCH/issue-1082-shell-test-clean.log
