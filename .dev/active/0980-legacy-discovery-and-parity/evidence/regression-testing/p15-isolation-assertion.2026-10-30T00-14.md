# P15-T19 — Registry-isolation assertion can fail

Task: [P15-T19] Make the registry-isolation assertion able to fail.
Branch: feature/legacy-discovery-and-parity-980
Issue: #980
Test: `tests/discovery_runtime/test_schema_validation.py::test_repeated_validations_through_one_catalog_are_independent`

## Change

- `before` is now `copy.deepcopy` of the resolved `activation` schema contents,
  taken before the three validations; `after` remains the live lookup.
- A new assertion requires `catalog.registry()` to return the same object that
  was obtained before the validations.
- The docstring states the deep copy and the identity requirement.

Previously `before` and `after` were two references to the same live mapping, so
`after == before` compared an object with itself and could not fail.

## Suite run on the tree

Timestamp: 2026-10-30T00:13Z
Command: `poetry run pytest tests/discovery_runtime/test_schema_validation.py -p no:cacheprovider -q`
EXIT_CODE: 0
Output Summary: `60 passed in 3.82s`

## Probe run (SCRATCH/issue-980-p15-isolation-probe.py)

The probe is a copy of the test that, after the validations and before the
comparison, sets `title` on the live resolved contents to `mutated by the probe`.

Timestamp: 2026-10-30T00:14Z
Command: `poetry run pytest SCRATCH/issue-980-p15-isolation-probe.py --rootdir <repo root> -p no:cacheprovider -q`
EXIT_CODE: 1
Output Summary: `1 failed in 5.45s`; the failing line is `assert after == before` with
`AssertionError: ... Differing items: {'title': 'mutated by the probe'} != {'title': 'Discovery v2 activation locator'}`.
The earlier assertions (`shared == fresh`, result equality, `catalog.registry() is registry`) passed in the probe, so the failure is attributable to the mutation alone.

## Disposition

The probe was deleted after this record was written; it is not part of the tree.
`tests/discovery_runtime/test_schema_validation.py` is 426 lines (at or below 500).
