# P3-T1 final bounded probe: provider

Timestamp: 2026-10-18T11-39
Command: poetry run python 'SCRATCH/issue-980-p3t1-provider-probes.py'
EXIT_CODE: 0
Output Summary: Three provider correction probes passed: owned stage cleanup, actual opened parent identity and configured larger originals. Memory-only injected OS checks; real Windows smoke remains separate.

The source hashes were stable throughout this command. Exact results and hashes are in [p3t1-executor-provider-probes-final.2026-10-18T11-39.json](p3t1-executor-provider-probes-final.2026-10-18T11-39.json). This is bounded task evidence, not final task or feature acceptance.

```text
{"name": "Owned partial stage is removed on failure", "passed": true, "details": {"close_calls": 1, "remove_calls": 1, "message": "Injected partial write", "foreign_remove_calls": 0}}
{"name": "Opened parent identity must match recorded stamp", "passed": true, "details": {"error": "Opened mutation parent identity changed", "resulting_content": "original", "events": [["enter", "."], ["enter", "docs"], ["enter", "docs/observations"], ["exit", "docs/observations"], ["exit", "docs"], ["exit", "."]]}}
{"name": "Configured larger original is not rejected by a fixed default limit", "passed": true, "details": {"error": null, "original_size": 16777217, "profile_schema_maximum": 67108864, "events": [["enter", "."], ["enter", "docs"], ["enter", "docs/observations"], ["stage", "docs/observations/.drm-mutation-owned-stage"], ["read-limit", 33554432], ["publish", "docs/observations/value.txt"], ["remove", "docs/observations/.drm-mutation-owned-stage"], ["exit", "docs/observations"], ["exit", "docs"], ["exit", "."]]}}
```
