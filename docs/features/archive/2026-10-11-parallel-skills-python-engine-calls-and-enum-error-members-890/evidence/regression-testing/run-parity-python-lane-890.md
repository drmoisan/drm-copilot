# Run-Mutation Parity: Python Reference Lane (Issue #890)

Timestamp: 2026-10-12T20-20
Task: P1-T9 (also records the P1-T7 fixture count and stem set)
Command: `poetry run pytest tests/scripts/dev_tools/test_parallel_mutation_run_bash_parity.py`
EXIT_CODE: 0
Output Summary: `25 passed in 0.12s` (4 structural tests plus 21 parametrized fixture cases); no failures.

corrections: none — every Reference R4 literal equals the Python reference output for the same argv.

## Fixture count (P1-T7)

Glob tool, pattern `tests/fixtures/parallel_mutation_run/*.json`: 21 paths. The stem set equals the R4 stem column exactly (also asserted by `test_corpus_matches_required_cases`).

`recolor-pinned-edge-offset.json` and `recolor-overlap.json` were copied byte-for-byte from `tests/fixtures/parallel_mutation_remove/` with `cp`; the other 19 were written with the Write tool.

## Fixture stems (21)

1. admit-no-conflict
2. admit-conflict-in-flight
3. admit-conflict-scheduled-member
4. admit-conflict-outside-cohort
5. recolor-pinned-edge-offset
6. recolor-overlap
7. add-entry-admit
8. add-entry-deferred
9. add-entry-deferred-generation-minus-one
10. add-entry-negative-generation
11. add-entry-non-positive-item
12. close-permitted
13. close-in-flight
14. close-unknown-state
15. close-non-positive-key
16. close-entry
17. close-entry-negative-generation
18. requeue-entry
19. requeue-entry-generation-minus-one
20. requeue-entry-negative-generation
21. requeue-entry-non-positive-item
