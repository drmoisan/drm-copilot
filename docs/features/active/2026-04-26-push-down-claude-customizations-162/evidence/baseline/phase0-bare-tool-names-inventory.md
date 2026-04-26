# Phase 0 — Bare Tool-Name Inventory (Pre-Edit Baseline)

Timestamp: 2026-04-26T14:05:00Z

Command: `git grep -n -E "\b(validate_orchestration_artifacts|resolve_atomic_plan_prompt|resolve_policy_audit_template_asset)\b" -- ".claude/skills/atomic-plan-contract/SKILL.md" ".claude/skills/policy-audit-template-usage/SKILL.md"`

EXIT_CODE: 0

Output Summary:
5 bare tool-name occurrences across 2 files to be normalized in Phase 5:

**`.claude/skills/atomic-plan-contract/SKILL.md`**:
- Line 22: `` `validate_orchestration_artifacts` MCP tool with `artifact_type: "plan"` and `artifact_path: <plan-path>` before they can be reported as approved. ``
- Line 156: `` run the `validate_orchestration_artifacts` MCP tool with `artifact_type: "plan"` and `artifact_path: <plan-path>`, ``

**`.claude/skills/policy-audit-template-usage/SKILL.md`**:
- Line 18: `` the MCP server tool `resolve_policy_audit_template_asset` with asset selector `template`. ``
- Line 24: `` the MCP server tool `resolve_policy_audit_template_asset` with asset `template`, then copy the resolved asset... ``
- Line 42: `` Run the `validate_orchestration_artifacts` MCP tool with `artifact_type: "policy-audit"` and `artifact_path: <path>` ``

All 5 occurrences will be normalized to fully-qualified `mcp__drmCopilotExtension__` prefixed forms in Phase 5.
