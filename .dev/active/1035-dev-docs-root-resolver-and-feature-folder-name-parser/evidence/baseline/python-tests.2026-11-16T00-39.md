# P0-T3 Python Gate — Phase 0 baseline

Timestamp: 2026-11-16T00-39
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools --cov=scripts.dev_tools --cov-branch --cov-report=term --cov-report=json:SCRATCH/p0-cov.json --junitxml=SCRATCH/p0-junit.xml -q (launcher runs poetry run pytest -n auto with the integration and golden lanes excluded)
EXIT_CODE: 0
Output Summary: 9200 passed, 0 failed, 6 skipped in 82.86s. Repo-wide (scripts.dev_tools): line 96.11%, branch 91.86%, combined 94.97% (terminal TOTAL 95%). Per-file figures below are read from the JSON report. Pre-existing below-threshold files: copy_research_to_issue (line 48.75%, branch 46.15%), plan_progress_report (line 73.27%), atomic_executor.cli (branch 73.08%). The final gate is compared with these figures.

Note: the JSON report was first written by Windows Python to a drive-relative form of the SCRATCH path and was moved into SCRATCH unchanged before it was read.

| Module | Line % | Branch % |
| --- | --- | --- |
| scripts.dev_tools.json_config | 95.00 | 91.67 |
| scripts.dev_tools.new_active_feature_folder_flow | 92.05 | 90.00 |
| scripts.dev_tools.new_active_feature_folder_io | 97.27 | 88.00 |
| scripts.dev_tools.new_potential_bug_entry | 91.89 | 90.00 |
| scripts.dev_tools.potential_to_issue | 99.26 | 97.37 |
| scripts.dev_tools.potential_to_issue_content | 96.84 | 82.14 |
| scripts.dev_tools.copy_research_to_issue | 48.75 | 46.15 |
| scripts.dev_tools.atomic_executor.cli | 89.01 | 73.08 |
| scripts.dev_tools.atomic_executor.prompt_builder | 100.00 | 100.00 |
| scripts.dev_tools.atomic_executor.cli_workspace | 90.16 | 76.47 |
| scripts.dev_tools.atomic_executor.feature_resolver | 98.36 | 96.15 |
| scripts.dev_tools.plan_progress_report | 73.27 | 76.92 |
| scripts.dev_tools.pr_context.feature_docs | 93.45 | 86.96 |
| scripts.dev_tools.pr_context.render_feature_excerpts | 86.11 | 75.00 |
| scripts.dev_tools.pr_context.verification_evidence | 100.00 | 93.75 |
| scripts.dev_tools.pr_context.summary_helpers | 91.30 | 81.43 |
| scripts.dev_tools.pr_context.collector | 93.45 | 84.00 |
| scripts.dev_tools.epic_planner_readiness | 100.00 | 93.02 |
| scripts.dev_tools.epic_kickoff_contract | 92.76 | 85.94 |
| scripts.dev_tools.parallel_kickoff_contract | 100.00 | 100.00 |
| scripts.dev_tools._orchestrator_state_issue_adoption | 100.00 | 100.00 |
| scripts.dev_tools._orchestrator_state_feature_folder_record | 100.00 | 100.00 |
| scripts.dev_tools._epic_orchestrator_state_resolution | 100.00 | 100.00 |
| scripts.dev_tools._parallel_orchestrator_state_cohort_barrier | 99.07 | 98.21 |
| scripts.dev_tools.resolve_execute_plan_prompt | 95.35 | 90.38 |
| scripts.dev_tools.resolve_file_prompt | 92.90 | 82.76 |
| scripts.dev_tools.validate_evidence_locations | 100.00 | 100.00 |
| scripts.dev_tools.push_down_codex_and_agents_customizations | 98.18 | 88.89 |
| scripts.dev_tools.compute_blast_radius | 100.00 | 100.00 |
| scripts.dev_tools._blast_radius_token_shapes | 100.00 | 100.00 |
| scripts.dev_tools._blast_radius_write_intent | 98.00 | 95.24 |
