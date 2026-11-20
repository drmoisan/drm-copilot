# Fail-before: recorded_at blank-set corpus rows ([P1-T2], expect-fail)

Timestamp: 2026-11-14T01-01
Command: bash SCRATCH/issue-1161-failbefore.sh (in the item worktree: `env -u VIRTUAL_ENV poetry run pytest -n auto -q -rf --no-cov tests/scripts/dev_tools/test_validate_epic_planner_state_planner_worktrees.py`, then in `extensions/drm-copilot`: `node run-jest.cjs --verbose test/lib/validate/epic-planner-state-planner-worktrees.test.ts`)
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: Validators unchanged (CycleStartHead content); corpus at 21 files. Exactly three rows fail, as planned. Python: 2 failed, 44 passed (exit 1). Jest: 1 failed, 45 passed (exit 1). Every other row passes. `git status --porcelain` identical before and after, so the task left the tree unchanged.

## Failing rows

| Runtime | Row | Observed | Expected by fixture |
|---|---|---|---|
| Python | `test_validator_reproduces_the_corpus_errors[recorded-at-unit-separator]` | the `recorded_at` error (`str.strip()` removes U+001F) | no error |
| Python | `test_validator_reproduces_the_corpus_errors[recorded-at-next-line]` | the `recorded_at` error (`str.strip()` removes U+0085) | no error |
| TypeScript | `planner_worktrees validator parity › reproduces the expected errors for recorded-at-byte-order-mark` | the `recorded_at` error (`trim()` removes U+FEFF) | no error |

Each runtime's native whitespace set disagrees with the shared blank set RB-1 on a different character, so reverting either runtime to its native strip or trim fails that runtime's parity suite. The row `blank-recorded-at-ascii-controls` passes in both runtimes before the change, because all six RB-1 characters are in both native sets.
