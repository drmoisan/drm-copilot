Timestamp: 2026-11-05T03-12
Started: 2026-11-05T03:08:52.1856223Z
Command: docker exec --user vscode --workdir REPO 40c5007b16b3 bash -c kcov --include-pattern=REPO/scripts,REPO/tools,REPO/.claude/lib/bash,REPO/.claude/skills,REPO/.codex,REPO/.devcontainer --exclude-pattern=REPO/tests SCRATCH/issue-1082-kcov-bats bats --recursive tests/shell
EXIT_CODE: 0
Output Summary:

```text
scripts/uppercase_bash
scripts/with_shebang
tools/format_me.sh != *\p\w\s\h\_\s\c\r\i\p\t\.\p\s\1* ]]

The following warnings were encountered during tests:
BW01: `run`'s command `env CLEANUP_WT_JQ_BIN=REPO/tests/fixtures/cleanup_worktrees/preserve/no-jq/jq PATH=REPO/tests/fixtures/cleanup_worktrees/preserve/no-jq /bin/bash -c source 'REPO/.claude/skills/cleanup-merged-worktrees/scripts/cleanup_worktrees_preserve_lib.sh' && preserve_resolve_jq` exited with code 127, indicating 'Command not found'. Use run's return code checks, e.g. `run -127`, to fix this message.
      (from function `run' in file /usr/lib/bats-core/test_functions.bash, line 290,
       in test file tests/shell/test_cleanup_worktrees_preserve.bats, line 139)
BW01: `run`'s command `env SHELL_QC_SHFMT_BIN=/nonexistent/definitely-not-a-tool bash -c cd 'REPO/tests/fixtures/shell_qc' && bash 'REPO/scripts/bash/shell-qc.sh' check` exited with code 127, indicating 'Command not found'. Use run's return code checks, e.g. `run -127`, to fix this message.
      (from function `run' in file /usr/lib/bats-core/test_functions.bash, line 290,
       in test file tests/shell/test_shell_qc_commands.bats, line 36)
BW01: `run`'s command `env SHELL_QC_SHFMT_BIN=REPO/tests/fixtures/shell_qc/stub-bin/shfmt SHELL_QC_SHELLCHECK_BIN=/nonexistent/definitely-not-a-tool bash -c cd 'REPO/tests/fixtures/shell_qc' && bash 'REPO/scripts/bash/shell-qc.sh' check` exited with code 127, indicating 'Command not found'. Use run's return code checks, e.g. `run -127`, to fix this message.
      (from function `run' in file /usr/lib/bats-core/test_functions.bash, line 290,
       in test file tests/shell/test_shell_qc_commands.bats, line 47)
BW01: `run`'s command `env SHELL_QC_BATS_BIN=/nonexistent/definitely-not-a-tool bash -c cd 'REPO/tests/fixtures/shell_qc' && bash 'REPO/scripts/bash/shell-qc.sh' test --coverage` exited with code 127, indicating 'Command not found'. Use run's return code checks, e.g. `run -127`, to fix this message.
      (from function `run' in file /usr/lib/bats-core/test_functions.bash, line 290,
       in test file tests/shell/test_shell_qc_commands.bats, line 106)
BW01: `run`'s command `env SHELL_QC_BATS_BIN=REPO/tests/fixtures/shell_qc/stub-bin/bats SHELL_QC_KCOV_BIN=/nonexistent/definitely-not-a-tool bash -c cd 'REPO/tests/fixtures/shell_qc' && bash 'REPO/scripts/bash/shell-qc.sh' test --coverage` exited with code 127, indicating 'Command not found'. Use run's return code checks, e.g. `run -127`, to fix this message.
      (from function `run' in file /usr/lib/bats-core/test_functions.bash, line 290,
       in test file tests/shell/test_shell_qc_commands.bats, line 113)
ok 742 test fails when a bats child sources a nounset library inside bash -c
ok 743 test passes when a bats child resets nounset after sourcing
ok 744 kcov_trace_env.sh sets the kcov PS4 format
ok 745 test passes --recursive to bats for each test directory
ok 746 test --coverage passes --recursive to bats under kcov
ok 747 check_coverage_threshold fails below the default 85 percent minimum
ok 748 check_coverage_threshold passes when coverage equals the minimum
ok 749 check_coverage_threshold passes when coverage is above the minimum
ok 750 check_coverage_threshold rejects a minimum that is not an integer
ok 751 check_coverage_threshold rejects a minimum above 100
ok 752 check_coverage_threshold prints nothing and passes when cov.xml is missing
ok 753 extract_shebang_command reads extensionless env bash shebang
ok 754 extract_shebang_command handles env -S flags form
ok 755 extract_shebang_command lowercases an uppercase shebang
ok 756 extract_shebang_command handles a plain sh shebang
ok 757 is_shell_script accepts a .sh suffix
ok 758 is_shell_script rejects a non-shell text file
ok 759 is_shell_script rejects a pwsh shebang
ok 760 discover_shell_scripts finds .sh suffix and every bash/sh shebang form
ok 761 discover_shell_scripts finds a .sh file under the .claude/lib/bash root
ok 762 discover_shell_scripts finds a .sh file under the .claude/skills root
ok 763 discover_shell_scripts finds a .sh file under the .codex root
ok 764 discover_shell_scripts prunes the excluded node_modules directory
ok 765 discover_shell_scripts ignores non-shell files (txt and ps1)
ok 766 discover_shell_scripts output is sorted and de-duplicated
```

Raw output: SCRATCH/issue-1082-shell-tests-coverage.log
