# Isolation Runs — Final Pass on the Merged Tree

Timestamp: 2026-10-17T01-47
Task: [P6-T9]
Command: sh SCRATCH/issue-964-jest-seeds.sh 964964 20261016 31337; poetry run python SCRATCH/issue-964-pytest-reverse.py <the nine new or modified Python test modules>; sh SCRATCH/issue-964-pester-shuffle.sh 964 20261016 31337; the [P6-T6] final single-process Pester run
EXIT_CODE: 0
Output Summary:
- Seeded randomized Jest (seeds 964964, 20261016, 31337): 4103 of 4103 tests passed for each seed.
- Python reverse collection order, one process: 88 passed, 0 failed.
- Seeded shuffled Pester file order (seeds 964, 20261016, 31337), one process: Passed=897 Failed=0 for each seed; FAILED_RUNS=0; order dependence: none found.
- Fresh single-process Pester over `tests/scripts` (2026-10-17T01-44 to 02-03): 11055 tests, 0 failures.
- These runs repeat `jest-seeded.2026-10-17T01-21.md`, `python-reversed.2026-10-17T01-21.md`, `pester-seeded-shuffle.2026-10-17T01-21.md`, and `pester-single-process.2026-10-17T01-39.md` after the merge of `origin/main` (PR #965); file orders per seed are identical to those recorded in the shuffle artifact, because the file set did not change.
