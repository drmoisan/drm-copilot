Timestamp: 2026-11-05T04-27
Started: 2026-11-05T04:22:18.5686619Z
Command: docker exec -u vscode 1a90d86c1591 bash SCRATCH/issue-1082-shell-final.sh test
EXIT_CODE: 0
Output Summary:

```text
ok 755 virtual environment cleanup failures propagate
ok 756 check prints the no-scripts skip message and exits 0
ok 757 check exits 127 with the five-line block when shfmt is missing
ok 758 check exits 127 with the block when shellcheck is missing
ok 759 check returns the shfmt exit code when only shfmt fails
ok 760 check returns the shellcheck exit code when only shellcheck fails
ok 761 check returns the maximum exit code when both tools fail
ok 762 check invokes shfmt once over the full list and shellcheck once per file
ok 763 format passes -w to shfmt
ok 764 test prints the exact no-test-directory skip marker and exits 0
ok 765 test prints the exact bats-missing skip marker and exits 0
ok 766 test --coverage exits 127 with the coverage message when bats is missing
ok 767 test --coverage exits 127 with message and block when kcov is missing
ok 768 test --coverage builds the kcov argv and merges the runs
ok 769 extract_cobertura_line_rate reads the fixture line-rate
ok 770 print_coverage_summary formats the fixture line-rate to one decimal percent
ok 771 --help prints usage and exits 0
ok 772 help subcommand prints usage and exits 0
ok 773 an unknown subcommand prints usage and exits 2
ok 774 an unknown test flag exits 2
ok 775 test fails when a bats child sources a nounset library inside bash -c
ok 776 test passes when a bats child resets nounset after sourcing
ok 777 kcov_trace_env.sh sets the kcov PS4 format
ok 778 test passes --recursive to bats for each test directory
ok 779 test --coverage passes --recursive to bats under kcov
ok 780 check_coverage_threshold fails below the default 85 percent minimum
ok 781 check_coverage_threshold passes when coverage equals the minimum
ok 782 check_coverage_threshold passes when coverage is above the minimum
ok 783 check_coverage_threshold rejects a minimum that is not an integer
ok 784 check_coverage_threshold rejects a minimum above 100
ok 785 check_coverage_threshold prints nothing and passes when cov.xml is missing
ok 786 extract_shebang_command reads extensionless env bash shebang
ok 787 extract_shebang_command handles env -S flags form
ok 788 extract_shebang_command lowercases an uppercase shebang
ok 789 extract_shebang_command handles a plain sh shebang
ok 790 is_shell_script accepts a .sh suffix
ok 791 is_shell_script rejects a non-shell text file
ok 792 is_shell_script rejects a pwsh shebang
ok 793 discover_shell_scripts finds .sh suffix and every bash/sh shebang form
ok 794 discover_shell_scripts finds a .sh file under the .claude/lib/bash root
ok 795 discover_shell_scripts finds a .sh file under the .claude/skills root
ok 796 discover_shell_scripts finds a .sh file under the .codex root
ok 797 discover_shell_scripts prunes the excluded node_modules directory
ok 798 discover_shell_scripts ignores non-shell files (txt and ps1)
ok 799 discover_shell_scripts output is sorted and de-duplicated
```

Raw output: SCRATCH/issue-1082-shell-test-final-corrected.log
