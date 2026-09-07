Timestamp: 2026-09-07T17:38
Policy Order:
1. CLAUDE.md
2. .claude/rules/general-code-change.md
3. .claude/rules/general-unit-test.md
4. .claude/rules/shell.md

Files read (in order):
- CLAUDE.md
- .claude/rules/general-code-change.md
- .claude/rules/general-unit-test.md
- .claude/rules/shell.md

Output Summary: All four policy files read in full at session start of the resumed atomic-execution
run for issue #631. Noted the 500-line file-size cap (general-code-change.md), the no-temp-file
test policy and 85% line / 75% branch coverage thresholds with bash exempt from the branch gate
(general-unit-test.md), and the four-stage shell toolchain order
(format -> check -> test -> test --coverage) with the `SHELL_QC_<TOOL>_BIN` override seam and the
500-line cap restated for shell files (shell.md).
