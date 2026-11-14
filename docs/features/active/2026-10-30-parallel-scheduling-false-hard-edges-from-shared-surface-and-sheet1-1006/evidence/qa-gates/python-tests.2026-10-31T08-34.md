# Python Tests with Coverage (issue #1006)

Timestamp: 2026-10-31T08-34
Task: P8-T4
Command: poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider --cov=scripts.dev_tools._blast_radius_token_shapes --cov=scripts.dev_tools._blast_radius_extraction --cov=scripts.dev_tools._blast_radius_write_intent --cov=scripts.dev_tools.compute_blast_radius --cov=scripts.dev_tools.push_down_claude_blast_radius_overlay --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1006-cov-final.json
EXIT_CODE: 0
Output Summary:
- 8334 passed, 0 failed, 6 skipped in 51.96s (the same 6 skips as P0-T5; P0-T5 named no failing test).
- Per-file coverage from the JSON report (line, branch):
  - `scripts/dev_tools/_blast_radius_token_shapes.py`: line 100.00% (31/31), branch 100.00% (10/10)
  - `scripts/dev_tools/_blast_radius_extraction.py`: line 100.00% (97/97), branch 100.00% (44/44)
  - `scripts/dev_tools/_blast_radius_write_intent.py`: line 98.00% (98/100), branch 95.24% (40/42); missing lines 349 and 355 are the pre-existing heading-continue lines, not changed lines
  - `scripts/dev_tools/compute_blast_radius.py`: line 100.00% (81/81), branch 100.00% (14/14)
  - `scripts/dev_tools/push_down_claude_blast_radius_overlay.py`: line 100.00% (135/135), branch 100.00% (64/64)
- Every file is at or above 85 percent line and 75 percent branch. An earlier loop pass showed one partial branch in the demotion (`shared_surfaces` absent); the test `test_document_without_shared_surfaces_keeps_that_key_absent` was added and the Python loop re-run from P8-T1.
