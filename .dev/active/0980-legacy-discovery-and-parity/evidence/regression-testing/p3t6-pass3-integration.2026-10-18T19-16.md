# p3t6-pass3-integration

Timestamp: 2026-10-18T19-16
Command: poetry run python SCRATCH\issue-980-p3t6-api-composed.py
EXIT_CODE: 0
Output Summary: {"name": "staged input and unrelated profile bytes preserved", "passed": true, "details": null}; {"name": "identical repeated import performs no publication", "passed": true, "details": null}; {"name": "staged byte change invalidates a previously valid import plan", "passed": true, "details": ["Finding(code='MUTATION_FAILED', message='MUTATION_STALE: Complete input state changed; reload', next_action='Reload all inputs, inspect partial/uncertain paths, and revalidate before retrying.', severity='error', artifact_path=None, pointer='', related_ids=(), related_paths=())"]}; {"passed": 11, "total": 11, "failure": null, "stable": true, "elapsed_seconds": 123.40642499999376}

Working directory: .
Started: 2026-10-18T19:14:49.510353+00:00
Duration seconds: 124.449
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
{"name": "actual export prospective graph", "passed": true, "details": null}
{"name": "export dry run has no writes or invalidation", "passed": true, "details": null}
{"name": "export creates exact bytes with manifest last", "passed": true, "details": []}
{"name": "source original bytes preserved", "passed": true, "details": null}
{"name": "new-destination import complete graph with staging retained", "passed": true, "details": []}
{"name": "import dry run preserves directories bytes and authority", "passed": true, "details": null}
{"name": "partial failure is explicit and manifest remains absent", "passed": true, "details": ["created", "conflict"]}
{"name": "partial import recovery preserves existing member and creates missing files", "passed": true, "details": []}
{"name": "staged input and unrelated profile bytes preserved", "passed": true, "details": null}
{"name": "identical repeated import performs no publication", "passed": true, "details": null}
{"name": "staged byte change invalidates a previously valid import plan", "passed": true, "details": ["Finding(code='MUTATION_FAILED', message='MUTATION_STALE: Complete input state changed; reload', next_action='Reload all inputs, inspect partial/uncertain paths, and revalidate before retrying.', severity='error', artifact_path=None, pointer='', related_ids=(), related_paths=())"]}
{"passed": 11, "total": 11, "failure": null, "stable": true, "elapsed_seconds": 123.40642499999376}
```
