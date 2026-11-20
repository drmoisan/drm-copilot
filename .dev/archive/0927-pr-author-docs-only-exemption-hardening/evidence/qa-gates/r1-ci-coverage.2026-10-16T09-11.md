# R1 CI Coverage on the Final Code Commit (Issue #927; PA-1; AC-9, AC-21, AC-M24 supporting values)

Timestamp: 2026-10-16T09-11
Command: gh run download 38876469175 -n poshqc-test-results -D SCRATCH/927/ci-r1/38876469175
EXIT_CODE: 0
Output Summary: PA-1 pass conditions hold on CI run 38876469175 (job poshqc / PowerShell QC, head 7966e1564635b5e4f60c22eeac47932018ae264a). Repo-wide PowerShell LINE 16580/18369 = 90.26% (PASS); JUnit tests=10545 failures=0 errors=0. All seven named hook files are at or above 85% line (helper copies 97.52% each; docs-only 100%; pr-author 92.98%; Claude gate 99.29%; resolution 95.65%; Codex gate 88.41%). The four AC-9 statements have ci > 0. Changed-line coverage: Claude gate 8/8, resolution 4/4, docs-only 8/8, pr-author N/A (0 executable changed lines), Codex gate 8/9 with the single ci=0 line being the entry-point statement at line 403 (D-R1-12).

R1_CI_RUN_ID: 38876469175
R1_CI_RUN_HEADSHA: 7966e1564635b5e4f60c22eeac47932018ae264a
DOWNLOAD_DIR: SCRATCH/927/ci-r1/38876469175 (new, empty directory before the download)

Command 2: poetry run python -I SCRATCH/927/tools/read_report_totals_927.py SCRATCH/927/ci-r1/38876469175/powershell-coverage.xml SCRATCH/927/ci-r1/38876469175/pester-junit.xml
EXIT_CODE_2: 0
REPORT_LINE: covered=16580 missed=1789 line_pct=90.26 threshold=85.00 result=PASS
JUNIT_TOTALS: tests=10545 failures=0 errors=0

C1 Command: poetry run python -I SCRATCH/927/tools/read_coverage_927.py <XML> .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .codex/hooks/enforce-epic-merge-gate.ps1 > SCRATCH/927/r1-out/files-38876469175.txt
C1_EXIT_CODE: 0
COVERAGE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 covered=118 missed=3 line_pct=97.52 threshold=85.00 result=PASS
COVERAGE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 covered=118 missed=3 line_pct=97.52 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 covered=54 missed=0 line_pct=100.0 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.ps1 covered=53 missed=4 line_pct=92.98 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 covered=139 missed=1 line_pct=99.29 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 covered=44 missed=2 line_pct=95.65 threshold=85.00 result=PASS
COVERAGE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 covered=145 missed=19 line_pct=88.41 threshold=85.00 result=PASS

C2 AC9_LINES derivation (grep -n on .claude/hooks/enforce-pr-author-skill.docs-only.ps1): capture statement 78; $code = $LASTEXITCODE 79; return $failure 75 and 82 (larger: 82); ExitCode = [int]$code 84
AC9_LINES: 78,79,82,84
C2 Command: poetry run python -I SCRATCH/927/tools/read_coverage_927.py <XML> .claude/hooks/enforce-pr-author-skill.docs-only.ps1:78,79,82,84 > SCRATCH/927/r1-out/ac9-38876469175.txt
C2_EXIT_CODE: 0
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=78 ci=2 mi=0
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=79 ci=1 mi=0
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=82 ci=1 mi=0
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=84 ci=4 mi=0

C3 (after git fetch origin main; git diff -U0 origin/main...HEAD -- <file>, hunks with d > 0):
CHANGED_LINES .claude/hooks/enforce-pr-author-skill.docs-only.ps1: 15,16,17,18,19,21,22,30,31,32,39,40,44,59,60,61,69,70,78,115,116,117,118,119,139,140,141,142,191,219
CHANGED_LINES .claude/hooks/enforce-pr-author-skill.ps1: 29,30,31,32,33,34,35,38,39,40,41,42
CHANGED_LINES .claude/hooks/enforce-epic-merge-gate.ps1: 36,37,38,39,40,41,42,43,44,45,46,47,81,82,418,419,420,421,422,423,424,425,426,431
CHANGED_LINES .claude/hooks/enforce-epic-merge-gate-resolution.ps1: 27,28,246-278 (each line listed individually in the C4 call)
CHANGED_LINES .codex/hooks/enforce-epic-merge-gate.ps1: 4-17,28,29,145,146,195-203,208,403 (each line listed individually in the C4 call)

C4 Command: poetry run python -I SCRATCH/927/tools/read_coverage_927.py <XML> <five file:list specs> > SCRATCH/927/r1-out/changed-38876469175.txt
C4_EXIT_CODE: 0
EXECUTABLE LINE_RESULT rows (verbatim; every other listed line printed NOT_EXECUTABLE_OR_ABSENT):
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=44 ci=2 mi=0
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=70 ci=1 mi=0
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=78 ci=2 mi=0
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=139 ci=2 mi=0
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=140 ci=1 mi=0
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=142 ci=1 mi=0
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=191 ci=3 mi=0
LINE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 nr=219 ci=2 mi=0
LINE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 nr=82 ci=3 mi=0
LINE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 nr=419 ci=1 mi=0
LINE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 nr=420 ci=1 mi=0
LINE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 nr=421 ci=1 mi=0
LINE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 nr=422 ci=1 mi=0
LINE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 nr=423 ci=1 mi=0
LINE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 nr=425 ci=1 mi=0
LINE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 nr=431 ci=2 mi=0
LINE_RESULT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 nr=272 ci=2 mi=0
LINE_RESULT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 nr=273 ci=1 mi=0
LINE_RESULT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 nr=274 ci=1 mi=0
LINE_RESULT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 nr=277 ci=1 mi=0
LINE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 nr=29 ci=2 mi=1
LINE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 nr=196 ci=1 mi=0
LINE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 nr=197 ci=1 mi=0
LINE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 nr=198 ci=1 mi=0
LINE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 nr=199 ci=1 mi=0
LINE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 nr=200 ci=1 mi=0
LINE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 nr=202 ci=1 mi=0
LINE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 nr=208 ci=1 mi=0
LINE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 nr=403 ci=0 mi=1

C5 tallies (COVERED / UNCOVERED / NOT_EXECUTABLE; each grep -c printing 0 exited 1, expected):
TALLY .claude/hooks/enforce-pr-author-skill.docs-only.ps1: COVERED 8 UNCOVERED 0 NOT_EXECUTABLE 22
TALLY .claude/hooks/enforce-pr-author-skill.ps1: COVERED 0 UNCOVERED 0 NOT_EXECUTABLE 12
TALLY .claude/hooks/enforce-epic-merge-gate.ps1: COVERED 8 UNCOVERED 0 NOT_EXECUTABLE 16
TALLY .claude/hooks/enforce-epic-merge-gate-resolution.ps1: COVERED 4 UNCOVERED 0 NOT_EXECUTABLE 31
TALLY .codex/hooks/enforce-epic-merge-gate.ps1: COVERED 8 UNCOVERED 1 NOT_EXECUTABLE 20

CHANGED_LINE_COVERAGE .claude/hooks/enforce-pr-author-skill.docs-only.ps1: 8/8 = 100.00%
CHANGED_LINE_COVERAGE .claude/hooks/enforce-pr-author-skill.ps1: N/A (0 executable changed lines; header comment only)
ENTRY_POINT_GREP: grep -n -F -e '$decision = Invoke-CodexEpicMergeDecision -PayloadRaw' .codex/hooks/enforce-epic-merge-gate.ps1 printed line 403
UNCOVERED_CHANGED_LINE: .codex/hooks/enforce-epic-merge-gate.ps1:403 REASON: entry-point statement after the dot-source guard; runs only when the hook executes as a process (D-R1-12)
R1_CI_COVERAGE: PASS
