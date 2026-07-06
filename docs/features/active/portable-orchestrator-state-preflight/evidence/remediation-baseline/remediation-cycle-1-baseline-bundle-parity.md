# Remediation Cycle 1 — Baseline Bundle-Parity (fail-before, R-1b)

Timestamp: 2026-07-06T15-30
Command: poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q
EXIT_CODE: 1
Output Summary: 1 failed, 6 passed. Failing test: `test_bundled_claude_payload_contains_all_repo_runtime_contracts`. Assertion message: `Bundle content differs from repo for: .claude\hooks\enforce-pr-author-skill.ps1` -- the diff shows the bundled snapshot is missing the `Test-PythonOrchestratorValidatorAvailable` function body present in the live hook (2550 identical leading characters, then a diff starting at the function definition). This is the pre-mirror failing baseline for R-1b; Phase 4 of the remediation plan mirrors the final post-fix `.claude/**` content into the bundle and Phase 4/5 re-run this same test to confirm it then passes (all 7 tests).
