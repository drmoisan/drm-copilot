# P2-T6 runtime identity probe setup

Timestamp: 2026-10-18T09-26

Command: `poetry run python SCRATCH/issue-980-p2t6-runtime-identity.py`

EXIT_CODE: 1

Output Summary: The cross-repository probe fixture supplied repository without the required path, revision and sha256 reference fields. Authoritative schema validation rejected the fixture before the foreign-runtime case executed. The source-runtime control had executed, but no complete verification result was claimed.

Correction: Supply the complete source feature reference using its captured path, immutable pin and exact artifact SHA-256. No schema or production code changed.
