# Fail-Before: Planning-Only Registry (Issue #697, AC-3.1 red)

Timestamp: 2026-09-25T21-02
Command: pwsh -NoProfile -Command '$r = Invoke-Pester -Path tests/scripts/codex-hooks/codex-planning-only-registry.Tests.ps1 -Output Detailed -PassThru; exit $r.FailedCount'
EXIT_CODE: 33
ExpectedExitCode: 33
Output Summary: `Tests Passed: 2, Failed: 33, Skipped: 0, Inconclusive: 0, NotRun: 0`.
- AC-3.1 red: `invokes Get-EpicPlanningRegisteredMcpTool from no top-level statement` failed with `Expected 0, because the registry must be read lazily inside a function, but got 1.`
- The 32 other failures are the `-RegistryPath` cases, each failing with `ParameterBindingException: A parameter cannot be found that matches parameter name 'RegistryPath'.` (expected before the fix).
- The two entrypoint cases passed (the repository registry exists, so the unfixed entry still runs).

Failed `It` names:
- invokes Get-EpicPlanningRegisteredMcpTool from no top-level statement
- allows any tool with a missing registry when no checkpoint or attestation is present
- allows an mcp__ tool with a missing registry on a non-preparation route
- returns the committed-registry decision for apply_patch planning document edit (allow) with a missing registry
- returns the committed-registry decision for apply_patch production edit (deny) with a missing registry
- returns the committed-registry decision for apply_patch checkpoint delete (deny) with a missing registry
- returns the committed-registry decision for Bash git status (allow) with a missing registry
- returns the committed-registry decision for Bash git reset --hard (deny) with a missing registry
- allows lifecycle tool mcp__drm-copilot__new_potential_entry with a missing registry in preparation mode
- allows lifecycle tool mcp__drm-copilot__new_potential_bug_entry with a missing registry in preparation mode
- allows lifecycle tool mcp__drm-copilot__potential_to_issue with a missing registry in preparation mode
- allows lifecycle tool mcp__drm-copilot__new_active_feature_folder with a missing registry in preparation mode
- allows lifecycle tool mcp__drm-copilot__resolve_atomic_plan_prompt with a missing registry in preparation mode
- allows lifecycle tool mcp__drm-copilot__resolve_execute_hard_lock_prompt with a missing registry in preparation mode
- denies a lifecycle tool whose workspace_root differs from the attested cwd with a missing registry
- denies mcp__drm-copilot__validate_orchestration_artifacts with a reason naming the missing registry in preparation mode
- denies mcp__drm_copilot__validate_orchestration_artifacts with a reason naming the missing registry in preparation mode
- denies mcp__drm-copilot__resolve_orchestration_topology with a reason naming the missing registry in preparation mode
- denies mcp__drm_copilot__resolve_orchestration_topology with a reason naming the missing registry in preparation mode
- denies mcp__drm-copilot__resolve_provider_routing with a reason naming the missing registry in preparation mode
- denies mcp__drm_copilot__resolve_provider_routing with a reason naming the missing registry in preparation mode
- denies mcp__drm-copilot__transition_prepared_orchestration with a reason naming the missing registry in preparation mode
- denies mcp__drm_copilot__transition_prepared_orchestration with a reason naming the missing registry in preparation mode
- denies mcp__drm-copilot__unregistered_tool with a reason naming the missing registry in preparation mode
- allows semantic tool mcp__drm-copilot__validate_orchestration_artifacts with the committed registry in preparation mode
- allows semantic tool mcp__drm_copilot__validate_orchestration_artifacts with the committed registry in preparation mode
- allows semantic tool mcp__drm-copilot__resolve_orchestration_topology with the committed registry in preparation mode
- allows semantic tool mcp__drm_copilot__resolve_orchestration_topology with the committed registry in preparation mode
- allows semantic tool mcp__drm-copilot__resolve_provider_routing with the committed registry in preparation mode
- allows semantic tool mcp__drm_copilot__resolve_provider_routing with the committed registry in preparation mode
- allows semantic tool mcp__drm-copilot__transition_prepared_orchestration with the committed registry in preparation mode
- allows semantic tool mcp__drm_copilot__transition_prepared_orchestration with the committed registry in preparation mode
- throws for a semantic tool when the registry fixture is invalid
