# r2c2 Fail-Before — Bundle Push-Down Contract Test

Timestamp: 2026-07-18T22-58

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts -v`

EXIT_CODE: 1

Output Summary:
- Result: 1 failed (expected fail-before; task tagged `[expect-fail]`).
- The test `test_bundled_claude_payload_contains_all_repo_runtime_contracts` asserts every non-memory repo `.claude` file has a byte-identical counterpart in the bundled extension payload.
- Assertion message surfaced: `AssertionError: Repo file missing from bundle: .claude\hooks\enforce-discovery-artifact-gate.ps1`. The `assert` short-circuits on the first missing file, so only the first missing path appears in the raised message.
- Both blocking files are confirmed missing from the bundle destination `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` by direct directory listing prior to this run:
  - `.claude/hooks/enforce-discovery-artifact-gate.ps1` — missing from bundle
  - `.claude/hooks/validate-discovery-artifact-gate.ps1` — missing from bundle
- Neither destination path exists in `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/` (verified: the directory contains other hook files but not these two).
- This is the single Blocking finding remediated by Phase 1 of this cycle.
