# Final QC: pytest Gate (P4-T4)

Timestamp: 2026-11-24T17-24
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest (launcher pytest suite: poetry run pytest -n auto, integration and golden lanes excluded; testpaths tests), run through SCRATCH/issue-1220-retry.sh
EXIT_CODE: 0
Output Summary: 17104 passed, 6 skipped, 0 failed in 72.96s (first attempt, no queue timeout). Same counts as the Phase 0 baseline (17104 passed, 6 skipped). The four push-down contract files test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py and test_push_down_pack_manifest_dependency_closure.py are under testpaths and report no FAILED or ERROR line (pass); they also passed in isolation in the P2 and P3 gates (43 passed each). No Python file is in scope, so no Python coverage threshold applies.
