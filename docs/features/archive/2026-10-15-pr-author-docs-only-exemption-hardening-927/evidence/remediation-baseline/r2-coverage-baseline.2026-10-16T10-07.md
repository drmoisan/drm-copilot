# R2 Coverage Baseline (Issue #927)

Timestamp: 2026-10-16T10-07
Command: grep -E -e '^(REPORT_LINE|JUNIT_TOTALS|COVERAGE_RESULT): ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/r1-ci-coverage.2026-10-16T09-11.md
EXIT_CODE: 0
Output Summary: CI baseline (run 38876469175, from the R1 record): repo-wide line 90.26% (16580/18369), JUnit tests=10545 failures=0 errors=0, all seven files PASS (helper copies 97.52% each). Local pre-cycle XML: repo-wide line 66.09% (8128/12298, FAIL), hook aggregate 66.09% (FAIL), JUnit tests=7183; three files have no class entry (CLASS_COUNT=0), reader exit 1, which is the expected pre-cycle state recorded for PA-1R.

R2_BASE_CI_SOURCE: r1-ci-coverage.2026-10-16T09-11.md

## CI baseline (Command 1)

R2_BASE_CI REPORT_LINE: covered=16580 missed=1789 line_pct=90.26 threshold=85.00 result=PASS
R2_BASE_CI JUNIT_TOTALS: tests=10545 failures=0 errors=0
R2_BASE_CI COVERAGE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 covered=118 missed=3 line_pct=97.52 threshold=85.00 result=PASS
R2_BASE_CI COVERAGE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 covered=118 missed=3 line_pct=97.52 threshold=85.00 result=PASS
R2_BASE_CI COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 covered=54 missed=0 line_pct=100.0 threshold=85.00 result=PASS
R2_BASE_CI COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.ps1 covered=53 missed=4 line_pct=92.98 threshold=85.00 result=PASS
R2_BASE_CI COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 covered=139 missed=1 line_pct=99.29 threshold=85.00 result=PASS
R2_BASE_CI COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 covered=44 missed=2 line_pct=95.65 threshold=85.00 result=PASS
R2_BASE_CI COVERAGE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 covered=145 missed=19 line_pct=88.41 threshold=85.00 result=PASS

## Local pre-cycle state

- Command 2: `stat -c %Y artifacts/pester/powershell-coverage.xml`
  - EXIT_CODE_2: 0
  - Output: `1792140182`
- Command 3: `poetry run python -I SCRATCH/927/tools/read_report_totals_927.py artifacts/pester/powershell-coverage.xml artifacts/pester/pester-junit.xml`
  - EXIT_CODE_3: 0
- Command 4: `poetry run python -I SCRATCH/927/tools/read_hook_aggregate_927.py artifacts/pester/powershell-coverage.xml`
  - EXIT_CODE_4: 0
- Command 5: `poetry run python -I SCRATCH/927/tools/read_coverage_927.py artifacts/pester/powershell-coverage.xml .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .codex/hooks/enforce-epic-merge-gate.ps1`
  - EXIT_CODE_5: 1 (expected pre-cycle state: three files have no entry in the scoped XML)

R2_BASE_LOCAL REPORT_LINE: covered=8128 missed=4170 line_pct=66.09 threshold=85.00 result=FAIL
R2_BASE_LOCAL JUNIT_TOTALS: tests=7183 failures=0 errors=0
R2_BASE_LOCAL HOOK_AGGREGATE_LINE: counters=1329 covered=40640 missed=20850 line_pct=66.09 threshold=85.00 result=FAIL
R2_BASE_LOCAL COVERAGE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 CLASS_COUNT=0
R2_BASE_LOCAL COVERAGE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 CLASS_COUNT=0
R2_BASE_LOCAL COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 CLASS_COUNT=0
R2_BASE_LOCAL COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.ps1 covered=53 missed=4 line_pct=92.98 threshold=85.00 result=PASS
R2_BASE_LOCAL COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 covered=139 missed=1 line_pct=99.29 threshold=85.00 result=PASS
R2_BASE_LOCAL COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 covered=44 missed=2 line_pct=95.65 threshold=85.00 result=PASS
R2_BASE_LOCAL COVERAGE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 covered=162 missed=2 line_pct=98.78 threshold=85.00 result=PASS
