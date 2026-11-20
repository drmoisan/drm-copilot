# Baseline — Python Tests and Coverage (Pytest) — Issue #475

Timestamp: 2026-08-15T19-21

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing` (run from the worktree root `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-afc9f4fd25ec235a5`)

EXIT_CODE: 0

Output Summary:

**Test results:**
- Passed: 3785
- Failed: 0
- Errors: 0
- Skipped: 5 (all five in `tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py:231`, each with the reason `manifest_m1_* declares no accessor expectation` — pre-existing, unrelated to this feature)
- Wall time: 15.46 s
- Platform: win32, Python 3.13.12-final-0

**Coverage headline values.** The `term-missing` report's `TOTAL` row prints the combined line-plus-branch figure (90%), which is not the line coverage figure the policy floors are stated against. Exact totals were therefore read from the coverage database via `poetry run coverage json`:

| Metric | Covered | Total | Percent | Floor | Status |
| --- | --- | --- | --- | --- | --- |
| **Line (statement) coverage** | 13288 | 14396 | **92.30%** | >= 85% | Met (7.30 points headroom) |
| **Branch coverage** | 4476 | 5286 | **84.68%** | >= 75% | Met (9.68 points headroom) |
| Combined (as displayed by `term-missing` TOTAL) | — | — | 90.26% | — | — |

Supporting raw totals from the coverage JSON:

```
covered_lines: 13288, num_statements: 14396, missing_lines: 1108, excluded_lines: 418
percent_statements_covered: 92.30341761600445
num_branches: 5286, covered_branches: 4476, missing_branches: 810, num_partial_branches: 556
percent_branches_covered: 84.67650397275823
percent_covered (combined): 90.25505538055076
```

An LCOV report was also written by the run to `artifacts/python/lcov.info` (a tool-native output path configured in the repository, not an evidence artifact of this plan).

## Known-Red Window Recorded in Advance

Per the plan's Sequencing Rationale, the Python bundle-parity test `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` enumerates every repository `.claude/**` file and asserts bundle presence plus byte identity. It passes at this baseline. It becomes expectedly red from the first new `.claude/lib/**` module created in `[P2-T2]` until the bundle mirror and manifest registration complete in Phase 12 (through `[P12-T8]`). No planned task runs pytest inside that window; `[P12-T10]` is the first. Any opportunistic pytest run inside the window must record that test as the in-progress mirror state, not as a regression against this baseline.

Phases 0 through 3 (the scope of this execution) create `.claude/lib/discovery-validation/DiscoveryValidation.psm1` at `[P2-T2]`, so this baseline is the last full-green Python state before that window opens.
