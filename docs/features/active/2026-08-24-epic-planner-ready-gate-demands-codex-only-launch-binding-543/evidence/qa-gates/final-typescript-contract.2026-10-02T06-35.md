# Final TypeScript contract / schema compatibility (issue #543)

Timestamp: 2026-10-02T06-35
Task: P9-T6
Loop iteration: 2
Command: `git diff ef80c57df8f8bbc7d2e9ac51586150dfee3cd5fd --stat -- extensions/drm-copilot/src/mcp-tool-definitions.ts extensions/drm-copilot/src/mcp-repo-automation-tool-definitions.ts extensions/drm-copilot/src/mcp-tool-inputs.ts` and `git status --porcelain -- <same three paths>`
Route: native (D2, D3) for the anchored diff
EXIT_CODE: 0

Output Summary:
- Both commands printed nothing: the MCP `validate_orchestration_artifacts` input schema and input mapping are unchanged.
- Every new TypeScript option is optional and defaults to the pre-fix behaviour:
  - `validateEpicPlannerChildLaunchBindings(features, options: LaunchPathGateOptions = {})`: `requireLaunchPaths` absent means every feature is validated.
  - `validateEpicPlannerLaunchEvidence(state, context, options = {})` and `validateEpicReadinessIntegrity(state, stateText, context, options = {})`: same default.
  - `ValidateEpicPlannerStateOptions.requireCodexModelRouting?` and `.requireCodexTopology?`: absent means the ready gate key-gates launch evidence, the intended behaviour change; asserting either restores unconditional validation.
  - The `epic-planner-state` dispatch case forwards both flags only when defined (conditional spread).
