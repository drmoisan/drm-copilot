# P3-T2 independent bootstrap-boundaries

Timestamp: 2026-10-18T13:13:36Z

Command: `poetry run python SCRATCH/issue-980-p3t2-boundaries.py`

EXIT_CODE: 0

## Output Summary

Behavioral assertions: 2/5 passed. The collecting diagnostic process exited zero; this does not convert a failed assertion into success. Source hashes remained unchanged during this command. This is a pre-gate review of persisted drafts, not task acceptance.

- PASS: unchanged-bootstrap-postcondition-control.
- PASS: old-directory-identity-substitution-rejected.
- FAIL: new-directory-identity-substitution-rejected — Post-bootstrap validation accepted substituted identity of newly created docs/migration/discovery/evidence.
- FAIL: bootstrap-capture-rejects-post-open-directory-substitution — Guarded bootstrap reported success after opened new-directory identity substitution.
- FAIL: invalid-existing-artifact-has-structured-conflict — Existing artifact conflict has no typed path/status result; only ValueError: Existing initialization artifact is invalid: docs/migration/discovery/coverage-ledger.json.

Captured result time: 2026-10-18T13:12:30.881317+00:00. Exact structured results and before/after source hashes: [p3t2-executor-bootstrap-boundaries.2026-10-18T13-13.json](p3t2-executor-bootstrap-boundaries.2026-10-18T13-13.json).

The check used memory adapters. No production code, consumer repository, plan checkbox, or acceptance criterion was changed. The earlier four failed accessor cases remain in the separate 13-06 receipt.
