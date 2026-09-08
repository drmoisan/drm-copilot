# Python Pytest Coverage Baseline

Timestamp: 2026-09-02T21-17
Command: `poetry run pytest --cov=src --cov=scripts/dev_tools --cov-branch --cov-report=term-missing`
Working Directory: repository root
EXIT_CODE: 0

Output Summary: 4,382 tests passed and 5 tests skipped. LCOV recorded 92.8608% repository line coverage (14,646/15,772) and 85.4181% branch coverage (4,903/5,740), exceeding the 85% line and 75% branch thresholds.

## Raw-byte fixture hydration observation

The first run returned exit code 1 because both TaskMaster #469 pinned-plan fixtures were checked out with LF bytes (`089467fcb70ebc8b3fd999b1426d41dfbf40016c062d560e76948558b3927864`), while their immutable metadata pins the equivalent CRLF bytes (`54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f`). Before the accepted run, only those two working-copy fixture files were mechanically hydrated to CRLF. After the accepted run, both were restored to their committed LF bytes. `git diff --quiet -- <both-fixture-paths>` returned 0 and the subsequent `git status --porcelain -- <both-fixture-paths>` returned no paths. This local working-copy hydration does not establish that a fresh Linux or CI checkout preserves the pinned raw bytes; exact-head CI remains a separate lifecycle gate.
