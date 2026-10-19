# Optional failure presentation qualification

Timestamp: 2026-10-19T11-48
Command: poetry run python SCRATCH/issue-980-p4t8-optional-normalize.py
EXIT_CODE: 0
Output Summary: exact failed JSON/Markdown and raw stdout/stderr are recoverable from the verified gzip+base64 archive. Only repeated synthetic payload runs were shortened in readable views.

The original result remains 92 passed, 1 failed, 2 errors across 94 collected cases. The actual large test input remains unchanged. Source/test bytes and coverage were not modified by this operation. Archive and per-stream hashes, decoded lengths, substitutions and original/readable bindings are recorded in the paired JSON.
