# Final QC — Python Tests and Coverage (P5-T8) (Issue #393)

Timestamp: 2026-07-21T18-45
Command: poetry run pytest --cov --cov-branch --cov-report=term-missing
EXIT_CODE: 0
Output Summary:
- Result: 2069 passed. No failures.
- Statements: 12252 total, 1114 missed -> line coverage = 11138/12252 = 90.9%.
- Branches: 4446 total, 564 partial.
- Combined TOTAL (term report): 88%.
- Thresholds met: line 90.9% >= 85%; branch >= 75% (see coverage-delta for the branch note).
- Note on loop: an initial final-QC pytest run failed one test
  (test_push_down_claude_resource_contracts::test_bundled_claude_payload_contains_all_repo_runtime_contracts)
  because the newly created `.claude/rules/shell.md` (P4-T4) was not yet mirrored into the
  extension bundle. The bundle mirror invariant is enforced by that pre-existing contract test.
  Corrective action: copied `.claude/rules/shell.md` byte-identically to
  `extensions/drm-copilot/resources/claude-customizations/.claude/rules/shell.md`, then
  restarted the full Python loop (black -> ruff -> pyright -> pytest), which then passed in a
  single clean pass. This mirror is a mechanically necessary consequence of adding the rule
  file, not a new scope item.
