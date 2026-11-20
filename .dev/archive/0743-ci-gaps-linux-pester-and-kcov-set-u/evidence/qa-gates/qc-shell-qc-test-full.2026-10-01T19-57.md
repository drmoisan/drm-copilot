# QC Step 6: Full Bash Test (P3-T6, pass 1)

Timestamp: 2026-10-01T19-57
RUN_START: 2026-10-01T19-37-00
RUN_END: 2026-10-01T19-57-23
Wall time: 20 min 23 s (recorded, not gated).

Command: SHELL_QC_BATS_BIN=<npm-cache>/_npx/cd2c4d46c11457b7/node_modules/bats/bin/bats sh scripts/bash/shell-qc.sh test > <session-scratchpad>/shell-qc-test-final.log 2>&1
EXIT_CODE: 0
Output Summary: TAP plan line `1..501`; 501 `ok` lines; 0 `not ok` lines (see `qc-shell-qc-test-not-ok.2026-10-01T19-57.md`). The log ends with bats BW01 warnings (a `run` command exiting 127 in `tests/shell/test_shell_qc_commands.bats` line 113), which are advisory warnings, not failures; the same warning class is present in the earlier run of this test set.
