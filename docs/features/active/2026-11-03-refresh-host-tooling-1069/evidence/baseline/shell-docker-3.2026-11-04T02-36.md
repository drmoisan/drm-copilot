Timestamp: 2026-11-04T02-36
Command: docker run --rm --user root --security-opt seccomp=unconfined --mount type=bind,source=WORKSPACE,target=/workspaces/drm-copilot,readonly --mount type=bind,source=SCRATCH,target=/coverage -w /workspaces/drm-copilot --entrypoint bash vsc-drm-copilot-e593fee203d55a66ea1452f0c5df0aee6691b7b1807f1b2ccbad654ee8bf0557 -lc 'SHELL_QC_KCOV_OUT_DIR=/coverage/issue-1069-shell-baseline bash scripts/bash/shell-qc.sh test --coverage'
EXIT_CODE: 1
Output Summary: ok 750 extract_shebang_command lowercases an uppercase shebang
ok 751 extract_shebang_command handles a plain sh shebang
ok 752 is_shell_script accepts a .sh suffix
ok 753 is_shell_script rejects a non-shell text file
ok 754 is_shell_script rejects a pwsh shebang
ok 755 discover_shell_scripts finds .sh suffix and every bash/sh shebang form
ok 756 discover_shell_scripts finds a .sh file under the .claude/lib/bash root
ok 757 discover_shell_scripts finds a .sh file under the .claude/skills root
ok 758 discover_shell_scripts finds a .sh file under the .codex root
ok 759 discover_shell_scripts prunes the excluded node_modules directory
ok 760 discover_shell_scripts ignores non-shell files (txt and ps1)
ok 761 discover_shell_scripts output is sorted and de-duplicated


