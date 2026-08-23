"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DEFAULT_HARD_LOCK_PROMPT_OUTPUT_PATH = void 0;
exports.listRepoAutomationTools = listRepoAutomationTools;
exports.dispatchRepoAutomationTool = dispatchRepoAutomationTool;
exports.isRepoAutomationToolName = isRepoAutomationToolName;
const command_runtime_1 = require("./command-runtime");
const mcp_repo_automation_tool_definitions_1 = require("./mcp-repo-automation-tool-definitions");
const repo_automation_tool_names_1 = require("./repo-automation-tool-names");
const mcp_tool_inputs_1 = require("./mcp-tool-inputs");
const collect_context_handlers_1 = require("./mcp-handlers/collect-context-handlers");
const codex_native_converter_handlers_1 = require("./mcp-handlers/codex-native-converter-handlers");
const feature_entry_handlers_1 = require("./mcp-handlers/feature-entry-handlers");
const poshqc_handlers_1 = require("./mcp-handlers/poshqc-handlers");
const push_down_handlers_1 = require("./mcp-handlers/push-down-handlers");
const resolve_execute_hard_lock_prompt_handler_1 = require("./mcp-handlers/resolve-execute-hard-lock-prompt-handler");
const discovery_handlers_1 = require("./mcp-handlers/discovery-handlers");
const render_subagent_tree_handler_1 = require("./mcp-handlers/render-subagent-tree-handler");
const template_validation_handlers_1 = require("./mcp-handlers/template-validation-handlers");
const workflow_command_arguments_1 = require("./workflow-command-arguments");
var resolve_execute_hard_lock_prompt_handler_2 = require("./mcp-handlers/resolve-execute-hard-lock-prompt-handler");
Object.defineProperty(exports, "DEFAULT_HARD_LOCK_PROMPT_OUTPUT_PATH", { enumerable: true, get: function () { return resolve_execute_hard_lock_prompt_handler_2.DEFAULT_HARD_LOCK_PROMPT_OUTPUT_PATH; } });
function inferWorkspaceRoot(rawInput) {
    if (typeof rawInput !== "object" ||
        rawInput === null ||
        Array.isArray(rawInput)) {
        return process.cwd();
    }
    const workspaceRoot = rawInput["workspace_root"];
    return (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(workspaceRoot, process.cwd());
}
function toMcpToolResult(result) {
    return {
        ok: true,
        tool: result.tool,
        workspace_root: result.workspaceRoot,
        summary: result.summary,
        ...(result.artifacts === undefined ? {} : { artifacts: result.artifacts }),
        ...(result.assetId === undefined ? {} : { asset_id: result.assetId }),
        ...(result.bundledSourcePath === undefined
            ? {}
            : { bundled_source_path: result.bundledSourcePath }),
        ...(result.destinationPath === undefined
            ? {}
            : { destination_path: result.destinationPath }),
        ...(result.renderedTree === undefined
            ? {}
            : { rendered_tree: result.renderedTree }),
    };
}
function toFailureToolResult(tool, workspaceRoot, error) {
    const stderrExcerpt = (0, command_runtime_1.getStderrExcerpt)(error);
    return {
        ok: false,
        tool,
        workspace_root: workspaceRoot,
        summary: error instanceof Error ? error.message : String(error),
        ...(stderrExcerpt === undefined ? {} : { stderr_excerpt: stderrExcerpt }),
    };
}
/**
 * Lists the semantic repo-automation tools exposed through the MCP bridge.
 *
 * @returns Stable tool definitions advertised to MCP clients.
 */
function listRepoAutomationTools() {
    return mcp_repo_automation_tool_definitions_1.REPO_AUTOMATION_TOOL_DEFINITIONS;
}
/**
 * Dispatches a semantic repo-automation tool call through the shared service layer.
 *
 * @param toolName The semantic snake_case tool name.
 * @param rawInput The raw MCP tool arguments.
 * @param service The shared repo-automation service.
 * @returns A structured result that can be surfaced to Codex.
 */
async function dispatchRepoAutomationTool(toolName, rawInput, service) {
    const workspaceRoot = inferWorkspaceRoot(rawInput);
    try {
        switch (toolName) {
            case "collect_commit_context": {
                return toMcpToolResult(await (0, collect_context_handlers_1.handleCollectCommitContext)(rawInput, service));
            }
            case "collect_pr_context": {
                return toMcpToolResult(await (0, collect_context_handlers_1.handleCollectPrContext)(rawInput, service));
            }
            case "run_codex_native_converter": {
                return toMcpToolResult(await (0, codex_native_converter_handlers_1.handleRunCodexNativeConverter)(rawInput, service));
            }
            case "push_down_copilot_customizations": {
                return toMcpToolResult(await (0, push_down_handlers_1.handlePushDownCopilotCustomizations)(rawInput, service));
            }
            case "push_down_codex_and_agents_customizations": {
                return toMcpToolResult(await (0, push_down_handlers_1.handlePushDownCodexAndAgentsCustomizations)(rawInput, service));
            }
            case "push_down_claude_customizations": {
                return toMcpToolResult(await (0, push_down_handlers_1.handlePushDownClaudeCustomizations)(rawInput, service));
            }
            case "new_potential_bug_entry": {
                return toMcpToolResult(await (0, feature_entry_handlers_1.handleNewPotentialBugEntry)(rawInput, service));
            }
            case "new_potential_entry": {
                return toMcpToolResult(await (0, feature_entry_handlers_1.handleNewPotentialEntry)(rawInput, service));
            }
            case "potential_to_issue": {
                return toMcpToolResult(await (0, feature_entry_handlers_1.handlePotentialToIssue)(rawInput, service));
            }
            case "new_active_feature_folder": {
                return toMcpToolResult(await (0, feature_entry_handlers_1.handleNewActiveFeatureFolder)(rawInput, service));
            }
            case "run_poshqc_format": {
                return toMcpToolResult(await (0, poshqc_handlers_1.handleRunPoshQCFormat)(rawInput, service));
            }
            case "run_poshqc_analyze": {
                return toMcpToolResult(await (0, poshqc_handlers_1.handleRunPoshQCAnalyze)(rawInput, service));
            }
            case "run_poshqc_test": {
                return toMcpToolResult(await (0, poshqc_handlers_1.handleRunPoshQCTest)(rawInput, service));
            }
            case "run_poshqc_analyze_autofix": {
                return toMcpToolResult(await (0, poshqc_handlers_1.handleRunPoshQCAnalyzeAutofix)(rawInput, service));
            }
            case "run_poshqc_suite": {
                return toMcpToolResult(await (0, poshqc_handlers_1.handleRunPoshQCSuite)(rawInput, service));
            }
            case "resolve_policy_audit_template_asset": {
                return toMcpToolResult(await (0, template_validation_handlers_1.handleResolvePolicyAuditTemplateAsset)(rawInput, service));
            }
            case "resolve_execute_hard_lock_prompt": {
                return toMcpToolResult(await (0, resolve_execute_hard_lock_prompt_handler_1.handleResolveExecuteHardLockPrompt)(rawInput, service));
            }
            case "resolve_atomic_plan_prompt": {
                const input = (0, mcp_tool_inputs_1.resolveResolveAtomicPlanPromptToolInput)(rawInput);
                return toMcpToolResult(await service.resolveAtomicPlanPrompt(input));
            }
            case "link_parent_child": {
                const input = (0, mcp_tool_inputs_1.resolveLinkParentChildToolInput)(rawInput);
                return toMcpToolResult(await service.linkParentChild(input));
            }
            case "validate_orchestration_artifacts": {
                return toMcpToolResult(await (0, template_validation_handlers_1.handleValidateOrchestrationArtifacts)(rawInput, service));
            }
            case "render_subagent_tree": {
                return toMcpToolResult(await (0, render_subagent_tree_handler_1.handleRenderSubagentTree)(rawInput, service));
            }
            case "validate_discovery_artifacts": {
                return toMcpToolResult(await (0, discovery_handlers_1.handleValidateDiscoveryArtifacts)(rawInput, service));
            }
            case "run_discovery_init": {
                return toMcpToolResult(await (0, discovery_handlers_1.handleRunDiscoveryInit)(rawInput, service));
            }
            case "run_discovery_repo_inventory": {
                return toMcpToolResult(await (0, discovery_handlers_1.handleRunDiscoveryRepoInventory)(rawInput, service));
            }
            case "run_discovery_dotnet_analyzer": {
                return toMcpToolResult(await (0, discovery_handlers_1.handleRunDiscoveryDotnetAnalyzer)(rawInput, service));
            }
            case "run_discovery_vsto_analyzer": {
                return toMcpToolResult(await (0, discovery_handlers_1.handleRunDiscoveryVstoAnalyzer)(rawInput, service));
            }
            case "run_discovery_scenario_generation": {
                return toMcpToolResult(await (0, discovery_handlers_1.handleRunDiscoveryScenarioGeneration)(rawInput, service));
            }
            case "run_discovery_report": {
                return toMcpToolResult(await (0, discovery_handlers_1.handleRunDiscoveryReport)(rawInput, service));
            }
        }
    }
    catch (error) {
        return toFailureToolResult(toolName, workspaceRoot, error);
    }
}
/**
 * Checks whether a tool name is one of the semantic repo-automation MCP tools.
 *
 * @param name The tool name to inspect.
 * @returns True when the supplied name is a supported semantic tool.
 */
function isRepoAutomationToolName(name) {
    return repo_automation_tool_names_1.REPO_AUTOMATION_TOOLS.includes(name);
}
