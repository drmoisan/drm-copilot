# AC-5 validator required key set (P1-T5)

Timestamp: 2026-10-12T08-11
Command: git grep -n -E '^[[:space:]]*"[a-z_]+",[[:space:]]*$' -- scripts/dev_tools/validate_epic_planner_state.py
EXIT_CODE: 0
Output Summary: rows with line numbers 34 through 57 inclusive number exactly 20 (rows at lines 35-45 and 48-56; the tuple layout is unchanged).
- REQUIRED_KEYS (11): objective, epic_feature_folder, epic_manifest_path, integration_branch, max_parallel_features, epic_worthiness, features, kickoff_prompt_path, completed_steps, next_step, last_updated
- REQUIRED_FEATURE_KEYS (9): issue_num, feature_folder, depends_on, wave, complexity_band, preparation_status, research_path, plan_path, preflight_status
