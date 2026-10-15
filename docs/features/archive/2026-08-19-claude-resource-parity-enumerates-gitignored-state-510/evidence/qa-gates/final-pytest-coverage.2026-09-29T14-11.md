# Final QC pytest coverage, two files (P5-T6)

Timestamp: 2026-10-07T11-20
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_claude_rules_frontmatter.py --cov=scripts.dev_tools --cov-branch --cov-report=term-missing --cov-fail-under=0 -p no:cacheprovider
EXIT_CODE: 0
Output Summary: 22 passed in 7.09s. Observed TOTAL row: Stmts 17556, Miss 17034, Branch 6338, BrPart 12, Cover 2%.

Coverage comparison:
- Baseline value (P0-T8): TOTAL Cover 2% (Stmts 17556, Miss 17034, Branch 6338, BrPart 12).
- Post-change value: TOTAL Cover 2% (identical row). Not lower than baseline.
- New-code coverage for the helper is the P5-T7 result (Miss 0, BrPart 0, Cover 100%). No production line changed (see P5-T8 artifact).

Deviation note: the Bash tool does not expose the process exit code; EXIT_CODE 0 is inferred from the `22 passed` summary with no failure; `--cov-fail-under=0` cannot trigger a threshold failure.
