Timestamp: 2026-08-26T01-11

Command: poetry run pytest tests/scripts/dev_tools/test_claude_rules_frontmatter.py -q
EXIT_CODE: 0

Output Summary: "8 passed in 0.09s" after the R1 fix (expanding
`EXCLUDED_CLAUDE_SUBDIRS` to `frozenset({"agent-memory", "worktrees", "state"})`).
All eight tests in the target module still pass; the exact test-function set is
unchanged.
