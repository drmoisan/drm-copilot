# Phase 4 Verification Gate — Python Toolchain and Test Counts — Issue #440 (F7)

Timestamp: 2026-08-08T22-24

Scope: the delegation verification gate for Phase 4 plus Absorptions A and B. This is not a plan task
artifact; the authoritative final Python QC numbers come from [P5-T4] through [P5-T7].

## Commands and Results

| Stage | Command | EXIT_CODE | Result |
| --- | --- | --- | --- |
| Format | `poetry run black .` | 0 | `376 files left unchanged` (no file rewritten) |
| Lint | `poetry run ruff check .` | 0 | `All checks passed!` |
| Type check | `poetry run pyright` | 0 | `0 errors, 0 warnings, 0 informations` |
| Test (gate scope) | `poetry run pytest tests/scripts/dev_tools/ -q` | 0 | `2950 passed` |
| Test (baseline scope) | `poetry run pytest -q` | 0 | `3038 passed` |

The loop completed in a single clean pass; no stage failed and no stage rewrote a file, so no restart was
required.

## Comparison Against the P0-T8 Baseline

The [P0-T8] baseline of `3007 passed / 0 failed` was captured with
`poetry run pytest --cov --cov-branch --cov-report=term-missing` from the repository root, i.e. the FULL
suite (see `evidence/baseline/python-tests-coverage.2026-08-08T20-57.md`). The like-for-like comparison is
therefore the full-suite run.

| Scope | Baseline | Now | Delta |
| --- | --- | --- | --- |
| Full suite (`poetry run pytest -q`) | 3007 passed / 0 failed | 3038 passed / 0 failed | +31 passed, failures unchanged at 0 |
| `tests/scripts/dev_tools/` subset | not separately baselined | 2950 passed / 0 failed | n/a |

The +31 delta is this feature's added Python tests (the [P3-T2] cohort-barrier suite). No test was removed
and no test regressed: failures remain 0 at both scopes.

## Six Escalated Failures — All Resolved

| # | Test | Status |
| --- | --- | --- |
| 1 | `test_validate_parallel_orchestrator_state_structures.py::test_invariant_15_accepts_a_normalized_edge` | PASS |
| 2 | `..._structures.py::test_invariant_15_accepts_every_edge_reason[path_overlap]` | PASS |
| 3 | `..._structures.py::test_invariant_15_accepts_every_edge_reason[module_overlap]` | PASS |
| 4 | `..._structures.py::test_invariant_15_accepts_every_edge_reason[shared_surface_overlap]` | PASS |
| 5 | `..._structures.py::test_invariant_15_accepts_every_edge_reason[contract_dependency]` | PASS |
| 6 | `test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` | PASS |

Failures 1-5 were repaired by Absorption A
(`evidence/other/absorption-a-f3-fixture-repair.2026-08-08T22-24.md`); failure 6 by Absorption B
(`evidence/other/absorption-b-push-down-mirror.2026-08-08T22-24.md`).

Two additional failures surfaced during the gate as mechanical consequences of required work and were
repaired with the narrowest edits; both are documented and escalated in
`evidence/other/phase4-consequential-repairs.2026-08-08T22-24.md`.

## PowerShell Note

Phase 4 changed no PowerShell source. The two PowerShell files added under the bundle by Absorption B are
byte-identical copies of hooks that already cleared the [P1-T5]/[P1-T6] and [P2-T5]/[P2-T6] PoshQC format
and analyzer gates, verified by matching SHA-256 hashes. The authoritative post-change PowerShell gates
are [P5-T1] through [P5-T3], which are outside this delegation's scope and were not run here.

EXIT_CODE: 0

Output Summary: PASS. The Python toolchain completed a single clean pass — black reported 376 files
unchanged, ruff reported all checks passed, and pyright reported 0 errors/0 warnings/0 informations.
`poetry run pytest tests/scripts/dev_tools/ -q` reports `2950 passed` with 0 failed, and the like-for-like
full-suite run `poetry run pytest -q` reports `3038 passed` with 0 failed against the P0-T8 full-suite
baseline of 3007 passed / 0 failed, a delta of +31 passed attributable to this feature's new Python tests
with failures unchanged at 0. All six escalated failures now pass: the five F3 invariant-15 acceptance
tests via Absorption A and the push-down contract test via Absorption B. Two further failures that
appeared as mechanical consequences of P4-T4 and Absorption B were repaired narrowly and are escalated
separately. Phase 4 changed no PowerShell source; the authoritative PowerShell gates remain P5-T1 through
P5-T3 and were not run here.
