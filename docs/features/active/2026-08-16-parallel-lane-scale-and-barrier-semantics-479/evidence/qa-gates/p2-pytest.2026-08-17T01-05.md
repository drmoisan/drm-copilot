# Phase 2 Pytest Gate (Issue #479, [P2-T10])

Timestamp: 2026-08-17T01-05

Command:
```
poetry run black .
poetry run ruff check .
poetry run pyright
poetry run pytest tests/scripts/dev_tools -q
poetry run pytest tests/scripts/dev_tools -q --deselect tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
poetry run pytest tests/scripts/dev_tools -k "epic" -q
```

EXIT_CODE: 0 / 0 / 0 / 1 / 0 / 0

## Output Summary

- `black .` -> `416 files left unchanged` (the new `test_validate_parallel_planner_state_bounds.py` raised the file count from 415).
- `ruff check .` -> `All checks passed!`
- `pyright` -> `0 errors, 0 warnings, 0 informations`
- `pytest tests/scripts/dev_tools -q` -> `1 failed, 3705 passed, 5 skipped in 6.03s`. The one
  failure is the Phase 0 pre-existing environmental
  `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (gitignored
  `.claude/worktrees/` live worktree); byte-identity of all 161 tracked `.claude` files against
  the bundle was independently verified with zero missing and zero differing.
- Same suite with only that test deselected -> `3705 passed, 5 skipped, 1 deselected in 4.38s`.
- Passing count rose from the Phase 1 3698 to 3705: +1 manifest in-range case (32), +6 planner
  bounds cases in the new sibling module (3 plain + 3 ready-gate).

### Sub-gates covered by this run

| Gate | Result |
|---|---|
| `test_parallel_manifest_bash_parity.py` (Python parity lane over the migrated fixture corpus) | 78 passed, 5 pre-existing skips |
| `test_invariant_m4_accessor_resolves_concurrency` (the default-of-4 tests, unmodified) | passed |
| `pytest -k "epic"` (epic bound tests still pinning `1..8`) | `192 passed, 3519 deselected` |

Epic non-modification confirmed textually as well:
`scripts/dev_tools/validate_epic_orchestrator_state.py:121` and
`scripts/dev_tools/validate_epic_planner_state.py:312` still read
`max_parallel_features must be an integer from 1 through 8`.

## AC coverage

- AC16 (Python/bash parity half) — the parity corpus passes with the widened bound and the
  migrated exemplars.
- AC19 — the epic bound tests pass and still pin `1..8`.
- AC20 — the accessor default of 4 is unchanged and its tests pass unmodified.
- AC21 (pytest part) — accept-32 / reject-33 in all three Python modules plus the new sibling.
- AC23 (Python part) — boolean-rejection cases retained in every Python module.
