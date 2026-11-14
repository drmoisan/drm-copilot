# User-story criterion 1 re-check ([P2-T7], remediation cycle 1)

Timestamp: 2026-11-14T01-20
Command: read of the evidence files below; `git -C <worktree> diff --numstat -- FEATURE/user-story.md`
EXIT_CODE: 0
Output Summary: Criterion 1 of the epic-planner operator story (the checkpoint accepts a `planner_worktrees` list, and both validators accept a well-formed list and reject malformed entries with byte-identical strings) now passes, so its box is checked in `FEATURE/user-story.md`. The diff of that file is one removed and one added line (the checkbox only); no criterion text changed. All 15 criteria in the file are now checked.

## Evidence

| Evidence | Result |
|---|---|
| `evidence/regression-testing/recorded-at-fail-before.2026-11-14T01-01.md` | before the fix the two runtimes disagreed on three corpus rows (U+001F and U+0085 in Python, U+FEFF in TypeScript), which is the PARTIAL finding PA-1 |
| `evidence/qa-gates/pytest-gate.2026-11-14T01-17.md` | 0 failures in one `pytest -n auto` run with all 21 corpus files (both parametrized corpus tests pass for every file) |
| `evidence/qa-gates/jest-gate.2026-11-14T01-18.md` | 0 failures in one Jest run with all 21 corpus files (both `it.each` corpus tests pass for every file) |

The same 21 committed files hold each runtime to the same ordered `expected_errors`, so both runtimes now return byte-identical results on every corpus row, including the three rows where they disagreed before the fix.
