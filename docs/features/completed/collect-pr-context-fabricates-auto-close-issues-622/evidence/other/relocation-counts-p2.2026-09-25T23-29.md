# Python Relocation Collection Count (P2-T6)

Timestamp: 2026-09-26T19-54
Command: poetry run pytest --collect-only -q tests/scripts/dev_tools/test_collect_pr_context.py tests/scripts/dev_tools/test_collect_pr_context_part4.py tests/scripts/dev_tools/test_collect_pr_context_part5.py
EXIT_CODE: 0

Output Summary:
- `24 tests collected in 0.13s`: test_collect_pr_context.py 20, test_collect_pr_context_part4.py 2, test_collect_pr_context_part5.py 2.
- Expected: N_cpc + N_p4 - 2 = 21 + 5 - 2 = 24 (values from test-collection-counts.2026-09-25T23-29.md). Match.
- The two relocated autoclose tests (`test_narrative_mentions_excluded_from_autoclose_section`, `test_pass_readiness_autoclose_section`) now live in tests/scripts/dev_tools/pr_context/test_autoclose_collector.py as C7 and C8.
