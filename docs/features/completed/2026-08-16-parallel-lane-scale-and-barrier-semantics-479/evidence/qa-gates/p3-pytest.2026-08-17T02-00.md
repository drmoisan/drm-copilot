# Phase 3 Gate Suite (Issue #479, [P3-T12])

Timestamp: 2026-08-17T02-00

Command:
```
poetry run black .
poetry run ruff check .
poetry run pyright
poetry run pytest tests/scripts/dev_tools -q
poetry run pytest tests/scripts/dev_tools -q --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

EXIT_CODE: 0 / 0 / 0 / 1 / 0

## Output Summary

- `black .` -> `419 files left unchanged`.
- `ruff check .` -> `All checks passed!`
- `pyright` -> `0 errors, 0 warnings, 0 informations`
- `pytest tests/scripts/dev_tools -q` -> `1 failed, 3796 passed, 5 skipped in 5.55s`.
- Same suite with only the environmentally-blocked test deselected ->
  `3796 passed, 5 skipped, 1 deselected in 4.62s`.

Passing count rose from Phase 2's 3705 to 3796 (+91): 43 lane-assertion tests, 22 M8 contract
tests, and 26 additional parity-corpus assertions from the 13 new shared M8 fixtures.

The single failure is the Phase 0 pre-existing environmental
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` (gitignored
`.claude/worktrees/` live worktree). Mirror byte-identity was independently verified over all
161 tracked `.claude` files: zero missing, zero differing.

## AC coverage

- **AC25** — `test_parallel_manifest_contract_m8.py::TestM8KeyAbsent` proves the key-gated
  guarantee, including a byte-identical error-list comparison against the recorded pre-change
  expectation.
- **AC26** — all M8 negative paths (non-list value, non-object entry, missing `members`, empty
  `members`, non-list `members`, non-positive member, boolean member, non-integer member,
  unresolved member, duplicate membership across components and within one component,
  empty-string `name`, whitespace-only `name`, and the name-then-members field ordering) plus
  the named and unnamed block-sequence positive paths pass.
- **AC27 (Python lane)** — `test_parallel_manifest_bash_parity.py` passes over the extended
  54-fixture corpus (104 passed, 5 pre-existing skips).
- **AC28** — `test_parallel_lane_assertion.py` passes with 100% line and 100% branch coverage
  on the new module (recorded in `p3-lane-assertion-coverage.2026-08-17T01-30.md`).
