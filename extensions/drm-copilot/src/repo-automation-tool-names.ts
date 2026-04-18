export const REPO_AUTOMATION_TOOLS = [
  "collect_commit_context",
  "collect_pr_context",
  "push_down_copilot_customizations",
  "push_down_codex_and_agents_customizations",
  "new_potential_bug_entry",
  "new_potential_entry",
  "potential_to_issue",
  "new_active_feature_folder",
  "run_poshqc_format",
  "run_poshqc_analyze",
  "run_poshqc_test",
  "run_poshqc_analyze_autofix",
  "run_poshqc_suite",
  "resolve_policy_audit_template_asset",
  "resolve_execute_hard_lock_prompt",
  "resolve_atomic_plan_prompt",
  "validate_orchestration_artifacts",
] as const;

export type RepoAutomationToolName = (typeof REPO_AUTOMATION_TOOLS)[number];
