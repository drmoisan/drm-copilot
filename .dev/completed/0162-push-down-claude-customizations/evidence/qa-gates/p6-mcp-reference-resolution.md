# P6-T3 MCP Reference Resolution Check

Timestamp: 2026-04-26T15-40
Command: Regex search `mcp__drmCopilotExtension__([a-z_]+)` across 5 plan-specified skill files, verified against `extensions/drm-copilot/src/repo-automation-tool-names.ts`.
EXIT_CODE: 0

## Output Summary

**Valid tool names in `repo-automation-tool-names.ts` (18 entries):**
`collect_commit_context`, `collect_pr_context`, `push_down_copilot_customizations`,
`push_down_codex_and_agents_customizations`, `new_potential_bug_entry`, `new_potential_entry`,
`link_parent_child`, `potential_to_issue`, `new_active_feature_folder`, `run_poshqc_format`,
`run_poshqc_analyze`, `run_poshqc_test`, `run_poshqc_analyze_autofix`, `run_poshqc_suite`,
`resolve_policy_audit_template_asset`, `resolve_execute_hard_lock_prompt`, `resolve_atomic_plan_prompt`,
`validate_orchestration_artifacts`

**MCP references found across the 5 checked skill files:**

| File | Tool Name | Valid |
|------|-----------|-------|
| `.claude/skills/feature-promotion-lifecycle/SKILL.md` | `new_potential_entry` | ✓ |
| `.claude/skills/feature-promotion-lifecycle/SKILL.md` | `new_potential_bug_entry` | ✓ |
| `.claude/skills/feature-promotion-lifecycle/SKILL.md` | `potential_to_issue` | ✓ |
| `.claude/skills/feature-promotion-lifecycle/SKILL.md` | `new_active_feature_folder` | ✓ |
| `.claude/skills/pr-base-branch-merge-base/SKILL.md` | `collect_pr_context` | ✓ |
| `.claude/skills/execute-hard-lock/SKILL.md` | `resolve_execute_hard_lock_prompt` | ✓ |
| `.claude/skills/atomic-plan-contract/SKILL.md` | `validate_orchestration_artifacts` | ✓ |
| `.claude/skills/policy-audit-template-usage/SKILL.md` | `resolve_policy_audit_template_asset` | ✓ |
| `.claude/skills/policy-audit-template-usage/SKILL.md` | `validate_orchestration_artifacts` | ✓ |

**UNKNOWN_MCP_REFERENCES: []**

All 9 distinct tool references (across the 5 plan-specified files) resolve to entries in `repo-automation-tool-names.ts`. Zero unknown references.
