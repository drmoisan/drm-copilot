# Python Test Gate (P9-T4)

Timestamp: 2026-11-17T10-18
Command: env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest tests/scripts/dev_tools --cov=scripts.dev_tools --cov-branch --cov-report=term --cov-report=json:SCRATCH/final-cov.json --junitxml=SCRATCH/final-junit.xml -q (sh SCRATCH/issue-1035-p9t4-run.sh; the launcher runs poetry run pytest -n auto with the integration and golden lanes excluded; the same form as the Phase 0 baseline). Figures read from the JSON report with SCRATCH/issue-1035-pycov.py, the reader used for the baseline.
EXIT_CODE: 0
Output Summary: 9328 passed, 6 skipped, 0 failed in 47.78s. Repo-wide (scripts.dev_tools): line 96.23%, branch 92.07%, combined 95.12% (baseline 96.11%, 91.86%, 94.97%).

The first run (9326 passed, 0 failed) showed one per-file drop: scripts.dev_tools.pr_context.feature_docs line 93.45% to 93.37% and branch 86.96% to 86.36%. The cause is the denominator: the branch removed covered statements (168 to 166) and branches (92 to 88) from gather_feature_excerpts, while the same eleven pre-existing lines stayed uncovered (shifted by six lines) and no changed line is uncovered. Two tests were added to tests/scripts/dev_tools/test_feature_docs.py (TestParseReadinessValue: no readiness marker, and an unknown readiness value) covering the two pre-existing `return None` lines of _parse_readiness_value; the Python loop was restarted from formatting (python-static.2026-11-17T10-18.md) and this gate re-ran once.

| Module | Line % | Branch % | Baseline line % | Baseline branch % |
| --- | --- | --- | --- | --- |
| scripts.dev_tools.json_config | 99.19 | 97.73 | 95.00 | 91.67 |
| scripts.dev_tools.new_active_feature_folder_flow | 92.50 | 90.32 | 92.05 | 90.00 |
| scripts.dev_tools.new_active_feature_folder_io | 97.39 | 90.00 | 97.27 | 88.00 |
| scripts.dev_tools.new_potential_bug_entry | 92.04 | 90.00 | 91.89 | 90.00 |
| scripts.dev_tools.potential_to_issue | 99.31 | 97.50 | 99.26 | 97.37 |
| scripts.dev_tools.potential_to_issue_content | 97.06 | 82.14 | 96.84 | 82.14 |
| scripts.dev_tools.copy_research_to_issue | 50.00 | 46.15 | 48.75 | 46.15 |
| scripts.dev_tools.atomic_executor.cli | 89.07 | 73.08 | 89.01 | 73.08 |
| scripts.dev_tools.atomic_executor.prompt_builder | 100.00 | 100.00 | 100.00 | 100.00 |
| scripts.dev_tools.atomic_executor.cli_workspace | 90.32 | 76.47 | 90.16 | 76.47 |
| scripts.dev_tools.atomic_executor.feature_resolver | 98.36 | 96.15 | 98.36 | 96.15 |
| scripts.dev_tools.plan_progress_report | 82.35 | 84.62 | 73.27 | 76.92 |
| scripts.dev_tools.pr_context.feature_docs | 94.58 | 88.64 | 93.45 | 86.96 |
| scripts.dev_tools.pr_context.render_feature_excerpts | 86.84 | 76.32 | 86.11 | 75.00 |
| scripts.dev_tools.pr_context.verification_evidence | 100.00 | 93.75 | 100.00 | 93.75 |
| scripts.dev_tools.pr_context.summary_helpers | 91.36 | 81.43 | 91.30 | 81.43 |
| scripts.dev_tools.pr_context.collector | 93.53 | 84.00 | 93.45 | 84.00 |
| scripts.dev_tools.epic_planner_readiness | 100.00 | 93.18 | 100.00 | 93.02 |
| scripts.dev_tools.epic_kickoff_contract | 92.81 | 85.94 | 92.76 | 85.94 |
| scripts.dev_tools.parallel_kickoff_contract | 100.00 | 100.00 | 100.00 | 100.00 |
| scripts.dev_tools._orchestrator_state_issue_adoption | 100.00 | 100.00 | 100.00 | 100.00 |
| scripts.dev_tools._orchestrator_state_feature_folder_record | 100.00 | 100.00 | 100.00 | 100.00 |
| scripts.dev_tools._epic_orchestrator_state_resolution | 100.00 | 100.00 | 100.00 | 100.00 |
| scripts.dev_tools._parallel_orchestrator_state_cohort_barrier | 99.08 | 98.21 | 99.07 | 98.21 |
| scripts.dev_tools.resolve_execute_plan_prompt | 95.35 | 91.67 | 95.35 | 90.38 |
| scripts.dev_tools.resolve_file_prompt | 92.90 | 85.19 | 92.90 | 82.76 |
| scripts.dev_tools.validate_evidence_locations | 100.00 | 100.00 | 100.00 | 100.00 |
| scripts.dev_tools.push_down_codex_and_agents_customizations | 98.20 | 88.89 | 98.18 | 88.89 |
| scripts.dev_tools.compute_blast_radius | 100.00 | 100.00 | 100.00 | 100.00 |
| scripts.dev_tools._blast_radius_token_shapes | 100.00 | 100.00 | 100.00 | 100.00 |
| scripts.dev_tools._blast_radius_write_intent | 98.02 | 95.24 | 98.00 | 95.24 |

Pre-existing below-threshold files, each at or above its baseline: copy_research_to_issue (line 50.00%, branch 46.15%), plan_progress_report (line 82.35%), atomic_executor.cli (branch 73.08%).
