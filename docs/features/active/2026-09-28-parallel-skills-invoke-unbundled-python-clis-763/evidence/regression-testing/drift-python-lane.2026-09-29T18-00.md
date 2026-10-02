# Python Drift Parity Lane (P3-T6)

Timestamp: 2026-09-29T18-00
Command: poetry run pytest -v tests/scripts/dev_tools/test_parallel_drift_parity.py
EXIT_CODE: 0
Output Summary:
- `20 passed in 0.09s`; no FAILED line.
- PASSED: `test_drift_corpus_meets_floor`, `test_drift_corpus_covers_every_named_case`
- 15 `test_reference_matches_fixture_payload[...]` nodes PASSED: escape-without-conflict,
  halt-both-starts-absent, halt-drifter-started-later, halt-equal-start-timestamps, halt-one-pair,
  halt-one-start-absent, halt-several-pairs, malformed-peer-radius-fails-closed,
  no-escape-empty-changed-paths, no-escape-inside-radius, non-object-edge-ignored,
  peer-not-in-flight-ignored, peer-radius-iso-timestamp-evaluated, reversed-existing-edge-not-new,
  tolerated-overlap-under-conflict-tolerance
- 3 `test_reference_reports_fixture_error[...]` nodes PASSED: error-item-key-missing,
  error-items-not-a-list, error-non-object-root
- Together the 18 parametrized nodes cover each C1 name exactly once.
