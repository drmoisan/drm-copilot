# Phase 0 Policy Reading Evidence (Issue #739)

Timestamp: 2026-10-01T20-47
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> python -> python-suppressions -> self-explanatory-code-commenting

Files read, in order (repository-relative, read from the worktree checkout of `bug/npm-token-guard-gaps-739`):

1. `CLAUDE.md` (P0-T1)
2. `.claude/rules/general-code-change.md` (P0-T2)
3. `.claude/rules/general-unit-test.md` (P0-T3)
4. `.claude/rules/python.md` (P0-T4)
5. `.claude/rules/python-suppressions.md` (P0-T5)
6. `.claude/rules/self-explanatory-code-commenting.md` (P0-T6)

Key constraints noted for this change:

- File size limit 500 lines for test code (general-code-change).
- Temporary files in tests are prohibited (general-unit-test, python).
- Coverage floors: line >= 85%, branch >= 75% (general-unit-test, python).
- Suppressions limited to pre-authorized patterns; `# noqa: S105 - test fixture data` is pre-authorized for test fixture literals (python-suppressions).
- Every function has a docstring; every loop and non-trivial comprehension has an intent comment (self-explanatory-code-commenting).
