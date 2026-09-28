# Property-Test Framework Deviation (P1-T8, AC-15)

Timestamp: 2026-09-27T15-17
Command: poetry run python -c "import hypothesis"; poetry show hypothesis
EXIT_CODE: 1
ExpectedExitCode: 1
Output Summary: The hypothesis package is not installed in the project environment ("ModuleNotFoundError: No module named 'hypothesis'"; "Package hypothesis not found"). Block B11 and AC-15 name hypothesis. The four B11 properties were written under their exact B11 test names as exhaustive checks over a fixed finite domain (13 radius templates, every ordered pair, 9 band combinations, 9 tolerances, 3 truth tables). The four properties asserted are the ones B11 and AC-15 list.

## Printed output

```text
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    import hypothesis
ModuleNotFoundError: No module named 'hypothesis'

Package hypothesis not found
```

## Why the dependency was not added

- hypothesis is not a direct or dev dependency in the project's pyproject.toml; it appears in the lock
  file only as an optional extra of a third-party package.
- The existing property suites state that hypothesis is absent and stays absent (the module
  docstrings of tests/scripts/dev_tools/test_parallel_mutation_contention_properties.py and
  tests/scripts/dev_tools/test_blast_radius_invariants.py).
- Adding a dependency is a new independent outcome that the approved plan does not contain (no task
  edits pyproject.toml or poetry.lock), and repository policy permits new dependencies only when
  explicitly directed.

## Why a seeded pseudo-random generator was not used either

A first version used a seeded random.Random generator, the convention of the existing seeded
property suites. Ruff reported S311 on each generator construction. The existing suites carry a
per-file S311 ignore in pyproject.toml; S311 is not a pre-authorized suppression in
.claude/rules/python-suppressions.md, and pyproject.toml is not a file this plan writes. The
generator was therefore replaced by exhaustive enumeration, which needs no suppression and checks
every point of the domain rather than a sample.

## Substitute and why it proves the same properties

File: tests/scripts/dev_tools/test_blast_radius_scheduling_properties.py (197 lines).

| B11 test name | Property asserted at every domain point |
| --- | --- |
| test_property_edge_implies_conflict | decision.edge implies the relation's verdict, at all nine tolerances |
| test_property_tolerance_zero_equals_conflict | at tolerance_percent 0, decision.edge equals the relation's verdict |
| test_property_monotone_in_tolerance | over ascending tolerances the edge sequence never goes from False back to True |
| test_property_symmetric_decision | decide(a, b) equals decide(b, a) with the bands swapped (full record equality), at all nine tolerances |

Domain: 13 radius templates (empty; concrete file; listed directory; file plus document; glob with
module; document glob with module; append-only file; append-only glob plus test file; mergeable
project file plus source file with two modules; test file with shared surface; module with shared
surface; document with contract; contract with module), all 169 ordered pairs (self pairs
included), bands None, C2, and C4 on each side (9 combinations), tolerances 0, 1, 50, 99, 100, 150,
400, 800, and 1000000, and three truth tables (committed weights; unit weights; skewed weights with
default_band C3). Each property is parametrized over the three truth tables.

Discrimination over the domain (13,689 decisions per truth table), measured with
SCRATCH/prop-discrimination.py:

```text
DISCRIMINATION member=committed {'points': 13689, 'conflict': 4698, 'edge': 3026, 'tolerated': 1672, 'hard': 648} edge_to_tolerated_transitions=450
DISCRIMINATION member=unit {'points': 13689, 'conflict': 4698, 'edge': 2646, 'tolerated': 2052, 'hard': 648} edge_to_tolerated_transitions=450
DISCRIMINATION member=skewed {'points': 13689, 'conflict': 4698, 'edge': 3629, 'tolerated': 1069, 'hard': 648} edge_to_tolerated_transitions=450
```

The domain contains conflicts, edges, tolerated overlaps, hard pairs, and pairs that change from edge
to tolerated as the tolerance rises, so none of the four properties holds vacuously.

## Acceptance-criterion consequence

AC-15 reads "Hypothesis property tests cover: edge implies conflict; tolerance 0 equals conflict;
monotonicity in tolerance_percent; symmetry." The four listed properties are covered by the tests
above. The framework named in the criterion is not used. AC-15 is checked off in P1-T15 on the
strength of property coverage, with this deviation cited in the check-off artifact and reported to
the caller.

SCRATCH denotes the executor session scratchpad directory (outside the repository).
