# R2 PA-1R Route B, Loop Pass 1 (Issue #927)

Timestamp: 2026-10-16T10-53
Command: date -u +%s
EXIT_CODE: 0
Output Summary: QC step 3, route B: a full-population run of the repository PoshQC module (CI form; coverage settings unchanged). It exited 0 and both XML files were rewritten after RUN_START_EPOCH. JUnit tests=10606 failures=0 errors=0; report-level line 90.33% (16644/18426, PASS); hook aggregate 90.33% (PASS); all 19 Appendix R rows Passed; no failed test name; all seven files present with result=PASS (helper copies 97.54% each). The R2-READ pass condition holds.

RUN_START_EPOCH: 1792147064

## Commands

- Command 1: `date -u +%s`
  - EXIT_CODE_1: 0
  - Output: `1792147064`
- Command 2: sh SCRATCH/927/r2/run-poshqc-927.sh SCRATCH/927/r2/run-poshqc-927.ps1 SCRATCH/927/r2/direct-run.log
  - Run with the Bash tool background option; one run only.
  - EXIT_CODE_2: 0 (from the completion notification)
- Command 3: `grep -F -e 'POSHQC_EXIT_CODE=' SCRATCH/927/r2/direct-run.log`
  - EXIT_CODE_3: 0
  - Output: `POSHQC_EXIT_CODE=0`
- Command 4: `stat -c %Y artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml`
  - EXIT_CODE_4: 0
  - Output: `1792147830` (coverage); `1792147946` (JUnit); both greater than RUN_START_EPOCH

## R2-READ

- K1: `poetry run python -I SCRATCH/927/tools/read_report_totals_927.py artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml`
  - EXIT_CODE_K1: 0

REPORT_LINE: covered=16644 missed=1782 line_pct=90.33 threshold=85.00 result=PASS
JUNIT_TOTALS: tests=10606 failures=0 errors=0

- K2: `poetry run python -I SCRATCH/927/tools/read_hook_aggregate_927.py artifacts/pester/powershell-coverage.xml`
  - EXIT_CODE_K2: 0

HOOK_AGGREGATE_LINE: counters=1981 covered=83220 missed=8910 line_pct=90.33 threshold=85.00 result=PASS

- K3: `grep -c -F -e '<token>" status="Passed"' artifacts/pester/pester-junit.xml` for each Appendix R token
  - Counts: F1 1, F2 1, F3 1, F4 1, F5 1, F6 1, F7 1, F8 1, F9 1, F10 1, F11 1, F12 1, F13 1, D1 1, D2 1, D3 1, D4 1, D5 1, D6 1
  - `grep -o -E 'testcase name="[^"]*" status="Failed"' artifacts/pester/pester-junit.xml`
  - EXIT_CODE_K3_FAILED_NAMES: 1 (no failed name)
- K4: `poetry run python -I SCRATCH/927/tools/read_coverage_927.py artifacts/pester/powershell-coverage.xml .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .codex/hooks/enforce-epic-merge-gate.ps1`
  - EXIT_CODE_K4: 0

COVERAGE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 covered=119 missed=3 line_pct=97.54 threshold=85.00 result=PASS
COVERAGE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 covered=119 missed=3 line_pct=97.54 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 covered=54 missed=0 line_pct=100.0 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.ps1 covered=53 missed=4 line_pct=92.98 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 covered=139 missed=1 line_pct=99.29 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 covered=44 missed=2 line_pct=95.65 threshold=85.00 result=PASS
COVERAGE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 covered=145 missed=19 line_pct=88.41 threshold=85.00 result=PASS

PA1R_ROUTE_B: SATISFIED
