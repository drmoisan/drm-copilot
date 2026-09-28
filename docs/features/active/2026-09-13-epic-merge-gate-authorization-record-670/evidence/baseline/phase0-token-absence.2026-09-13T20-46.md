# Phase 0 Token Absence — Issue #670

Timestamp: 2026-09-17T07-50
Task: [P0-T4]
Command: git grep -c -F 'LITERAL' -- .claude .codex tests extensions scripts   (run once per literal below)
EXIT_CODE: 1
ExpectedExitCode: 1

| Literal | git grep exit code | ExpectedExitCode | Matching tracked files |
| --- | --- | --- | --- |
| `standalone_merge_authorizations` | 1 | 1 | 0 |
| `STANDALONE_MERGE_AUTHORIZATION_ABSENT` | 1 | 1 | 0 |
| `STANDALONE_MERGE_AUTHORIZATION_PR_MISMATCH` | 1 | 1 | 0 |
| `STANDALONE_MERGE_AUTHORIZATION_MALFORMED` | 1 | 1 | 0 |
| `STANDALONE_MERGE_AUTHORIZATION_NOT_PR_SPECIFIC` | 1 | 1 | 0 |

Output Summary:
- All five searches exited 1 (no match), equal to the expected exit code 1 for each.
- Zero matching tracked files for all five literals under `.claude`, `.codex`, `tests`, `extensions`, `scripts`. The fix does not already exist in the runtime tree. `docs` is excluded by design.
