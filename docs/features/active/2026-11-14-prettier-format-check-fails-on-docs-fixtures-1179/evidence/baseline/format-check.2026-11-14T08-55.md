# Baseline: root format:check (P0-T1)

Timestamp: 2026-11-14T08-55
Command: npm --prefix <worktree> run format:check (after one `npm --prefix <worktree> ci --no-audit --no-fund`, 510 packages added)
EXIT_CODE: 1
Output Summary: Prettier reported "Code style issues found in 3 files". Files flagged:
- tests/scripts/claude-lib/docs/fixtures/config-surface-corpus.json
- tests/scripts/claude-lib/docs/fixtures/python-native-corpus.json
- tests/scripts/claude-lib/docs/fixtures/python-surface-corpus.json
No file other than the three fixtures was flagged. Raw output kept in SCRATCH (issue-1179-fc0.txt).
