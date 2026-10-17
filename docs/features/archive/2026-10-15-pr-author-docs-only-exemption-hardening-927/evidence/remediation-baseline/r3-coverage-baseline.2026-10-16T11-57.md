# R3 coverage and test-total baseline (issue #927, remediation cycle 3)

Timestamp: 2026-10-16T11-57
Command: grep -E -e '^(REPORT_LINE|JUNIT_TOTALS|COVERAGE_RESULT): ' docs/features/active/2026-10-15-pr-author-docs-only-exemption-hardening-927/evidence/qa-gates/r2-pa1r-route-b.2026-10-16T10-53.md
EXIT_CODE: 0
Output Summary: Baseline is the cycle 2 full-population route B record of the code examined by the 2026-10-16T11-19 review. Repo-wide line 90.33% (16644/18426); JUnit tests=10606 failures=0 errors=0; both helper copies 97.54%; all seven changed hook files PASS against the 85% floor. Nine lines copied below.

R3_BASE_SOURCE: r2-pa1r-route-b.2026-10-16T10-53.md

R3_BASE REPORT_LINE: covered=16644 missed=1782 line_pct=90.33 threshold=85.00 result=PASS
R3_BASE JUNIT_TOTALS: tests=10606 failures=0 errors=0
R3_BASE COVERAGE_RESULT: .claude/hooks/hook-docs-only-diff.ps1 covered=119 missed=3 line_pct=97.54 threshold=85.00 result=PASS
R3_BASE COVERAGE_RESULT: .codex/hooks/hook-docs-only-diff.ps1 covered=119 missed=3 line_pct=97.54 threshold=85.00 result=PASS
R3_BASE COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.docs-only.ps1 covered=54 missed=0 line_pct=100.0 threshold=85.00 result=PASS
R3_BASE COVERAGE_RESULT: .claude/hooks/enforce-pr-author-skill.ps1 covered=53 missed=4 line_pct=92.98 threshold=85.00 result=PASS
R3_BASE COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate.ps1 covered=139 missed=1 line_pct=99.29 threshold=85.00 result=PASS
R3_BASE COVERAGE_RESULT: .claude/hooks/enforce-epic-merge-gate-resolution.ps1 covered=44 missed=2 line_pct=95.65 threshold=85.00 result=PASS
R3_BASE COVERAGE_RESULT: .codex/hooks/enforce-epic-merge-gate.ps1 covered=145 missed=19 line_pct=88.41 threshold=85.00 result=PASS
