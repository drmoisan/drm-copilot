# Remediation cycle 2 - baseline PowerShell coverage and Passed-count headline (P0-T9)

Timestamp: 2026-10-16T19-54
Command: Read FEATURE/evidence/qa-gates/coverage-comparison.2026-10-16T17-08.md:4,9,17,19,26-29; Read FEATURE/evidence/qa-gates/ci-rows-windows.2026-10-16T17-08.md:9,38-42; Read FEATURE/evidence/qa-gates/ci-rows-linux.2026-10-16T17-08.md:23-27
EXIT_CODE: 0
Output Summary:
R_BASE_REM=38933561015
CODEX_HELPER_LINE=74.07
CODEX_HELPER_CHANGED=74.07
CODEX_HELPER_UNCOVERED_LINES=67, 68, 72, 165, 166, 171, 172, 179, 182, 183, 184, 185, 186, 189
CLAUDE_HELPER_LINE=100.00
REPO_PS_LINE=89.90
Windows Passed counts: CLAUDE_MQ=40 CODEX_MQ=35 CODEX_CMD=15 CLAUDE_DOCSONLY=14 CODEX_DOCSONLY=9
Linux Passed counts: CLAUDE_MQ=40 CODEX_MQ=35 CODEX_CMD=15 CLAUDE_DOCSONLY=14 CODEX_DOCSONLY=9
DOCS_ONLY_DIFF_COVERAGE_BASE=PENDING-ORCH (ORCH-R3, R_base 38926487064)

## Source lines (verbatim)

coverage-comparison.2026-10-16T17-08.md:
- :4 `Command: D-COV over powershell-coverage.xml of R_final_2 38933561015 (job poshqc / PowerShell QC); ...`
- :9 `REPO_PS_LINE=89.90 (covered 16720, missed 1878)`
- :17 `| .claude/hooks/enforce-epic-merge-gate-command.ps1 | NEW | 100.00 | 54 | 54 | 100.00 | PASS |`
- :19 `| .codex/hooks/enforce-epic-merge-gate-command.ps1 | NEW | 74.07 | 54 | 40 | 74.07 | FAIL |`
- :26 `CODEX_HELPER_COVERED_LINES=23,26,29,32,45,46,47,64,65,66,70,71,86,87,88,89,90,91,93,107,108,109,111,131,132,134,135,137,158,159,160,161,162,163,164,168,169,170,174,177`
- :27 `CODEX_HELPER_UNCOVERED_LINES=67,68,72,165,166,171,172,179,182,183,184,185,186,189`
- :28 `CLAUDE_HELPER_COVERED_LINES=` (54 lines, including every Codex-uncovered line)
- :29 `CLAUDE_HELPER_UNCOVERED_LINES=`

ci-rows-windows.2026-10-16T17-08.md:
- :9 `DOCS_ONLY_CLAUDE_BASE=14 DOCS_ONLY_CODEX_BASE=9 (R_base 38911869997 Windows file; equal to the planner static counts)`
- :38 `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1 | 40 | 0 | 40 | PASS`
- :39 `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1 | 35 | 0 | 35 | PASS`
- :40 `tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1 | 15 | 0 | 15 | PASS`
- :41 `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1 | 14 | 0 | 14 | PASS`
- :42 `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1 | 9 | 0 | 9 | PASS`

ci-rows-linux.2026-10-16T17-08.md:
- :23 MergeQueue 40; :24 Codex merge-queue 35; :25 command 15; :26 DocsOnly 14; :27 docs-only 9 (each 0 fail/error, PASS)

Every copied value is numeric and equals its source.
