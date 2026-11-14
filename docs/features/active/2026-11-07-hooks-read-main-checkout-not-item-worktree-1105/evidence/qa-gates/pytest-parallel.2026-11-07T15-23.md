# QA gate: pytest parallel run (issue 1105)

Timestamp: 2026-11-07T15-23
Task: [P4-T3]
Command: sh SCRATCH/issue-1105-pytest.sh final1 (`poetry run pytest -n auto -q -rfE -p no:cacheprovider` from the item worktree root; output to SCRATCH/issue-1105-final1-pytest.log)
EXIT_CODE: 0
Output Summary:
- Final summary: 16179 passed, 6 skipped in 79.79s. Failed 0, errors 0. One run; no re-run was needed.
- Listed modules (collected tests from a collect-only pass that runs no test / FAILED or ERROR lines in the gate run):
  - test_push_down_claude_resource_contracts.py: 14 / 0 (pass)
  - test_push_down_claude_pack_manifest_completeness.py: 2 / 0 (pass)
  - test_push_down_pack_manifest_dependency_closure.py: 18 / 0 (pass)
  - test_push_down_issue_824_follow_ups.py: 62 / 0 (pass)
  - test_push_down_codex_and_agents_resource_contracts.py: 9 / 0 (pass)
  - test_execution_environment_brief_contracts.py: 21 / 0 (pass)
  - test_discovery_documentation_contracts.py: 32 / 0 (pass)
  - test_claude_planning_integrity_contracts.py: 6 / 0 (pass)
- No Python file was added or edited; the run checks the mirror, manifest, and brief contracts (AC-13, AC-14).
