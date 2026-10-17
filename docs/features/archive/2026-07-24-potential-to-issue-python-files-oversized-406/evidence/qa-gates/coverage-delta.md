Timestamp: 2026-09-30T10-25
Command: comparison of evidence/baseline/pytest-coverage.md with evidence/qa-gates/pytest-coverage.md (computed from recorded values; no separate command)
EXIT_CODE: 0
Output Summary: PASS. Computed line cover = (Stmts - Miss) / Stmts; printed Cover is the combined line+branch figure, recorded for reference only.

Baseline family (3 rows):
- potential_to_issue.py: Stmts 178, Miss 1, computed 99.44%, printed 97%, BrPart 5
- potential_to_issue_content.py: Stmts 95, Miss 3, computed 96.84%, printed 93%, BrPart 5
- potential_to_issue_filesystem.py: Stmts 31, Miss 0, computed 100.00%, printed 100%, BrPart 0
- Family: Stmts 304, Miss 4, computed 98.68%, BrPart sum 10

Post-change family (4 rows):
- potential_to_issue.py: Stmts 136, Miss 1, computed 99.26%, printed 99%, BrPart 1
- potential_to_issue_adapters.py: Stmts 48, Miss 0, computed 100.00%, printed 94%, BrPart 4
- potential_to_issue_content.py: Stmts 95, Miss 3, computed 96.84%, printed 93%, BrPart 5
- potential_to_issue_filesystem.py: Stmts 31, Miss 0, computed 100.00%, printed 100%, BrPart 0
- Family: Stmts 310, Miss 4, computed 98.71%, BrPart sum 10

Moved-code coverage (potential_to_issue_adapters.py): Stmts 48, Miss 0, computed 100.00%, printed 94%.

Acceptance checks:
1. Post-change family Miss 4 <= baseline family Miss 4: HOLDS.
2. potential_to_issue_content.py Miss unchanged (3 -> 3): HOLDS.
3. Post-change combined computed line cover 98.71% >= baseline 98.68%: HOLDS.
4. Each post-change row computed line cover >= 85% (99.26, 100.00, 96.84, 100.00): HOLDS.
5. Post-change BrPart sum 10 <= baseline BrPart sum 10: HOLDS.
No baseline row reported computed line cover below 85%; no pre-existing finding to record.
