# pytest Gate, Post-Merge (P6-T6 re-run after merge commit 25dcbcdc2)

Timestamp: 2026-11-10T03-55
Command: sh SCRATCH/issue-1164-pytest-gate.sh (env -u VIRTUAL_ENV poetry run pytest tests/ -n auto -q -p no:cacheprovider --cov-branch --cov-report=term-missing --cov-report=json:SCRATCH/issue-1164-cov-postmerge.json --junitxml=SCRATCH/issue-1164-pytest-postmerge.junit.xml --cov)
EXIT_CODE: 0
Output Summary:
- Run started 2026-11-10T03-55 (UTC), ended 2026-11-10T04-01; summary line "16667 passed, 6 skipped in 344.78s (0:05:44)"; 0 failed. JUnit: 16673 tests, 0 failures, 0 errors, 6 skipped.
- Counts against the Phase 0 baseline (evidence/baseline/pytest-gate.2026-11-09T23-39.md: 16590 passed, 0 failed, 6 skipped) and the pre-merge final (16659 passed): the 8 additional tests are the main-side suites of PR #1166. No new failing test.
- Repo-wide (JSON report totals): line 34525 / 35546 = 97.13% (Phase 0 97.11%, pre-merge final 97.13%); branch 12758 / 13514 = 94.41% (Phase 0 94.38%, pre-merge final 94.41%). No drop.
- Per-file (JSON report), post-merge versus Phase 0 baseline (no drop):
  - scripts/dev_tools/_blast_radius_scheduling.py: line 171/171 = 100.00%, branch 40/40 = 100.00% (baseline 100.00% / 100.00%)
  - scripts/dev_tools/_parallel_drift_scheduling.py: line 47/47 = 100.00%, branch 18/18 = 100.00% (baseline 100.00% / 100.00%)
  - scripts/dev_tools/_parallel_state_records.py: line 191/191 = 100.00%, branch 96/96 = 100.00% (baseline 100.00% / 100.00%)
  - scripts/dev_tools/parallel_drift_detection.py: line 80/80 = 100.00%, branch 26/26 = 100.00% (baseline 100.00% / 100.00%)
  - scripts/dev_tools/parallel_drift_detection_cli.py: line 75/75 = 100.00%, branch 10/10 = 100.00% (baseline 100.00% / 100.00%)
  - scripts/dev_tools/parallel_manifest_contract.py: line 168/168 = 100.00%, branch 82/82 = 100.00% (baseline 100.00% / 100.00%)
  - scripts/dev_tools/validate_parallel_orchestrator_state.py: line 88/90 = 97.78%, branch 32/34 = 94.12% (baseline 97.73% / 94.12%)
  - scripts/dev_tools/validate_parallel_planner_state.py: line 117/117 = 100.00%, branch 46/46 = 100.00% (baseline 100.00% / 100.00%)
- Named suites (JUnit cases, failed): test_push_down_claude_resource_contracts 14/0; test_push_down_codex_and_agents_resource_contracts 9/0; test_push_down_claude_pack_manifest_completeness 2/0; test_push_down_codex_and_agents_pack_manifest_completeness 2/0; test_push_down_pack_manifest_dependency_closure 18/0; test_blast_radius_config_parity 20/0; test_claude_rules_frontmatter 9/0; test_parallel_planner_surface_contracts 24/0; test_parallel_orchestrator_surface_contracts 38/0; test_parallel_issue_combination_contracts 24/0; test_parallel_state_scheduling_parity 22/0; test_parallel_manifest_bash_parity 133/0 (5 skipped, as before); test_blast_radius_access_weights 18/0.
- Main-side suites merged from PR #1166: test_bash_command_shape_surfaces 6/0; test_execution_environment_brief_contracts 23/0; test_claude_rules_frontmatter (above, includes the new bash-command-shape rule) 9/0.
