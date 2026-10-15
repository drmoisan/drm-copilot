# P2-T2 Numeric content check of the CI evidence file

Timestamp: 2026-10-12T19-42
Command: grep -c -E 'covered=(57 missed=4 line_pct=93.44|111 missed=3 line_pct=97.37|53 missed=4 line_pct=92.98|64 missed=2 line_pct=96.97) threshold=85.00 result=PASS' docs/features/active/2026-10-11-pr-author-hook-docs-only-exemption-901/evidence/qa-gates/ci-pr-924.2026-10-12T19-05.md
EXIT_CODE: 0
CMD2_EXIT_CODE: 0 (grep -c -F -e 'covered=16300 missed=1741 line_pct=90.35' ...)
CMD3_EXIT_CODE: 0 (grep -c -F -e 'CI_RUN_ID: 38321045586' ...)
CMD4_EXIT_CODE: 0 (grep -c -F -e 'CI_HEAD_SHA: c9123db7f7db50f200a639360f799d4959b4da5d' ...)
Output Summary:
- Counts printed 4, 1, 1, 1: all four per-file results, the repository-wide total, the run id, and the head SHA are present as fixed by the plan.
