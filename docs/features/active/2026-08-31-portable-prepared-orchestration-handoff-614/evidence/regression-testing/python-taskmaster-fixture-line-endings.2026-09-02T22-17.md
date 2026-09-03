# TaskMaster #469 Committed Fixture Byte Verification

Timestamp: 2026-09-02T22-17-04:00
Command: poetry run pytest tests/scripts/dev_tools/test_orchestration_handoff_taskmaster_469.py -k fixture_hashes_and_source_history_are_pinned --no-cov -q
EXIT_CODE: 1

Output Summary: Both parameterized fixture directions failed at test_orchestration_handoff_taskmaster_469.py:77. Each committed plan file hashes to 089467fcb70ebc8b3fd999b1426d41dfbf40016c062d560e76948558b3927864, while each fixture.json pins 54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f. The run reported 2 failed and 54 deselected in 0.10 seconds.

## Supporting read-only checks

Command: Get-FileHash -Algorithm SHA256 for both plan fixtures; git diff --quiet HEAD for both paths; git check-attr -a for both paths; read fixture.json plan.sha256
EXIT_CODE: 0

- claude-to-codex plan: working-tree SHA-256 089467fcb70ebc8b3fd999b1426d41dfbf40016c062d560e76948558b3927864; pinned SHA-256 54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f; git diff exit 0.
- codex-to-claude plan: working-tree SHA-256 089467fcb70ebc8b3fd999b1426d41dfbf40016c062d560e76948558b3927864; pinned SHA-256 54c9718097de0a151947ca2e639856e67fe1b7abfbf9edc75adac80ea3c9ba2f; git diff exit 0.
- Git attributes for both paths: text=auto and eol=lf, inherited from repository .gitattributes line 1.

The working-tree files are identical to HEAD according to git diff. This is therefore a committed-head defect, not an uncommitted local change. The earlier accepted Python and integration evidence explicitly depended on temporary CRLF hydration and does not supersede this result.
