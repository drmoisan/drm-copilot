# R1 Pre-remediation CI Snapshot (Issue #927; supporting data only)

Timestamp: 2026-10-16T07-40
Command: gh run view 38855083321 --json headSha,status,conclusion,event
EXIT_CODE: 0
Output Summary: Run 38855083321 (workflow_dispatch, completed, success, head 620a2e966) snapshot of the reviewed code: repo-wide LINE 16533/18323 (90.23%), JUnit tests=10517 failures=0 errors=0; all seven named hook files at or above 85% line. Supporting data only; PA-1 is closed by [P8-T3].

PRE_RUN: {"conclusion":"success","event":"workflow_dispatch","headSha":"620a2e966129dd4b68e8aed9b6397c33bb0080ff","status":"completed"}

Command 2: gh run download 38855083321 -n poshqc-test-results -D SCRATCH/927/ci-pre/38855083321
EXIT_CODE_2: 0

Command 3: poetry run python -I SCRATCH/927/tools/read_report_totals_927.py SCRATCH/927/ci-pre/38855083321/powershell-coverage.xml SCRATCH/927/ci-pre/38855083321/pester-junit.xml
EXIT_CODE_3: 0
REPORT_LINE: covered=16533 missed=1790 line_pct=90.23 threshold=85.00 result=PASS
JUNIT_TOTALS: tests=10517 failures=0 errors=0

Command 4: poetry run python -I SCRATCH/927/tools/read_coverage_927.py SCRATCH/927/ci-pre/38855083321/powershell-coverage.xml .claude/hooks/hook-docs-only-diff.ps1 .codex/hooks/hook-docs-only-diff.ps1 .claude/hooks/enforce-pr-author-skill.docs-only.ps1 .claude/hooks/enforce-pr-author-skill.ps1 .claude/hooks/enforce-epic-merge-gate.ps1 .claude/hooks/enforce-epic-merge-gate-resolution.ps1 .codex/hooks/enforce-epic-merge-gate.ps1
EXIT_CODE_4: 0
COVERAGE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 covered=94 missed=4 line_pct=95.92 threshold=85.00 result=PASS
COVERAGE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 covered=95 missed=3 line_pct=96.94 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 covered=54 missed=0 line_pct=100.0 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.ps1 covered=53 missed=4 line_pct=92.98 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 covered=139 missed=1 line_pct=99.29 threshold=85.00 result=PASS
COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 covered=44 missed=2 line_pct=95.65 threshold=85.00 result=PASS
COVERAGE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 covered=145 missed=19 line_pct=88.41 threshold=85.00 result=PASS
