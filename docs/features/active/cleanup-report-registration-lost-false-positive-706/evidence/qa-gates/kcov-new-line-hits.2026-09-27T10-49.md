# New-Line Hit Verification (P4-T13)

Timestamp: 2026-09-27T10-49
CI_SHA: 3bcaee4d87dae9d077ddbe9b6cb9f357230e3548
RUN_ID: 36326020967

Command: grep -n -F 'local path=${1:-}' scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: 83

Command: grep -n -F '[[ $path == /* || $path == [A-Za-z]:[/\\]* ]]' scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 1
Output Summary: No output. Same local GNU grep 3.0 `-F` defect recorded in P3-T4 (`\\` in the pattern is collapsed to one backslash). Located with the escaped form below.

Command: grep -n -F '[[ $path == /* || $path == [A-Za-z]:[/\\\\]* ]]' scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: 84

Command: grep -n -F '[[ -e ${1:-} ]]' scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: 94

Command: grep -n -F 'if ! scan_helper_is_absolute_path "$target"; then' scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: 116

Command: grep -n -F 'target="$dir/$target"' scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: 117

Command: grep -n -F 'if scan_helper_target_present "$target"; then' scripts/bash/cleanup_worktrees_scan_helper.sh
EXIT_CODE: 0
Output Summary: 119

## Hits from the P4-T12 class block

| Line | Content | hits |
| --- | --- | --- |
| 83 | `local path=${1:-}` | 1 |
| 84 | `[[ $path == /* \|\| $path == [A-Za-z]:[/\\]* ]]` | 1 |
| 94 | `[[ -e ${1:-} ]]` | 1 |
| 116 | `if ! scan_helper_is_absolute_path "$target"; then` | 1 |
| 117 | `target="$dir/$target"` | 1 |
| 119 | `if scan_helper_target_present "$target"; then` | 1 |

Result: all six lines are instrumented and each has hits of at least 1. No NOT-INSTRUMENTED line and no ATTRIBUTION-GAP.
