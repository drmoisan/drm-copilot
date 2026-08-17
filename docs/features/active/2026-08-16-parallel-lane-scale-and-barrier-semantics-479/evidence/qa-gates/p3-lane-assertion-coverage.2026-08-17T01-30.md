# Lane-Assertion Module Coverage (Issue #479, [P3-T4], AC28)

Timestamp: 2026-08-17T01-30

Command:
```
poetry run pytest tests/scripts/dev_tools/test_parallel_lane_assertion.py \
  --cov=scripts.dev_tools.parallel_lane_assertion --cov-branch --cov-report=term
```

EXIT_CODE: 0

## Output Summary

```
Name                                           Stmts   Miss Branch BrPart  Cover
--------------------------------------------------------------------------------
scripts\dev_tools\parallel_lane_assertion.py     143      0     44      0   100%
--------------------------------------------------------------------------------
TOTAL                                            143      0     44      0   100%
43 passed in 0.24s
```

- Line coverage: **100.00%** (143 of 143 statements; 0 missed) — threshold `>= 85`, met.
- Branch coverage: **100.00%** (44 of 44 branch exits; 0 partial) — threshold `>= 75`, met.
- Tests: **43 passed**, 0 failed.
- Module size: `scripts/dev_tools/parallel_lane_assertion.py` = **499 lines** (`<= 500`).
- Test-module size: `tests/scripts/dev_tools/test_parallel_lane_assertion.py` = **395 lines**.

## Dotted-module `--cov` form

The DOTTED module form `--cov=scripts.dev_tools.parallel_lane_assertion` is required and was
used. The path forms `--cov=scripts/dev_tools/parallel_lane_assertion` and
`--cov=scripts/dev_tools/parallel_lane_assertion.py` resolve no module and collect no data
(coverage.py reports `Module ... was never imported` / `No data was collected`), which would
make the threshold vacuous rather than failing loudly.

## Scenarios covered

| Requirement | Tests |
|---|---|
| Isolated vertices | `test_isolated_vertices_each_form_their_own_component`, `test_a_self_loop_is_skipped`, `test_an_edge_naming_an_unknown_vertex_is_skipped` |
| Chains | `test_a_chain_is_one_component`, `test_two_disjoint_groups_are_two_components`, `test_edge_direction_and_repetition_are_normalized_away` |
| 13-lane transpose (13 components over 69 items, all confirmed) | `test_the_thirteen_lane_transpose_yields_thirteen_components`, `test_the_transpose_assertion_is_confirmed_with_no_disagreement` |
| Report class: expected-together-but-derived-apart | `test_expected_together_but_derived_apart_is_reported` |
| Report class: expected-apart-but-derived-together | `test_expected_apart_but_derived_together_is_reported` |
| Report class: member naming no manifest item | `test_a_member_naming_no_manifest_item_is_reported` |
| Report class: item covered by no expected component (informational) | `test_an_uncovered_item_is_reported_informationally`, `test_an_absent_assertion_reports_only_uncovered_items` |

Additional coverage: value objects (`label` named/unnamed, `disagreement_count` excluding the
informational class), the advisory renderer, defensive manifest reading (non-list assertion,
non-mapping entry, non-list `members`, non-string `name`, non-positive/non-integer members,
malformed `items`), the `<a>:<b>` edge parser, and the CLI (missing file, unparseable file,
and the checked-in fixture manifest happy path, all exiting 0).

No test creates a temporary file. The CLI paths read only checked-in files
(`tests/fixtures/parallel_manifest_payload/parallel.md`, `pyproject.toml`) and a path that
does not exist.
