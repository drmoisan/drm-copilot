# Baseline size and mirror (P0-T4)

Timestamp: 2026-10-09T06-52
Command: wc -l .claude/lib/bash/parallel-cohorts.sh extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-cohorts.sh tests/shell/parallel_cohorts.bats
EXIT_CODE: 0
Output: 330 / 330 / 222 (total 882)

Command: cmp .claude/lib/bash/parallel-cohorts.sh extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-cohorts.sh
EXIT_CODE: 0
Output: (empty; byte-identical)

Command: grep -c -F "shellcheck disable" .claude/lib/bash/parallel-cohorts.sh
EXIT_CODE: 0
Output: 2
N_sup: 2

Output Summary: line counts 330, 330, 222; cmp exit 0 with empty output; suppression count 2 recorded as N_sup.
