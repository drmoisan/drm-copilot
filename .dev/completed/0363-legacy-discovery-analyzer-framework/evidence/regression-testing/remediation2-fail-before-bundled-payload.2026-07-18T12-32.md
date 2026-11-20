# Remediation Cycle 2 — Fail-Before Evidence (Bundled Payload Drift)

Timestamp: 2026-07-18T12-32

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`

EXIT_CODE: 1

Output Summary: FAIL (expected). 1 failed in 0.10s. Test id `test_bundled_claude_payload_contains_all_repo_runtime_contracts`. The assertion failed with `AssertionError: Repo file missing from bundle: .claude\agents\legacy-parity-analyst.md`. The test asserts existence per repo `.claude` file in iteration order and halts at the first missing file; the remediation finding identifies the full set of four missing bundle files:

- `.claude/agents/legacy-parity-analyst.md`
- `.claude/agents/migration-coverage-reviewer.md`
- `.claude/agents/requirements-reconciler.md`
- `.claude/agents/runtime-characterization-analyst.md`

These four repo `.claude/agents/` source files are absent from the bundled payload `extensions/drm-copilot/resources/claude-customizations/.claude/agents/`. The blocking drift is confirmed prior to any bundle change.
