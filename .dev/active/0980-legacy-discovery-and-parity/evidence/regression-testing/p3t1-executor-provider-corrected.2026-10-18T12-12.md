# P3-T1 corrected provider verification

Timestamp: 2026-10-18T12-12
Command: poetry run python SCRATCH/issue-980-p3t1-provider-probes.py
EXIT_CODE: 0
Output Summary: Three provider correction cases passed on the corrected provider hash db2aca8b…; source bytes remained stable.

Exact proof and hashes: [p3t1-executor-provider-corrected.2026-10-18T12-12.json](p3t1-executor-provider-corrected.2026-10-18T12-12.json). The early six-case native smoke is diagnostic; the final ordered integration result and complete task gates remain required. P3-T1 is unchecked.

```text
{"name": "Owned partial stage is removed on failure", "passed": true, "details": {"close_calls": 1, "remove_calls": 1, "message": "Injected partial write", "foreign_remove_calls": 0}}
{"name": "Opened parent identity must match recorded stamp", "passed": true, "details": {"error": "Opened mutation parent identity changed", "resulting_content": "original", "events": [["enter", "."], ["enter", "docs"], ["enter", "docs/observations"], ["exit", "docs/observations"], ["exit", "docs"], ["exit", "."]]}}
{"name": "Configured larger original is not rejected by a fixed default limit", "passed": true, "details": {"error": null, "original_size": 16777217, "profile_schema_maximum": 67108864, "events": [["enter", "."], ["enter", "docs"], ["enter", "docs/observations"], ["stage", "docs/observations/.drm-mutation-owned-stage"], ["read-limit", 33554432], ["publish", "docs/observations/value.txt"], ["remove", "docs/observations/.drm-mutation-owned-stage"], ["exit", "docs/observations"], ["exit", "docs"], ["exit", "."]]}}
```
