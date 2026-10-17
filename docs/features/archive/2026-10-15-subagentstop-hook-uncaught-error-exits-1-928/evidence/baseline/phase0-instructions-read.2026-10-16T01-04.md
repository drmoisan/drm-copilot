# Phase 0 Instructions Read (issue #928)

Timestamp: 2026-10-16T01-04
Policy Order: CLAUDE.md -> general-code-change -> general-unit-test -> powershell -> python -> python-suppressions -> quality-tiers

Files read, in order (paths relative to WORKTREE_ROOT):

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/powershell.md`
5. `.claude/rules/python.md`
6. `.claude/rules/python-suppressions.md` (Python in scope only for the pytest parity check)
7. `.claude/rules/quality-tiers.md` (applies: `quality-tiers.yml` exists and classifies `.claude/hooks` as T3)

Output Summary: Seven policy files read in the stated order. `quality-tiers.yml` line 28-29 records `.claude/hooks` as tier T3.
