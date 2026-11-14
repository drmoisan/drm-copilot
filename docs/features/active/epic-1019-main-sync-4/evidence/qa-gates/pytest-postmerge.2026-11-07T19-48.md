# Pytest final gate (after the main merge)

Timestamp: 2026-11-07T19-36
Command: poetry run pytest -n auto --cov --cov-branch --cov-report=json:SCRATCH/postmerge/coverage.json --cov-report=term --junitxml=SCRATCH/postmerge/pytest-junit.xml -q -p no:cacheprovider
EXIT_CODE: 0
Output Summary:
- Tree: merge commit 9b650459c (parents 2f5968dca and origin/main 12825cb00).
- Result: 16480 passed, 6 skipped, 0 failed, 0 errors in 150.08s.
- Coverage (combined line and branch, TOTAL row): 96% (35278 statements, 1021 missed; 13388 branches, 556 partial). Phase 0 baseline: 96% (1110 missed, 572 partial).
- Mirror and bundle parity contract tests passed in this run: test_push_down_claude_resource_contracts (14), test_push_down_codex_and_agents_resource_contracts (9), test_push_down_claude_pack_manifest_completeness (2), test_push_down_codex_and_agents_pack_manifest_completeness (2), test_push_down_pack_manifest_dependency_closure (18), test_codex_handoff_contract_parity (5), test_typescript_toolchain_instruction_contracts (15), test_push_down_issue_824_follow_ups (62).
