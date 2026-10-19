# P4-T1 scratch helper command rejection

Timestamp: 2026-10-19T02:23:02Z
Command: Create local scratch QA helper files and record the rejected invocation
EXIT_CODE: Not executed; PreToolUse rejected both shell calls
Output Summary: Two exec_command calls were rejected before execution with zero file mutations. The first command attempted only to write two scratch Python QA helpers. The second attempted only to write this rejection receipt. Neither command requested a GitHub issue operation. Both returned the same rejection:

> PROMOTION_MCP_ONLY_BLOCKED: Direct GitHub issue creation via `gh` bypasses the approved drm-copilot MCP promotion path (`mcp__drm-copilot__new_potential_entry` -> `mcp__drm-copilot__potential_to_issue` -> `mcp__drm-copilot__new_active_feature_folder`). Use those MCP tools instead.

The authorized scratch helper files and this evidence were written through the normal `apply_patch` file-edit tool. No hook or policy was modified, no lifecycle action was delegated to a different owner, and no final gate was run. All 26 candidate source/test paths remain frozen. The parent explicitly confirmed that local scratch QA helpers were already authorized.

The blocked calls returned no process exit status because they never launched. This receipt records the rejection and actual corrective action; it does not report those calls as successful executions.
