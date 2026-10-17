# Preserved deny-phrase checks ([P4-T6])

Timestamp: 2026-10-08T18-02
Command: grep -c -F "replaced through an unresolved patch" <both hooks> ; grep -c -F "COMPLETION_CONSISTENCY_BLOCKED:" <both hooks>
EXIT_CODE: 0
Output Summary: printed 1 (.claude), 1 (.codex), 3 (.claude), 3 (.codex); every value is at least 1. The transport suite run in [P3-T9] passed (PASSED=51), which proves the subprocess and in-process markers still match.
