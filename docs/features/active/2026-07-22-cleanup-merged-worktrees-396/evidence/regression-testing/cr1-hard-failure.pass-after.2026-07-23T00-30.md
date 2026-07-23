# CR-1 Hard-Failure Regression — Pass-After Evidence (Cycle 2), Issue #396

Timestamp: 2026-07-22T21-10

Command:

```
gh run watch 29970805348 --exit-status
gh run view 29970805348 --log
```

EXIT_CODE: 0

- Fail-before run (fail-open, no fix): https://github.com/drmoisan/drm-copilot/actions/runs/29970355445 (red, headSha e09c0e92)
- Pass-after run (CR-1 fix applied): https://github.com/drmoisan/drm-copilot/actions/runs/29970805348 (green, headSha 8ba4fb79)

## Paired fail-before / pass-after per new test

| Plan task | TAP # / suite | Fail-before (29970355445) | Pass-after (29970805348) |
|---|---|---|---|
| P2-T4 | enumeration #41 — `parse_worktree_list returns non-zero and emits no records on a git worktree-list hard failure` | `not ok 41` | `ok 41` |
| P2-T5a | classification #9 — `worktree_list_error: classify_branch reports ANCESTRY_ERROR, never a delete-eligible verdict` | `not ok 9` | `ok 9` |
| P2-T5b | classification #10 — `worktree_list_error: run_report returns non-zero and emits no MERGED or WORKTREE lines` | `not ok 10` | `ok 10` |
| P2-T6 | classification #11 — `cherry_error: classify_branch reports ANCESTRY_ERROR on a git cherry hard failure` | `not ok 11` | `ok 11` |
| P2-T7 | classification #12 — `rev_list_error: classify_branch returns non-zero with no fabricated COMMIT record` | `not ok 12` | `ok 12` |

## Result

Both runs report TAP plan `1..85`. The fail-before run had exactly these 5 failures with all 80 pre-existing tests green; the pass-after run has 0 failures (85/85). Each new hard-failure test flips from `not ok` to `ok` between the two runs, and no pre-existing test regressed.

Output Summary: One fail-before and one pass-after observation are paired for every new test (P2-T4..P2-T7). The 5 tests transition from red (run 29970355445) to green (run 29970805348) once the CR-1 fix lands; the 80 pre-existing tests stay green across both runs.
