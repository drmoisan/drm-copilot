# QA gate: pytest parallel run (issue 1105, remediation cycle 1)

Timestamp: 2026-11-07T16-50
Task: [P3-T3]
Command: sh SCRATCH/issue-1105-pytest.sh c1final1 (`poetry run pytest -n auto -q -rfE -p no:cacheprovider` from the item worktree root; output to SCRATCH/issue-1105-c1final1-pytest.log)
EXIT_CODE: 0
Output Summary:
- Final summary: 16179 passed, 6 skipped in 88.75s. One run; no re-run was needed.
- Totals: passed 16179, failed 0, skipped 6, errors 0. No FAILED or ERROR line.
- Named modules: 0 failures in each, because the run has no failure. Collected test counts come from a collection-only listing (`pytest --collect-only -q <module>`), which runs no test:
  - test_push_down_claude_resource_contracts.py: 14
  - test_push_down_claude_pack_manifest_completeness.py: 2
  - test_push_down_pack_manifest_dependency_closure.py: 18
  - test_push_down_issue_824_follow_ups.py: 62
  - test_execution_environment_brief_contracts.py: 21
  - test_claude_planning_integrity_contracts.py: 6
- No Python file changed. The [P3-T4] coverage fix that followed this run edits one PowerShell test file only, which no pytest module reads.
- No `poetry install` was run.
