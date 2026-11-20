Timestamp: 2026-11-04T02-38
Command: pwsh -NoProfile -File SCRATCH/issue-1069-shell-bounded.ps1
EXIT_CODE: 0
Output Summary: ok 38 discover_shell_scripts finds .sh suffix and every bash/sh shebang form
ok 39 discover_shell_scripts finds a .sh file under the .claude/lib/bash root
ok 40 discover_shell_scripts finds a .sh file under the .claude/skills root
ok 41 discover_shell_scripts finds a .sh file under the .codex root
ok 42 discover_shell_scripts prunes the excluded node_modules directory
ok 43 discover_shell_scripts ignores non-shell files (txt and ps1)
ok 44 discover_shell_scripts output is sorted and de-duplicated
ok 45 coverage_demo.sh runs successfully with default argument
ok 46 coverage_demo.sh accepts a custom name argument
ok 47 coverage_lib.sh greet_user function outputs greeting
