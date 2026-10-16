# Baseline PowerShell coverage and Passed counts (remediation cycle 1, issue #952)

Timestamp: 2026-10-16T15-36
Task: [P0-T9]
Command: Read FEATURE/evidence/qa-gates/coverage-comparison.2026-10-16T12-40.md, FEATURE/evidence/qa-gates/ci-rows-windows.2026-10-16T12-40.md, FEATURE/evidence/qa-gates/ci-rows-linux.2026-10-16T12-40.md
EXIT_CODE: 0
Output Summary:
R_BASE_REM=38899600487
CODEX_HELPER_LINE=75.47
CODEX_HELPER_CHANGED=75.47
CODEX_HELPER_UNCOVERED=63, 64, 68, 160, 161, 166, 173, 176, 177, 178, 179, 180, 183
CLAUDE_HELPER_LINE=94.34
CLAUDE_HELPER_UNCOVERED=68, 160, 161
PARSER_LINE=91.67
PARSER_UNCOVERED=98, 101, 108, 128
Windows Passed (job poshqc / PowerShell QC): CLAUDE_MQ=36 CODEX_MQ=34 PARSER_SUITE=13
Linux Passed (job poshqc / PowerShell hook suites (Linux)): CLAUDE_MQ=36 CODEX_MQ=34

Sources:
- coverage-comparison.2026-10-16T12-40.md: `.codex/hooks/enforce-epic-merge-gate-command.ps1 | NEW | 75.47 | 53 | 40 | 75.47 | FAIL`; `.claude/hooks/enforce-epic-merge-gate-command.ps1 | NEW | 94.34 | 53 | 50 | 94.34 | PASS`; `.claude/lib/ci-gate/Invoke-MergeConfirmationParser.ps1 | NEW | 91.67 | 48 | 44 | 91.67 | PASS`; uncovered-line lists as above.
- ci-rows-windows.2026-10-16T12-40.md lines 40-42: MergeQueue (Claude) 36, merge-queue (Codex) 34, Invoke-MergeConfirmationParser 13; R_final=38899600487.
- ci-rows-linux.2026-10-16T12-40.md lines 23-24: MergeQueue (Claude) 36, merge-queue (Codex) 34; R_final=38899600487.

Every value is numeric and equals its source.
