# Final Python Tests with Coverage (Issue #479, [P7-T4])

Timestamp: 2026-08-17T02-47

Command: `poetry run pytest --cov --cov-branch --cov-report=term-missing` (repo root)

EXIT_CODE: 1

## Output Summary

### Test counts

`1 failed, 3887 passed, 5 skipped in 18.65s`

Baseline (Phase 0) was `1 failed, 3784 passed, 5 skipped`. Net +103 passing tests. The one
failure and the five skips are the SAME items as at baseline:

- The failure is
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`,
  established as a pre-existing environmental condition at the untouched baseline commit
  `a43deb73` in `evidence/baseline/python-test-baseline.2026-08-16T23-55.md`. It fails because
  a live gitignored `git worktree` at `.claude/worktrees/agent-afc9f4fd25ec235a5/` places
  untracked agent log files inside the `.claude` tree the test enumerates with `rglob`. The
  directory does not exist in CI. Running the same suite with only that test deselected returns
  exit 0.
- The five skips are the pre-existing `manifest_m1_*` accessor-expectation skips in
  `test_parallel_manifest_bash_parity.py`.

Mirror parity, which that test would otherwise assert, was verified independently by direct
per-pair byte comparison over all 161 tracked `.claude` files: zero missing from the bundle,
zero byte-differing.

### Numeric repo-wide coverage

| Metric | Value | Baseline | Threshold | Result |
|---|---|---|---|---|
| Combined (`percent_covered` with `--cov-branch`) | **90.38%** | 90.25% | — | +0.13 |
| Line | **92.40%** (13479/14587) | 92.30% (13288/14396) | >= 85% | PASS, +0.10 |
| Branch | **84.88%** (4548/5358) | 84.66% (4475/5286) | >= 75% | PASS, +0.22 |

Both thresholds are met and both improved against baseline.

### Per-module values required by the plan

| Module | Line | Branch | Baseline line | Disposition |
|---|---|---|---|---|
| `scripts/dev_tools/parallel_lane_assertion.py` (NEW) | **100.00%** | **100.00%** | n/a | New module, both thresholds met |
| `scripts/dev_tools/parallel_mutation_protocol.py` (CHANGED) | **100.00%** | **100.00%** | 100% | At baseline |
| `scripts/dev_tools/parallel_manifest_contract.py` (CHANGED) | **100.00%** | **100.00%** | 100% | At baseline |

### Other modules touched by this feature

| Module | Line | Branch |
|---|---|---|
| `scripts/dev_tools/_parallel_mutation_models.py` (docstring only) | 100.00% | 100.00% |
| `scripts/dev_tools/_parallel_state_common.py` (docstring only) | 100.00% | 100.00% |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` (constant only) | 97.73% | 94.12% |
| `scripts/dev_tools/validate_parallel_planner_state.py` (constant only) | 100.00% | 100.00% |

`validate_parallel_orchestrator_state.py` reports the same 97%/94% it reported at baseline; its
only change is the one-line `MAX_CONCURRENCY` constant, which is a covered module-level
statement. No changed line in any module is uncovered.
