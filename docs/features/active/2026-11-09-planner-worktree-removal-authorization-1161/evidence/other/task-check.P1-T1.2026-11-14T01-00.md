# Task check P1-T1 (remediation cycle 1)

Timestamp: 2026-11-14T01-00
Command: bash SCRATCH/issue-1161-tc-p1t1.sh (in the item worktree; steps listed below)
EXIT_CODE: 0
Output Summary: Static checks clean on every changed file. The four new fixtures parse as JSON, hold only ASCII bytes (the `recorded_at` values are the escape text `\ufeff`, `\u001f`, `\u0085`, and ` \t\n\r\u000b\u000c`), and contain no absolute host path. Both count tests pass (`test_corpus_holds_the_planned_file_count`, `holds exactly the planned number of files`). The corpus suites report only the expected fail-before rows that P1-T2 records: Python 2 failed, 44 passed; Jest 1 failed, 45 passed.

Changed files: `tests/fixtures/epic_planner_state_planner_worktrees/recorded-at-byte-order-mark.json`, `recorded-at-unit-separator.json`, `recorded-at-next-line.json`, `blank-recorded-at-ascii-controls.json` (new); `tests/scripts/dev_tools/test_validate_epic_planner_state_planner_worktrees.py`; `extensions/drm-copilot/test/lib/validate/epic-planner-state-planner-worktrees.test.ts`.

Selection rule: the test files that read the changed corpus directory or are themselves changed: the Python corpus module and the TypeScript corpus file.

| Step | Command | EXIT_CODE | Result |
|---|---|---|---|
| Black check | `env -u VIRTUAL_ENV poetry run black --check` on the Python test file | 0 | `1 file would be left unchanged.` |
| Ruff | `env -u VIRTUAL_ENV poetry run ruff check` on the Python test file | 0 | `All checks passed!` |
| Pyright | `env -u VIRTUAL_ENV poetry run pyright` on the Python test file | 0 | 0 errors, 0 warnings, 0 informations |
| Prettier check (fixtures) | `npx prettier --check` on the four new fixtures | 0 | `All matched files use Prettier code style!` |
| Fixture checks | JSON parse, non-ASCII byte count, absolute-path pattern count per file | 0 | 4 parse-ok, 0 non-ASCII lines, 0 path hits each |
| pytest | `env -u VIRTUAL_ENV poetry run pytest -n auto -q <Python corpus module> --no-cov` | 1 | 2 failed, 44 passed; failures are `[recorded-at-next-line]` and `[recorded-at-unit-separator]` of `test_validator_reproduces_the_corpus_errors` (expected before P1-T3) |
| Prettier check (TS test) | `npx prettier --check` on the TS test file | 0 | clean |
| ESLint (TS test) | `npx eslint` on the TS test file | 0 | 0 findings |
| tsc (jest config) | `npx tsc -p tsconfig.jest.json --noEmit` | 0 | 0 errors |
| Jest | `node run-jest.cjs test/lib/validate/epic-planner-state-planner-worktrees.test.ts` | 1 | 1 failed, 45 passed (expected before P1-T4) |
