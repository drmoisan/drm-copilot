# Stage J Python Final-QC Test Gate (P3-T3)

Timestamp: 2026-11-08T23-22
Command: poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1097-j-final3-coverage.json --cov (from the worktree root; VIRTUAL_ENV set to the main checkout's .venv, PYTHONPATH set to packages/discovery-runtime/src of the worktree; one run; output stored under SCRATCH); figures from the JSON report totals
EXIT_CODE: 0
Output Summary:
  16590 passed, 6 skipped, 0 failed, 0 errors in 269.05 s. Baseline (stage-j-python-test.2026-11-08T22-10.md): 16590 passed, 6 skipped, 0 failed.
  Repo-wide (JSON totals): line 97.11% (34334 of 35355); branch 94.37% (12668 of 13424). Baseline: line 97.11% (34334 of 35355), branch 94.37% (12668 of 13424). No drop. Terminal TOTAL row: 96% combined.
  The named contract tests are in this run and pass (0 FAILED and 0 ERROR lines): test_push_down_claude_resource_contracts.py, test_push_down_codex_and_agents_resource_contracts.py, test_push_down_claude_pack_manifest_completeness.py, test_push_down_pack_manifest_dependency_closure.py (including test_claude_manifest_powershell_dependency_closure), and test_push_down_issue_824_follow_ups.py.
  The run started beside the P3-T2 Pester run on the tree of the P3-T1 record commit; the only later commit adds evidence and the plan check-off, which no Python test reads for this stage. The stage changes no Python file.
