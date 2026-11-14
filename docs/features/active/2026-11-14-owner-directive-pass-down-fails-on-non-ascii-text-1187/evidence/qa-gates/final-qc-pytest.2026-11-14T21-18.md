# Final QC - pytest Gate (P3-T3)

Timestamp: 2026-11-14T21-17
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest (launched from the item worktree root by SCRATCH/issue-1187-pytest-gate.sh; pytest -n auto)
EXIT_CODE: 0
Output Summary:
- 16928 passed, 6 skipped in 56.20s; 0 failed.
- tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, and test_push_down_pack_manifest_dependency_closure.py: passed (no failure or skip reported; they also passed alone in the P2-T3 task check, 41 passed).

Comparison with the Phase 0 baseline (evidence/baseline/pytest.2026-11-14T19-14.md, the greatest pytest.*.md): baseline 16928 passed, 6 skipped, 0 failed; final 16928 passed, 6 skipped, 0 failed. No new failure (AC-14; AC-20 local part).
