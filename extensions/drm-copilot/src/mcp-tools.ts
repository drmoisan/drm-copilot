import { getStderrExcerpt } from "./command-runtime";
import {
  REPO_AUTOMATION_TOOL_DEFINITIONS,
  type ToolDefinition,
} from "./mcp-repo-automation-tool-definitions";
import {
  type RepoAutomationExecutionResult,
  type RepoAutomationService,
} from "./repo-automation-service";
import {
  REPO_AUTOMATION_TOOLS,
  type RepoAutomationToolName,
} from "./repo-automation-tool-names";
import {
  resolveLinkParentChildToolInput,
  resolveResolveAtomicPlanPromptToolInput,
} from "./mcp-tool-inputs";
import {
  handleCollectCommitContext,
  handleCollectPrContext,
} from "./mcp-handlers/collect-context-handlers";
import { handleRunCodexNativeConverter } from "./mcp-handlers/codex-native-converter-handlers";
import {
  handleNewActiveFeatureFolder,
  handleNewPotentialBugEntry,
  handleNewPotentialEntry,
  handlePotentialToIssue,
} from "./mcp-handlers/feature-entry-handlers";
import {
  handleRunPoshQCAnalyze,
  handleRunPoshQCAnalyzeAutofix,
  handleRunPoshQCFormat,
  handleRunPoshQCSuite,
  handleRunPoshQCTest,
} from "./mcp-handlers/poshqc-handlers";
import {
  handlePushDownClaudeCustomizations,
  handlePushDownCodexAndAgentsCustomizations,
  handlePushDownCopilotCustomizations,
} from "./mcp-handlers/push-down-handlers";
import { handleResolveExecuteHardLockPrompt } from "./mcp-handlers/resolve-execute-hard-lock-prompt-handler";
import {
  handleResolvePolicyAuditTemplateAsset,
  handleValidateOrchestrationArtifacts,
} from "./mcp-handlers/template-validation-handlers";
import { normalizeWorkspaceRoot } from "./workflow-command-arguments";

export { DEFAULT_HARD_LOCK_PROMPT_OUTPUT_PATH } from "./mcp-handlers/resolve-execute-hard-lock-prompt-handler";

export interface RepoAutomationMcpToolResult extends Record<string, unknown> {
  readonly ok: boolean;
  readonly tool: RepoAutomationToolName;
  readonly workspace_root: string;
  readonly artifacts?: ReadonlyArray<string>;
  readonly asset_id?: string;
  readonly bundled_source_path?: string;
  readonly destination_path?: string;
  readonly summary: string;
  readonly stderr_excerpt?: string;
}

function inferWorkspaceRoot(rawInput: unknown): string {
  if (
    typeof rawInput !== "object" ||
    rawInput === null ||
    Array.isArray(rawInput)
  ) {
    return process.cwd();
  }

  const workspaceRoot = (rawInput as Readonly<Record<string, unknown>>)[
    "workspace_root"
  ];
  return normalizeWorkspaceRoot(workspaceRoot, process.cwd());
}

function toMcpToolResult(
  result: RepoAutomationExecutionResult,
): RepoAutomationMcpToolResult {
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
  };
}

function toFailureToolResult(
  tool: RepoAutomationToolName,
  workspaceRoot: string,
  error: unknown,
): RepoAutomationMcpToolResult {
  const stderrExcerpt = getStderrExcerpt(error);
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
export function listRepoAutomationTools(): ReadonlyArray<ToolDefinition> {
  return REPO_AUTOMATION_TOOL_DEFINITIONS;
}

/**
 * Dispatches a semantic repo-automation tool call through the shared service layer.
 *
 * @param toolName The semantic snake_case tool name.
 * @param rawInput The raw MCP tool arguments.
 * @param service The shared repo-automation service.
 * @returns A structured result that can be surfaced to Codex.
 */
export async function dispatchRepoAutomationTool(
  toolName: RepoAutomationToolName,
  rawInput: unknown,
  service: RepoAutomationService,
): Promise<RepoAutomationMcpToolResult> {
  const workspaceRoot = inferWorkspaceRoot(rawInput);

  try {
    switch (toolName) {
      case "collect_commit_context": {
        return toMcpToolResult(
          await handleCollectCommitContext(rawInput, service),
        );
      }

      case "collect_pr_context": {
        return toMcpToolResult(await handleCollectPrContext(rawInput, service));
      }

      case "run_codex_native_converter": {
        return toMcpToolResult(
          await handleRunCodexNativeConverter(rawInput, service),
        );
      }

      case "push_down_copilot_customizations": {
        return toMcpToolResult(
          await handlePushDownCopilotCustomizations(rawInput, service),
        );
      }

      case "push_down_codex_and_agents_customizations": {
        return toMcpToolResult(
          await handlePushDownCodexAndAgentsCustomizations(rawInput, service),
        );
      }

      case "push_down_claude_customizations": {
        return toMcpToolResult(
          await handlePushDownClaudeCustomizations(rawInput, service),
        );
      }

      case "new_potential_bug_entry": {
        return toMcpToolResult(
          await handleNewPotentialBugEntry(rawInput, service),
        );
      }

      case "new_potential_entry": {
        return toMcpToolResult(
          await handleNewPotentialEntry(rawInput, service),
        );
      }

      case "potential_to_issue": {
        return toMcpToolResult(await handlePotentialToIssue(rawInput, service));
      }

      case "new_active_feature_folder": {
        return toMcpToolResult(
          await handleNewActiveFeatureFolder(rawInput, service),
        );
      }

      case "run_poshqc_format": {
        return toMcpToolResult(await handleRunPoshQCFormat(rawInput, service));
      }

      case "run_poshqc_analyze": {
        return toMcpToolResult(await handleRunPoshQCAnalyze(rawInput, service));
      }

      case "run_poshqc_test": {
        return toMcpToolResult(await handleRunPoshQCTest(rawInput, service));
      }

      case "run_poshqc_analyze_autofix": {
        return toMcpToolResult(
          await handleRunPoshQCAnalyzeAutofix(rawInput, service),
        );
      }

      case "run_poshqc_suite": {
        return toMcpToolResult(await handleRunPoshQCSuite(rawInput, service));
      }

      case "resolve_policy_audit_template_asset": {
        return toMcpToolResult(
          await handleResolvePolicyAuditTemplateAsset(rawInput, service),
        );
      }

      case "resolve_execute_hard_lock_prompt": {
        return toMcpToolResult(
          await handleResolveExecuteHardLockPrompt(rawInput, service),
        );
      }

      case "resolve_atomic_plan_prompt": {
        const input = resolveResolveAtomicPlanPromptToolInput(rawInput);
        return toMcpToolResult(await service.resolveAtomicPlanPrompt(input));
      }

      case "link_parent_child": {
        const input = resolveLinkParentChildToolInput(rawInput);
        return toMcpToolResult(await service.linkParentChild(input));
      }

      case "validate_orchestration_artifacts": {
        return toMcpToolResult(
          await handleValidateOrchestrationArtifacts(rawInput, service),
        );
      }
    }
  } catch (error: unknown) {
    return toFailureToolResult(toolName, workspaceRoot, error);
  }
}

/**
 * Checks whether a tool name is one of the semantic repo-automation MCP tools.
 *
 * @param name The tool name to inspect.
 * @returns True when the supplied name is a supported semantic tool.
 */
export function isRepoAutomationToolName(
  name: string,
): name is RepoAutomationToolName {
  return REPO_AUTOMATION_TOOLS.includes(name as RepoAutomationToolName);
}
