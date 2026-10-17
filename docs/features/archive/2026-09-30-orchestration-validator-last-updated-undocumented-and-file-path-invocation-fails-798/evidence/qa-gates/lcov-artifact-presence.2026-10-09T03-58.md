# LCOV Artifact Presence (P1-T2)

Timestamp: 2026-10-09T03-58
Command: poetry run python -S -c "import os, pathlib; p = pathlib.Path('artifacts/python/lcov.info'); print('LCOV_EXISTS', p.is_file(), 'LCOV_BYTES', os.stat(p).st_size)"
EXIT_CODE: 0
Output Summary: `LCOV_EXISTS True LCOV_BYTES 496729` for the repository-relative path `artifacts/python/lcov.info` (496729 bytes).
