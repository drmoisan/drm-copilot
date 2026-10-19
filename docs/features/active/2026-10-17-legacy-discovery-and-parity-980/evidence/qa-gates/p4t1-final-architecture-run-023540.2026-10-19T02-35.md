Timestamp: 2026-10-19T02:35:40.536071+00:00
Command: poetry run python SCRATCH\issue-980-p4t1-architecture.py docs\features\active\2026-10-17-legacy-discovery-and-parity-980\evidence\qa-gates\p4t1-analyzer-repair-manifest.2026-10-19T02-32.json
EXIT_CODE: 1
Output Summary:

```text
PASS canonical package and optional-import boundary: __init__.py
Traceback (most recent call last):
  File "SCRATCH\issue-980-p4t1-architecture.py", line 23, in <module>
    assert not any(value.startswith(('scripts', 'subprocess', 'socket', 'requests', 'http', 'urllib', 'os')) for value in imports), path
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py

```

Exact source/test bytes unchanged: True
Raw command output and hashes: docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p4t1-final-architecture-run-023540.2026-10-19T02-35.json
