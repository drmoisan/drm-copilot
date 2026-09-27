# Phase 3 Python Consumer Run (P3-T2)

Timestamp: 2026-09-27T15-16

Command: poetry run pytest tests/scripts/dev_tools/test_blast_radius_regression_452.py -v

EXIT_CODE: 0

Tolerance branch: NOT FOUND (P0-T29).

Full output (interpreter path replaced with `<worktree root>`-relative form; rootdir shown as `<worktree root>`):

```
============================= test session starts =============================
platform win32 -- Python 3.13.12, pytest-9.0.2, pluggy-1.6.0
cachedir: .pytest_cache
rootdir: <worktree root>
configfile: pyproject.toml
plugins: anyio-4.12.1, cov-7.0.0
collecting ... collected 26 items

tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_corpus_top_level_shape_matches_the_contract PASSED [  3%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_every_case_matches_the_case_shape_contract PASSED [  7%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_corpus_case_ids_are_unique_and_equal_the_spec_case_list PASSED [ 11%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_every_expected_verdict_matches_its_direction PASSED [ 15%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_every_pairing_resolves_to_an_opposite_direction_case_of_the_same_gap PASSED [ 19%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_each_gap_has_a_must_conflict_and_a_must_not_conflict_case PASSED [ 23%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_every_plan_line_follows_the_plan_line_intent_rule PASSED [ 26%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g1-plan-poetry-lock] PASSED [ 30%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g1-plan-package-lock] PASSED [ 34%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g1-plan-different-surfaces] PASSED [ 38%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g1-plan-unconfigured-root-file] PASSED [ 42%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g1-plan-quality-tiers-mandate-read] PASSED [ 46%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g1-radius-quality-tiers] PASSED [ 50%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g1-radius-quality-tiers-vs-poetry-lock] PASSED [ 53%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g2-dir-vs-glob] PASSED [ 57%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g2-glob-vs-dir] PASSED [ 61%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g2-dir-vs-sibling-glob] PASSED [ 65%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g2-sibling-glob-vs-dir] PASSED [ 69%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g2-artifacts-dir-vs-glob] PASSED [ 73%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g2-artifacts-glob-vs-dir] PASSED [ 76%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g2-artifacts-dir-vs-sibling-glob] PASSED [ 80%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g2-artifacts-sibling-glob-vs-dir] PASSED [ 84%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g2-empty-modules-dir-vs-glob] PASSED [ 88%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_case_verdict_matches_corpus[g2-empty-modules-dir-vs-sibling-glob] PASSED [ 92%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_bundled_separator_free_shared_surfaces_equal_the_self_hosted_subset PASSED [ 96%]
tests/scripts/dev_tools/test_blast_radius_regression_452.py::test_strictest_tolerance_keeps_a_scheduling_edge_for_every_must_conflict_case SKIPPED [100%]

=========================== short test summary info ===========================
SKIPPED [1] tests\scripts\dev_tools\test_blast_radius_regression_452.py:483: Issue #722 tolerance layer absent at execution start (Phase 0 detection NOT FOUND); detection-level verdicts for every must-conflict case are recorded as evidence instead.
======================== 25 passed, 1 skipped in 0.09s ========================
```

Output Summary: EXIT_CODE 0; "25 passed, 1 skipped"; 26 collected; exactly 17 progress lines contain "::test_case_verdict_matches_corpus[" and "PASSED" (one per case id, including g1-plan-quality-tiers-mandate-read and g1-radius-quality-tiers); the short test summary contains exactly one SKIPPED line, whose reason contains "#722". The corpus meta-tests (shape, ids, direction, pairing, both directions per gap, plan-line intent) and the bundled-parity test pass. The consumer was first formatted with Black before this run (authoring step, before its phase commit); after that Black reported "1 file left unchanged.", Ruff "All checks passed!", Pyright "0 errors", and the file is 487 lines.
