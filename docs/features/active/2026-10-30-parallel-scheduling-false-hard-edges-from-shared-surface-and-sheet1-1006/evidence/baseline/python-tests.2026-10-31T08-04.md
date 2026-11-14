# Python Tests and Coverage Baseline (issue #1006)

Timestamp: 2026-10-31T08-04
Task: P0-T5
Command: poetry run pytest tests/scripts/dev_tools -q -p no:cacheprovider --cov=scripts.dev_tools._blast_radius_token_shapes --cov=scripts.dev_tools._blast_radius_extraction --cov=scripts.dev_tools._blast_radius_write_intent --cov=scripts.dev_tools.compute_blast_radius --cov=scripts.dev_tools.push_down_claude_blast_radius_overlay --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1006-cov-baseline.json
EXIT_CODE: 0
Output Summary:
- 8300 passed, 0 failed, 6 skipped in 73.27s.
- Pre-existing failing tests: none.
- Skipped: `test_blast_radius_regression_452.py` (1, unconditional tolerance skip marker) and `test_parallel_manifest_bash_parity.py` (5, no accessor expectation).
- Per-file coverage from the JSON report (line, branch):
  - `scripts/dev_tools/_blast_radius_token_shapes.py`: line 100.00% (27/27), branch 100.00% (10/10)
  - `scripts/dev_tools/_blast_radius_extraction.py`: line 100.00% (97/97), branch 100.00% (44/44)
  - `scripts/dev_tools/_blast_radius_write_intent.py`: line 97.98% (97/99), branch 95.24% (40/42); missing lines 345, 351 (pre-existing)
  - `scripts/dev_tools/compute_blast_radius.py`: line 100.00% (80/80), branch 100.00% (14/14)
  - `scripts/dev_tools/push_down_claude_blast_radius_overlay.py`: line 100.00% (109/109), branch 100.00% (52/52)
- Note: the first run wrote the JSON report to a mis-resolved MSYS path; the file was moved into SCRATCH before reading, and the launcher was corrected for later runs. The test results are unaffected.
